import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infibo_app/api/modbus/modbus_rtu_service.dart';
import 'package:infibo_app/components/water_quality/water_quality_controller.dart';
import 'package:infibo_app/components/water_quality/water_quality_host.dart';
import 'package:infibo_app/pages/main/ui.dart';
import 'package:infibo_app/routes/route_observer.dart';
import 'package:infibo_app/stores/app_header_clock_store.dart';
import 'package:infibo_app/stores/user_store.dart';
import 'package:infibo_app/translation/app_translations.dart';

class HomeDevice extends ModbusRtuService {
  final reads = <int>[];
  @override
  Future<int> readHoldingRegister(int address) async {
    reads.add(address);
    if (address == 0x01EC) return 10;
    if (address == 0x01ED) return 2;
    return 0;
  }

  @override
  Future<void> sendCommandQueue(List<ModbusWriteCommand> commands) async {}
}

void main() {
  testWidgets('real home reads EC after light status water and opens failure', (
    tester,
  ) async {
    Get.testMode = true;
    Get.put(UserStore());
    final device = HomeDevice();
    final controller = WaterQualityController(
      readRegister: device.readHoldingRegister,
    );
    addTearDown(() {
      controller.dispose();
      if (Get.isRegistered<AppHeaderClockController>()) {
        Get.find<AppHeaderClockController>().onClose();
        Get.delete<AppHeaderClockController>(force: true);
      }
      Get.reset();
    });
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/main',
        locale: const Locale('zh', 'CN'),
        translations: AppTranslations(),
        navigatorObservers: [
          appRouteObserver,
          WaterQualityRouteObserver(controller),
        ],
        builder: (context, child) =>
            WaterQualityHost(controller: controller, child: child!),
        getPages: [
          GetPage(
            name: '/main',
            page: () => MainPage(modbusService: device),
          ),
        ],
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));
    expect(device.reads.take(5).toList(), [
      0x0012,
      0x0006,
      0x01E5,
      0x01EC,
      0x01ED,
    ]);
    expect(find.text('水质处理失败'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    if (Get.isRegistered<AppHeaderClockController>()) {
      Get.find<AppHeaderClockController>().onClose();
    }
  });
}
