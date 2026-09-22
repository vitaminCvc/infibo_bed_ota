import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infibo_app/api/modbus/modbus_rtu_service.dart';
import 'package:infibo_app/stores/app_header_clock_store.dart';
import 'package:infibo_app/components/designCanvas/design.dart';
import 'package:infibo_app/constants/layout.dart';
import 'package:infibo_app/pages/main/ui.dart';
import 'package:infibo_app/pages/joystick/ui.dart';
import 'package:infibo_app/stores/user_store.dart';
import 'package:infibo_app/translation/app_translations.dart';

class HomeCurrentService extends ModbusRtuService {
  int status = 1;
  bool failCurrent = false;
  int currentReads = 0;
  @override
  Future<int> readHoldingRegister(int address) async {
    if (address == 0x0011) return status;
    if (address == 0x0017) {
      currentReads++;
      if (failCurrent) throw StateError('read failed');
      return 21;
    }
    return 0;
  }

  @override
  Future<void> sendCommandQueue(List<ModbusWriteCommand> commands) async {}
}

void main() {
  for (final layout in [AppLayout.ratio16x10, AppLayout.ratio16x9]) {
    testWidgets('home current display ${layout.profile}', (tester) async {
      Get.testMode = true;
      Get.put(UserStore());
      tester.view.physicalSize = layout.designSize;
      tester.view.devicePixelRatio = 1;
      JoystickCommandBus.instance.reset();
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
        Get.reset();
      });
      final service = HomeCurrentService();
      await tester.pumpWidget(
        GetMaterialApp(
          translations: AppTranslations(),
          locale: const Locale('zh', 'CN'),
          home: AppLayoutScope(
            layout: layout,
            child: MainPage(modbusService: service),
          ),
        ),
      );
      await tester.pump();
      // 电流功能停用后，首页不再显示或读取电流。
      expect(find.textContaining('电流 0x0017'), findsNothing);
      JoystickCommandBus.instance.lockLeftBottom();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      /* 原电流显示测试暂时停用。
      expect(find.text('电流 0x0017：21'), findsOneWidget);
      service.failCurrent = true;
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      expect(find.text('电流 0x0017：读取失败'), findsOneWidget);
      service.failCurrent = false;
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump();
      service.status = 0;
      await tester.pump(const Duration(milliseconds: 500));
      final count = service.currentReads;
      await tester.pump(const Duration(seconds: 1));
      expect(service.currentReads, count);
      expect(find.text('电流 0x0017：21'), findsOneWidget);
      */
      await tester.pump(const Duration(seconds: 1));
      expect(service.currentReads, 0);
      expect(find.textContaining('电流 0x0017'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      if (Get.isRegistered<AppHeaderClockController>()) {
        Get.find<AppHeaderClockController>().onClose();
        Get.delete<AppHeaderClockController>(force: true);
      }
    });
  }
}
