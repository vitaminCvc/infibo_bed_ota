# 升降状态同步验证（2026-10-28）

## 改动范围

- `lib/pages/joystick/ui.dart`：统一 0～4 状态映射，500ms 持续轮询，路由暂停恢复，过期响应保护，本地手势独立记录。按用户截图后的明确补充要求，读取 0x0010，与 0x0011 不一致时实际回写，相等不重发。
- `lib/pages/main/ui.dart`：升降轮询先等待既有首页设备读取周期，慢响应也保留 0x0012 → 0x0006 → 0x01E5 的提交顺序。
- `lib/pages/start/ui.dart`：允许注入 Modbus 服务，用真实启动页验证共用组件；升降命令在发起时保存版本，排队发送前、确认后与后台状态读取后均校验版本。
- 三处控制入口共用串行写队列，校正写在途时用户操作不会丢失；松手撤销排队移动，停止仍发送。主动停止后，未收到停止反馈前，不用旧运动反馈重新启动。

## 验证结果

- 组件 26 项、两页集成 5 项。覆盖 4 → 3 → 2 → 1 → 0、停止后新动作、反馈纠正方向、读失败及未知值、慢读取、页面覆盖和返回、松手停止、第二触点、在途写入停止、慢速首页首读。
- 回写验证采用独立的状态和控制寄存器，截图中的 0x0011=3、0x0010=4 在旧实现下测试失败；修复后控制值变为 3，后续一致时不再写。覆盖 0～4 全部状态、读控制失败恢复、写失败重试、排队校正期间的新操作及松手、旧后台零反馈不能清除新停止保护、上升确认前停止使旧任务失效。
- 专项回归命令：`flutter test test/joystick_status_sync_test.dart test/lift_pages_status_sync_test.dart test/lift_current_test.dart test/start_lift_sequence_test.dart test/start_stop_sequence_test.dart test/main_modbus_send_order_test.dart test/main_startup_polling_test.dart test/water_quality_home_integration_test.dart --reporter expanded`。
- 专项回归结果：55 项全部通过。
- 完整 `flutter test --reporter expanded`：563 通过，9 跳过，17 失败。失败名称与修改前对照完全一致，无新增失败。
- 对照方法：在临时副本保留其他既有工作区文件，仅用 Git index 中本次修改前的 `joystick/ui.dart` 和 `start/ui.dart` 替换对应文件；副本创建于首页新增接入前。运行上述失败涉及的 9 个测试文件，重现同一组 17 项失败。
- 静态分析：共用组件和新增/更新测试无新增问题；启动页原有 `_designHeight`、`concentrationText` 未使用警告仍在。
- 独立代码审查及修复后复核通过。未做实机验证，未安装或发布。

## 修改前后均存在的失败

| 文件 | 测试名称 |
| --- | --- |
| app_brand_test.dart | AppBrands provides the exact configuration for every flavor |
| choseusers_popup_background_test.dart | all add-user popup text uses 18px font size |
| device_info_panel_test.dart | device information panel uses English content and scrolls |
| manual_app_install_test.dart | older published APK shows actual build codes without a rollback action |
| manual_firmware_install_test.dart | manual target 304 has a clear confirmation that can be cancelled |
| preset_configs_test.dart | preset identifiers and corrected parameters match the source table |
| uae_logo_size_test.dart | UAE device preserves full SVG dimensions |
| uae_logo_size_test.dart | UAE home preserves full SVG dimensions |
| uae_logo_size_test.dart | UAE settings preserves full SVG dimensions |
| widget_test.dart | Chinese backend messages use translated fallback outside Chinese |
| widget_test.dart | gender values are localized for the current language |
| widget_test.dart | mode card header places icon and translated title in one row |
| widget_test.dart | mode card title keeps its default position in English |
| wifi_bluetooth_system_gateway_test.dart | Android accepts an Inmortal A2DP or headset connection |
| wifi_bluetooth_system_gateway_test.dart | fresh Android permission is granted before Bluetooth devices are read |
| wifi_bluetooth_system_gateway_test.dart | non-Android platforms use the GATT snapshot only |
| wifi_bluetooth_system_gateway_test.dart | returns the real name of the first matching Bluetooth device |
