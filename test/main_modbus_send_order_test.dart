// 首页 Modbus 读取时序回归测试。
//
// 背景（见《6.30日7.9现版本区别.docx》结论）：
//   6月30日 / 7月9日 版本首页发送顺序为 0x0012 → 0x0006 → 0x01E5；
//   现版本曾变成 0x0012 → 0x01E5 → 0x0006（0x01E5 与 0x0012 几乎同时发出，
//   0x0006 要等 0x0012 响应返回后才发出）。
// 本用例锁定修正后的顺序：0x0012 → 0x0006 → 0x01E5。
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infibo_app/api/modbus/modbus_rtu_service.dart';
import 'package:infibo_app/pages/main/ui.dart';
import 'package:infibo_app/routes/route_observer.dart';
import 'package:infibo_app/stores/app_header_clock_store.dart';
import 'package:infibo_app/stores/user_store.dart';
import 'package:infibo_app/translation/app_translations.dart';

/// 记录每次读取的寄存器地址，用于断言发送时序。
class _RecordingModbusService extends ModbusRtuService {
  final List<int> readAddresses = <int>[];

  @override
  Future<int> readHoldingRegister(int address) async {
    readAddresses.add(address);
    // 全部返回 0：氛围灯关闭、设备正常、水位不缺，避免弹窗干扰时序断言。
    return 0;
  }

  @override
  Future<void> sendCommandQueue(List<ModbusWriteCommand> commands) async {}
}

void main() {
  testWidgets('home page reads registers in order 0x0012 → 0x0006 → 0x01E5', (
    WidgetTester tester,
  ) async {
    Get.testMode = true;
    Get.put(UserStore());
    addTearDown(() {
      if (Get.isRegistered<AppHeaderClockController>()) {
        Get.delete<AppHeaderClockController>(force: true);
      }
      Get.reset();
    });

    final _RecordingModbusService service = _RecordingModbusService();
    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('zh', 'CN'),
        navigatorObservers: [appRouteObserver],
        home: MainPage(modbusService: service),
      ),
    );

    // 进入首页后的首个轮询周期：0x0012（氛围灯）→ 0x0006（设备状态）→ 0x01E5（水位）。
    await tester.pump(const Duration(milliseconds: 250));
    expect(service.readAddresses.take(3).toList(), <int>[
      0x0012,
      0x0006,
      0x01E5,
    ]);

    // 稳态下（0x0012/0x0006 每 5s、0x01E5 每 3s）同样不允许 0x01E5
    // 插在 0x0012 与 0x0006 之间。
    await tester.pump(const Duration(seconds: 16));
    bool pendingDeviceStatus = false;
    for (final int address in service.readAddresses) {
      if (address == 0x0012) {
        pendingDeviceStatus = true;
      } else if (address == 0x0006) {
        pendingDeviceStatus = false;
      } else if (address == 0x01E5) {
        expect(
          pendingDeviceStatus,
          isFalse,
          reason: '0x01E5 不得排在 0x0006 之前：${service.readAddresses}',
        );
      }
    }
    // 确认稳态期间确实跑过多轮设备状态轮询，断言才有意义。
    expect(
      service.readAddresses.where((int address) => address == 0x0012).length,
      greaterThanOrEqualTo(4),
    );

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    if (Get.isRegistered<AppHeaderClockController>()) {
      Get.find<AppHeaderClockController>().onClose();
      Get.delete<AppHeaderClockController>(force: true);
    }
  });
}
