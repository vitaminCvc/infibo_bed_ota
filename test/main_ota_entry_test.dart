import 'dart:async';
import 'package:infibo_app/config/app_brand.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:infibo_app/api/modbus/modbus_rtu_service.dart';
import 'package:infibo_app/pages/main/ui.dart';
import 'package:infibo_app/ota/ota_controller.dart';
import 'package:infibo_app/ota/ota_manifest.dart';
import 'package:infibo_app/routes/route_observer.dart';
import 'package:infibo_app/stores/user_store.dart';
import 'package:infibo_app/stores/app_header_clock_store.dart';
import 'package:infibo_app/translation/app_translations.dart';
import 'ota_controller_test.dart' show TestGateway, TestService;

class _Board extends ModbusRtuService {
  int state = 0;
  bool offline = false;
  @override
  Future<int> readHoldingRegister(int address) async {
    if (address == 6 && offline) throw StateError('offline');
    return address == 0x01e5
        ? 2
        : address == 6
        ? state
        : 0;
  }

  @override
  Future<void> sendCommandQueue(List<ModbusWriteCommand> commands) async {}
}

void main() {
  for (final brand in [AppBrands.global, AppBrands.uaeBiohackn]) {
    for (final scenario in [
      'idle',
      'busy',
      'offline',
      'latest',
      'firmwareOnly',
      'busyAfterPrompt',
    ]) {
      testWidgets(
        '${brand.flavor} home OTA checks once per page entry: $scenario',
        (tester) async {
          AppBrand.configure(brand);
          addTearDown(() => AppBrand.configure(AppBrands.global));
          SharedPreferences.setMockInitialValues({});
          Get.testMode = true;
          Get.put(UserStore());
          tester.view.physicalSize = const Size(1200, 1600);
          tester.view.devicePixelRatio = 1;
          final board = _Board()..state = scenario == 'busy' ? 1 : 0;
          board.offline = scenario == 'offline';
          final gateway = TestGateway()..code = scenario == 'latest' ? 2 : 1;
          final service = TestService(gateway);
          if (scenario == 'firmwareOnly') {
            service.publishedManifest = OtaManifest(
              firmware: FirmwareRelease(
                version: '1.3.1',
                versionRegister: 0x0131,
                url: Uri.parse('https://example.test/board.bin'),
                size: 8,
                sha256: 'a' * 64,
                crc32: 0,
              ),
            );
          }
          final shouldPrompt =
              scenario == 'idle' || scenario == 'busyAfterPrompt';
          final controller = OtaController(
            service: service,
            readRegister: board.readHoldingRegister,
          );
          final nav = GlobalKey<NavigatorState>();
          await tester.pumpWidget(
            GetMaterialApp(
              navigatorKey: nav,
              translations: AppTranslations(),
              locale: const Locale('zh', 'CN'),
              navigatorObservers: [appRouteObserver],
              home: MainPage(modbusService: board, otaController: controller),
            ),
          );
          await tester.pump(const Duration(seconds: 11));
          await tester.pump();
          expect(service.checks, 1);
          expect(
            find.byKey(const ValueKey('ota-confirmation-frame')),
            shouldPrompt ? findsOneWidget : findsNothing,
          );
          if (scenario == 'busyAfterPrompt') {
            board.state = 1;
            await tester.pump(const Duration(milliseconds: 400));
            await tester.tap(find.text('ota_confirm'.tr));
            await tester.pump();
            expect(controller.errorKey, 'ota_device_busy');
          } else if (scenario == 'idle') {
            nav.currentState!.pop();
            await tester.pump();
          }
          await tester.pump(const Duration(minutes: 6));
          await tester.pump();
          expect(
            service.checks,
            1,
            reason: 'no timer polling or dialog-close check',
          );
          unawaited(
            nav.currentState!.push(
              MaterialPageRoute<void>(builder: (_) => const Scaffold()),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
          nav.currentState!.pop();
          await tester.pump();
          await tester.pump(const Duration(seconds: 11));
          await tester.pump();
          expect(
            service.checks,
            2,
            reason: 'every real reentry refreshes even the same version',
          );
          if (scenario == 'idle') {
            expect(
              find.byKey(const ValueKey('ota-confirmation-frame')),
              findsOneWidget,
            );
            nav.currentState!.pop();
            await tester.pump();
          }
          expect(
            service.downloads,
            0,
            reason: 'no automatic download without confirmation',
          );
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();
          controller.dispose();
          if (Get.isRegistered<AppHeaderClockController>()) {
            Get.find<AppHeaderClockController>().onClose();
          }
          Get.reset();
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        },
      );
    }
  }
}
