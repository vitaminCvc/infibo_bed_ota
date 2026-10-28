import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:infibo_app/ota/firmware_ota_service.dart';
import 'package:infibo_app/ota/ota_checksums.dart';
import 'package:infibo_app/ota/ota_controller.dart';
import 'package:infibo_app/ota/ota_manifest.dart';
import 'package:infibo_app/ota/ota_service.dart';
import 'package:infibo_app/pages/settingpage/system_update_panel.dart';
import 'package:infibo_app/translation/app_translations.dart';
import 'firmware_ota_service_test.dart' show FakeBoard;
import 'ota_controller_test.dart' show TestGateway, TestService;

// 替换网络下载而非升级服务，验证 Controller 确实走完整分包/重启/回读流程。
class _Download extends TestService {
  _Download(super.gateway, this.file);
  final File file;
  OtaManifest published = const OtaManifest();
  @override
  Future<UpdateCheck> check() async =>
      UpdateCheck(await gateway.installedApp(), published);
  @override
  Future<File> download(
    OtaFile release, {
    CancelToken? cancelToken,
    void Function(double)? onProgress,
  }) async {
    downloads++;
    return file;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late OtaController controller;
  late _Download service;
  late FakeBoard board;
  late Uint8List bytes;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    directory = await Directory.systemTemp.createTemp('manual-board-install-');
    bytes = Uint8List(259);
    final vectors = ByteData.sublistView(bytes);
    vectors.setUint32(0, 0x20008000, Endian.little);
    vectors.setUint32(4, 0x08004009, Endian.little);
    final file = await File(
      '${directory.path}/test_APP_OTA.bin',
    ).writeAsBytes(bytes);
    service = _Download(TestGateway(), file);
    board = FakeBoard()..current = 0x0130;
    controller = OtaController(
      service: service,
      readRegister: (address) async =>
          address == 2 ? board.current : board.system,
      firmwareService: FirmwareOtaService(
        transport: board,
        wait: (_) async {},
        installDelay: Duration.zero,
      ),
    );
    controller.boardVersion = board.current;
  });
  tearDown(() async {
    controller.dispose();
    await directory.delete(recursive: true);
    Get.reset();
  });
  void published(int version) {
    controller.manifest = OtaManifest(
      firmware: FirmwareRelease(
        version: version == 0x0130 ? '1.3.0' : '1.2.5',
        url: Uri.parse('https://example.test/test_APP_OTA.bin'),
        size: bytes.length,
        sha256: sha256.convert(bytes).toString(),
        versionRegister: version,
        crc32: crc32(bytes),
      ),
    );
    service.published = controller.manifest!;
  }

  for (final target in [0x0130, 0x0125]) {
    test(
      'manual target $target reaches protocol and reports honest completion',
      () async {
        published(target);
        await controller.updateFirmware();
        expect(service.downloads, 1);
        expect(board.commands.last, 0xa004);
        expect(controller.boardVersion, target);
        expect(controller.phase, OtaPhase.success);
        expect(
          controller.noticeKey,
          target == 0x0130
              ? 'ota_board_reinstall_unverified'
              : 'ota_board_success',
        );
        expect(controller.takePrompt(), isFalse);
        expect(controller.firmwareAvailable, isTrue);
      },
    );

    testWidgets(
      'manual target $target has a clear confirmation that can be cancelled',
      (tester) async {
        published(target);
        await tester.pumpWidget(
          GetMaterialApp(
            translations: AppTranslations(),
            locale: const Locale('zh', 'CN'),
            home: Scaffold(body: SystemUpdatePanel(controller: controller)),
          ),
        );
        await tester.pumpAndSettle();
        final button = find.byKey(const ValueKey('ota-board-update'));
        await tester.ensureVisible(button);
        await tester.pumpAndSettle();
        expect(
          find.text(target == 0x0130 ? '下载并重新安装' : '下载并降级安装'),
          findsOneWidget,
        );
        await tester.tap(button);
        await tester.pumpAndSettle();
        expect(find.textContaining('同版本回读不能单独证明'), findsNothing);
        expect(find.text('设备须处于空闲状态，传输和安装期间请勿断电。'), findsOneWidget);
        await tester.tap(find.text('稍后'));
        await tester.pumpAndSettle();
        expect(service.downloads, 0);
        expect(board.commands, isEmpty);
        await tester.pumpWidget(const SizedBox.shrink());
      },
    );
  }
}
