# OTA Updates Implementation Plan

> For agentic workers: use superpowers:executing-plans task by task. 用户明确授权本会话自主分步实施，无需逐项等待回复。

**Goal:** 为 infibo_ota 接入软件更新与主板升级的客户端流程。
**Architecture:** 可测试的数据与下载服务、Android 安装网关、独立主板状态机、共用更新页面。
**Tech Stack:** Flutter/Dart/GetX/Dio/crypto/Kotlin/Modbus RTU。
**Spec:** docs/superpowers/specs/2026-10-14-ota-design.md

## Global Constraints
- 只改 OTA 副本的应用代码；共用打包工具新增 OTA 编译参数。
- 官方/国内测试渠道明确分离。默认 HTTPS；未配置服务不猜测地址。
- 用户确认安装，设备运行期间禁止安装或烧写。
- 不上传文件、不部署服务器、不在设备上执行真实升级。

## Review Focus
- 错渠道/错包名/版本回退均拒绝。
- 下载取消或校验失败不得触发安装。
- 安装授权页面返回不能误报升级成功。
- 主板 WRITE 已执行但回复丢失时不可重复提交。
- 重启安装后串口无应答保持待确认，失败必须恢复屏幕与串口使用权。

### Task 1: 共用打包工具（已完成）
- [x] 新增两项跨项目打包并验证项目目录、版本号、保存目录。

### Task 2: 版本检查数据契约
Files: lib/ota/ota_manifest.dart, lib/ota/ota_config.dart, test/ota_manifest_test.dart。
Interfaces: OtaManifest.parse(json, channel, packageName, allowHttp); AppRelease.isNewerThan(installedCode); FirmwareRelease；OtaConfig。
- [x] 写错渠道、错包名、旧版本、非法 URL/尺寸/hash 的测试并观察失败。
- [x] 实现严格解析和安全 URL 配置。
- [x] 运行定向测试，记录结果。

### Task 3: 软件下载与安装网关
Files: lib/ota/ota_service.dart, lib/ota/android_update_gateway.dart, AndroidUpdateBridge.kt, AndroidManifest.xml, res/xml/ota_file_paths.xml, test/ota_service_test.dart。
Interfaces: query()/download()/cancel()/install()；真实已安装版本与缓存目录来自 Android。
- [x] 写下载长度/hash/取消/失败不安装的测试并观察失败。
- [x] 实现受限下载、校验、PackageInstaller 用户确认入口和安装权限引导。
- [x] 测试并核对 Android 文件 URI、包名与版本号验证。

### Task 4: 系统更新页面与提示
Files: lib/pages/settingpage/system_update_panel.dart, lib/ota/ota_controller.dart, settingpage/ui.dart, translations, main/ui.dart。
- [x] 测试未配置、无更新、有更新、错误、忙碌、确认取消等页面状态。
- [x] 沿用设置样式；显示真实版本、说明、下载/安装阶段，首页空闲检查并每会话提醒一次。
- [x] 防止在运行页面打断治疗与安装。

### Task 5: 主板 OTA
Files: lib/ota/firmware_ota_service.dart, lib/ota/modbus_ota_transport.dart, android_serial_port_service.dart, test/firmware_ota_service_test.dart。
- [x] 以模拟传输测试分包、CRC、奇数末包、丢 ACK、状态/进度错误、复位超时。
- [x] 实现独占串口、状态检查、重试与复位版本验证，再接入更新页面。
- [x] 确认取消/异常恢复资源，重启阶段不能错误重发或取消。

### Task 6: 验证和交付
- [x] 运行完整 Flutter 测试并与原项目对照（相同 12 项基线失败）、33 项新增测试通过、定向分析通过、两个真实 Android APK 编译通过。
- [x] 人工全流程检查并修复重要问题；独立 OTA 审查因额度不足未完成，限制已记录。
- [x] 更新 docs/ota-progress.md、服务器 manifest 示例与发布/实机验证说明。
