import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infibo_app/api/modbus/modbus_rtu_service.dart';
import 'package:infibo_app/components/designCanvas/design.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/constants/layout.dart';
import 'package:infibo_app/pages/joystick/ui.dart';
import 'package:infibo_app/pages/main/ui.dart';
import 'package:infibo_app/pages/start/ui.dart';
import 'package:infibo_app/routes/route_observer.dart';
import 'package:infibo_app/stores/app_header_clock_store.dart';
import 'package:infibo_app/stores/user_store.dart';
import 'package:infibo_app/translation/app_translations.dart';

class PageLiftService extends ModbusRtuService {
  int liftStatus = 4;
  int liftControl = 4;
  Completer<int>? pendingLight;
  Completer<int>? pendingDevice;
  final reads = <int>[];
  final writes = <ModbusWriteCommand>[];

  @override
  Future<int> readHoldingRegister(int address) async {
    reads.add(address);
    if (address == 0x0012 && pendingLight != null) return pendingLight!.future;
    if (address == 0x0006 && pendingDevice != null) {
      return pendingDevice!.future;
    }
    if (address == 0x0011) return liftStatus;
    if (address == 0x0010) return liftControl;
    if (address == 0x01E5) return 2;
    return 0;
  }

  @override
  Future<void> sendCommandQueue(List<ModbusWriteCommand> commands) async {
    writes.addAll(commands);
    for (final command in commands) {
      if (command.address == 0x0010) liftControl = command.value;
    }
  }
}

void main() {
  testWidgets(
    'home waits for slow light and device reads before lift polling',
    (tester) async {
      Get.testMode = true;
      Get.put(UserStore());
      JoystickCommandBus.instance.reset();
      addTearDown(() => Get.reset());
      final light = Completer<int>();
      final device = Completer<int>();
      final service = PageLiftService()
        ..pendingLight = light
        ..pendingDevice = device;
      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('zh', 'CN'),
          navigatorObservers: [appRouteObserver],
          home: MainPage(modbusService: service),
        ),
      );
      await tester.pump(const Duration(milliseconds: 600));
      expect(service.reads, [0x0012]);
      light.complete(0);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(service.reads, [0x0012, 0x0006]);
      device.complete(0);
      await tester.pump();
      await tester.pump();
      expect(service.reads, [0x0012, 0x0006, 0x01E5, 0x0011, 0x0010]);
      await tester.pumpWidget(const SizedBox());
      if (Get.isRegistered<AppHeaderClockController>()) {
        Get.find<AppHeaderClockController>().onClose();
      }
    },
  );

  for (final layout in [AppLayout.ratio16x10, AppLayout.ratio16x9]) {
    for (final startPage in [false, true]) {
      testWidgets(
        '${startPage ? 'start' : 'home'} lift reflects device status ${layout.profile}',
        (tester) async {
          Get.testMode = true;
          Get.put(UserStore());
          JoystickCommandBus.instance.reset();
          tester.view.physicalSize = layout.designSize;
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
          final service = PageLiftService();
          await tester.pumpWidget(
            GetMaterialApp(
              translations: AppTranslations(),
              locale: const Locale('zh', 'CN'),
              navigatorObservers: [appRouteObserver],
              home: AppLayoutScope(
                layout: layout,
                child: startPage
                    ? StartPage(modbusService: service)
                    : MainPage(modbusService: service),
              ),
            ),
          );
          final joystick = find.byType(JoystickControl);
          for (final (status, asset) in [
            (4, Assets.joystickLeftBottom),
            (3, Assets.joystickLeftTop),
            (2, Assets.joystickRightBottom),
            (1, Assets.joystickRightTop),
          ]) {
            service.liftStatus = status;
            await tester.pump(const Duration(milliseconds: 500));
            await tester.pump();
            expect(
              find.descendant(
                of: joystick,
                matching: find.byWidgetPredicate(
                  (widget) =>
                      widget is Image && widget.image == AssetImage(asset),
                ),
              ),
              findsOneWidget,
              reason: '0x0011=$status',
            );
            expect(service.liftControl, status);
          }
          service.liftStatus = 0;
          await tester.pump(const Duration(milliseconds: 500));
          await tester.pump();
          expect(
            find.descendant(of: joystick, matching: find.byType(Image)),
            findsOneWidget,
          );
          expect(
            service.writes
                .where((command) => command.address == 0x0010)
                .map((command) => command.value),
            [3, 2, 1, 0],
          );
          expect(service.liftControl, 0);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
          await tester.pump();
          if (Get.isRegistered<AppHeaderClockController>()) {
            Get.find<AppHeaderClockController>().onClose();
          }
        },
      );
    }
  }
}
