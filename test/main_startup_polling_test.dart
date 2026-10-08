import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infibo_app/api/modbus/modbus_rtu_service.dart';
import 'package:infibo_app/components/water_level_state_dialog.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/pages/WifiBluetooth/connection_prompt_controller.dart';
import 'package:infibo_app/pages/WifiBluetooth/connection_prompt_dialog.dart';
import 'package:infibo_app/pages/WifiBluetooth/connection_prompt_host.dart';
import 'package:infibo_app/pages/WifiBluetooth/logic.dart';
import 'package:infibo_app/pages/main/ui.dart';
import 'package:infibo_app/routes/route_observer.dart';
import 'package:infibo_app/stores/app_header_clock_store.dart';
import 'package:infibo_app/stores/user_store.dart';
import 'package:infibo_app/translation/app_translations.dart';

class _StartupGateway implements ConnectionPromptGateway {
  final wifi = Completer<WifiConnectionStatus>();
  final ble = Completer<bool>();

  @override
  Stream<WifiConnectionStatus> get wifiStatusStream => const Stream.empty();
  @override
  Future<WifiConnectionStatus> readWifiStatus() => wifi.future;
  @override
  Future<bool> hasConnectedBleDevice() => ble.future;
  @override
  Future<void> openWifiSettings() async {}
  @override
  Future<void> openBluetoothSettings() async {}
}

class _StartupModbus extends ModbusRtuService {
  final reads = <int>[];
  int light = 0;
  int water = 2;

  @override
  Future<int> readHoldingRegister(int address) async {
    reads.add(address);
    if (address == 0x0012) return light;
    if (address == 0x01E5) return water;
    return 0;
  }

  @override
  Future<void> sendCommandQueue(List<ModbusWriteCommand> commands) async {}
}

void main() {
  for (final scenario in ['skipped', 'connected', 'covered by another page']) {
    testWidgets(
      'startup home resumes light and water checks after connection prompt '
      '$scenario',
      (tester) async {
        Get.testMode = true;
        Get.put(UserStore());
        tester.view.physicalSize = const Size(1200, 1600);
        tester.view.devicePixelRatio = 1;
        addTearDown(() {
          if (Get.isRegistered<AppHeaderClockController>()) {
            Get.find<AppHeaderClockController>().onClose();
            Get.delete<AppHeaderClockController>(force: true);
          }
          Get.reset();
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });
        final gateway = _StartupGateway();
        final service = _StartupModbus();
        final navigatorKey = GlobalKey<NavigatorState>();
        await tester.pumpWidget(
          GetMaterialApp(
            navigatorKey: navigatorKey,
            translations: AppTranslations(),
            locale: const Locale('zh', 'CN'),
            navigatorObservers: [appRouteObserver],
            initialRoute: '/main',
            getPages: [
              GetPage(
                name: '/main',
                page: () => MainPage(modbusService: service),
              ),
            ],
            builder: (context, child) => ConnectionPromptHost(
              navigatorKey: navigatorKey,
              gateway: gateway,
              child: child!,
            ),
          ),
        );
        await tester.pump();
        expect(find.byType(WifiBluetoothConnectionDialog), findsOneWidget);
        if (scenario == 'covered by another page') {
          unawaited(
            navigatorKey.currentState!.push<void>(
              MaterialPageRoute<void>(
                builder: (_) => const Scaffold(body: Text('another page')),
              ),
            ),
          );
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 350));
        }
        service.reads.clear();
        service.light = 1;
        service.water = 1;
        if (scenario == 'connected') {
          gateway.wifi.complete(WifiConnectionStatus.connected);
          gateway.ble.complete(true);
        } else {
          tester
              .widget<WifiBluetoothConnectionDialog>(
                find.byType(WifiBluetoothConnectionDialog),
              )
              .controller
              .skipForCurrentRun();
          gateway.wifi.complete(WifiConnectionStatus.disconnected);
          gateway.ble.complete(false);
        }
        await tester.pump();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 250));
        expect(find.byType(WifiBluetoothConnectionDialog), findsNothing);
        if (scenario == 'covered by another page') {
          expect(find.text('another page'), findsOneWidget);
          expect(service.reads, isEmpty);
          navigatorKey.currentState!.pop();
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 350));
        }
        expect(service.reads.take(3).toList(), [0x0012, 0x0006, 0x01E5]);
        expect(find.byType(WaterLevelStateDialog), findsOneWidget);
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Image &&
                widget.image is AssetImage &&
                (widget.image as AssetImage).assetName == Assets.lightOpenLogo,
          ),
          findsOneWidget,
        );
        // 缺水弹窗期间仍应持续检测水位。
        final waterReads = service.reads
            .where((address) => address == 0x01E5)
            .length;
        await tester.pump(const Duration(seconds: 3));
        expect(
          service.reads.where((address) => address == 0x01E5).length,
          greaterThan(waterReads),
        );
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        Get.find<AppHeaderClockController>().onClose();
      },
    );
  }
}
