# OTA 更新设计

用户授权：在 infibo_ota 副本中自主、逐任务实施，每完成任务记录交付和验证。仅官方版和国内测试版发布 OTA；旧项目仅维护共用打包工具。采用现有设置页样式，新增「系统更新」，分别展示上位机软件和主板固件。

## 软件更新

运行时从 Android 读取实际包名、versionName、versionCode。服务器地址通过 OTA_MANIFEST_URL 编译参数配置，渠道通过 OTA_CHANNEL 指定 official 或 china_test；未配置时明确显示服务尚未配置，不请求猜测的接口，不显示虚假版本。默认只接受 HTTPS，HTTP 仅可用显式测试参数启用。

Manifest schema=1，channel 必须等于当前渠道。app 可为空；非空时包含 version、version_code、package_name、url、size、sha256、notes。package_name 必须等于安装应用，只有 version_code 大于已安装值才可更新。下载到 Android 私有缓存目录，限制最多 512 MiB，验证实际长度和 SHA256，通过后才交给安卓系统安装。拒绝损坏包、错包名、重复点击、运行期间安装。采用用户确认安装，不承诺静默升级。

APK 安装通过 FileProvider 内容 URI，Android 8+ 无安装授权时引导系统设置，返回后用户再次操作；安装过程取消不能报告成功。下次启动读取实际版本确认，不修改本地业务数据。

## 主板更新

firmware 包含 product=Immortal-Main-Board、version、firmware_register、url、size、sha256、crc32、notes。沿用提供的 RS232/Modbus OTA 协议；文件为 APP_OTA.bin。读取实际版本、协议版本和 MAX_SIZE；仅空闲设备升级。传输期间独占串口并阻止导航和重复升级，状态、进度确认优先于重复提交 WRITE。FINISH ready 后再 REBOOT，复位无应答视为待确认；最终读到目标版本才成功。

UI 传输 100% 与升级成功是不同阶段；网络、校验、硬件状态失败须给出明确信息。未知安装结果保留说明，不自动 ABORT 已重启设备。安装断电恢复依赖已验证的 Bootloader，客户端无法替代。

## 测试及边界

先测试 manifest、渠道与版本判断，再测下载和安装网关，再测 UI 和主板协议。使用模拟服务覆盖错误、取消、短包、奇数末包、丢应答和超时。完成后运行 Flutter 测试及 Android 编译。真实服务器接口、APK 签名、屏幕安装权限和真实主板升级最终需设备联调，日志和进度文档明确区分模拟验证与实机验证。
