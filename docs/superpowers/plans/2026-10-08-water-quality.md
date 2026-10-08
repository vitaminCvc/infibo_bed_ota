# 分子氢水质检测 Implementation Plan

> **For agentic workers:** Use superpowers:executing-plans to implement this plan task by task in the current checkout. Steps use checkbox syntax for tracking.

**Goal:** 实现用户确认的水质异常全局弹窗及处理跟踪。

**Architecture:** 独立 ChangeNotifier 控制器管理异常轮次、页面访问和串行读取；应用根部 Host 管理前台轮询及浮层，PageRoute observer 只识别真实页面导航。首页在原水位读取结束后触发水质读取；启动、继续及阶段切换前复测，并过滤不允许启用的分子氢命令。

**Tech Stack:** Flutter、Dart、GetX、现有 Modbus RTU，无新增依赖。

**Spec:** ../specs/2026-10-08-water-quality-interaction-and-function-spec.md

## Global Constraints

- TDS ≥ 10 触发弹窗，出现后才读 0x01ED；关闭不停止本轮跟踪。
- 0=成功，1=处理中，2=失败；0 且最新 TDS < 10 才结束异常。
- 页面跳转保留浮层；真实进入首页或启动页才重新提醒，PopupRoute 不算页面访问。
- 下位机控制处理、两分钟超时及输出；App 不额外启动、停止或重试处理。
- 保留项目原有未提交改动，在用户指定目录实现，不复制或重置现有修改。

## Review Focus

- 待读取响应期间关闭或换页，不得重开旧弹窗。
- 首页灯光、系统状态、水位读取顺序不能被首个 TDS 读取打断。
- 显示成功后出现新异常，复用浮层并重新跟踪。
- 读取失败或未定义状态不能被转换为成功。
- 关闭浮层及系统返回键不能误退出运行页。

## Task 1 控制器

Files: lib/components/water_quality/water_quality_controller.dart; test/water_quality_controller_test.dart.

Interfaces: enterPage(String, {bool deferRead}); onHomeWaterPollComplete(); poll(); checkHydrogenBeforeCommand(); dismiss(); phase、visible、episodeActive、canUseHydrogen、readError。

- [x] 写阈值、延迟 ED 读取、关闭后台跟踪、跨页面重新提醒、恢复和新异常、失败响应及异步竞态测试。
- [x] 运行 flutter test test/water_quality_controller_test.dart，确认功能缺失导致失败。
- [x] 实现串行读取及异常轮次状态机。
- [x] 同一命令验证测试通过。

## Task 2 全局浮层与页面接入

Files: lib/components/water_quality/water_quality_dialog.dart; water_quality_host.dart; lib/routes/index.dart; lib/pages/main/ui.dart; lib/translation/app_translations.dart; test/water_quality_widget_test.dart.

Interfaces: WaterQualityHost(controller, child); WaterQualityScope.maybeOf(context); WaterQualityRouteObserver(controller)。

- [x] 写跨 start → summary → main 保留、关闭不退页、PopupRoute 不重复提醒及长文案布局测试。
- [x] 运行测试确认失败，再实现根部浮层、真实页面 observer、关闭守卫和十种语言文案。
- [x] 首页原水位读取结束后调用 onHomeWaterPollComplete，保证已有顺序。
- [x] 验证新增 widget 测试和首页时序回归。

## Task 3 分子氢命令保护与整体验证

Files: lib/api/modbus/hydrogen_modbus.dart; lib/pages/start/ui.dart; test/water_quality_command_guard_test.dart.

Interfaces: 控制器读取函数复用 ModbusRtuService.readHoldingRegister；命令保护保留其他模块及停止指令，阻止分子氢启动、继续、使能及功率修改。

- [x] 写保护测试，证明水质不可用时其他模块仍可发送、分子氢停止仍允许。
- [x] 实现启动、继续、阶段切换前的新读取及发送前最终检查。
- [x] flutter test 全套；flutter analyze；flutter build apk --debug --target lib/main.dart（当前默认 global 入口）。
- [x] 审查本次 diff 与新文件，保留工作区供用户查看，不自动提交或发布。

## Final Verification — 2026-10-08

- 新增测试 32 项全部通过；与首页时序、启动和停止回归一起执行，53 项全部通过。
- 全套测试：253 通过、1 跳过、12 失败。开始实现前为 221 通过、1 跳过、12 失败；逐项比较后失败列表一致，无新增失败。
- 原有失败涉及品牌配置、添加用户字体、设备信息布局、预设参数、国际化及蓝牙连接判定，未扩大本次修改范围。
- flutter analyze：0 error，28 项原有 warning/info；新增 water_quality 文件无诊断。
- flutter build apk --debug --target lib/main.dart：成功，默认 global 调试版。
- 安装包：build/app/outputs/flutter-apk/infibo-water-quality-global-debug.apk。
- git diff --check：通过。独立只读审查已完成，发现的异步关闭、首页延迟读取和阶段参数重放问题已修复，无剩余实质问题。
- 在已有非主分支工作区实现；保留原有代码改动，不自动提交、推送或发布。Flutter 构建生成文件随构建自动更新。
- 本次为模拟寄存器和页面自动化验证，未连接真实下位机；实际通信、处理超时与恢复输出需上机联调。
