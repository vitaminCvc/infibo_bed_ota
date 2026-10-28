# OTA 服务器与发布说明

## 现在完成的范围

客户端包含软件 APK 更新和 IMMORTAL 主控板固件升级。两个渠道分别打包，原来的 USB APK 项目继续保留。没有部署服务器，也没有执行实机升级。

## 填写服务器地址

复制根目录 `ota_release_config.example.json` 为 `ota_release_config.json`，填写两个独立 manifest 地址。共用打包工具勾选「官方版 OTA」和「国内测试版 OTA」时，会读取这个文件并分别编译渠道与 URL。空地址保留「尚未配置升级服务器」，不会请求猜测的接口。

```json
{
  "official": { "manifest_url": "https://你的正式域名/ota/official.json", "allow_http": false },
  "china_test": { "manifest_url": "https://你的测试域名/ota/china-test.json", "allow_http": false }
}
```

上述地址仅为格式示例。默认 HTTPS。仅内部测试时可显式开启 allow_http；正式发布保持 false。下载链接应直接返回文件和 HTTP 200，客户端拒绝重定向，以防协议降级或错误下载目标。

## Manifest 格式（schema 1）

下面是结构示例，APK 大小与 hash 必须按实际文件生成，不能照抄。

```json
{
  "schema": 1,
  "channel": "official",
  "app": {
    "package_name": "com.infibo.app.global",
    "version": "1.1.0",
    "version_code": 2,
    "url": "https://你的域名/Infibo_official_ota.apk",
    "size": 123456,
    "sha256": "替换为实际文件的64位SHA256",
    "notes": "本次更新说明"
  },
  "firmware": {
    "product": "Immortal-Main-Board",
    "version": "1.2.5",
    "firmware_register": "0x0125",
    "file": "Immortal-Main-v1_2_5_APP_OTA.bin",
    "url": "https://你的域名/Immortal-Main-v1_2_5_APP_OTA.bin",
    "size": 27492,
    "crc32": "0x2F599FDA",
    "sha256": "37f619dadcff160ff86379cb1bb9759431d24ff86e18f33fb2b191a806a2a90e",
    "notes": "主板更新说明"
  }
}
```

国内测试版 channel 必须是 china_test。两种 APK 包名相同，但下载文件和 manifest 分开。app 或 firmware 可省略，表示该渠道暂未发布对应更新。

服务器返回管理员指定的 APK 和主板固件，不按版本号大小选择。Android APK 只在内部编号高于当前已安装编号时提供更新，取消回退尝试入口，保留包名和签名校验。新打包的编号继续递增，相同编号不反复提醒或提供重新下载。主板固件允许管理员指定同版本重装或降级，用户手动确认后安装；相同版本不会反复自动提醒。固件接受任意 .bin 文件名，实际内容仍须为兼容主板的应用镜像；版本由管理员另行声明，校验实际大小/SHA256/CRC32 和向量基本格式；旧主板另按旧方案读取 APP_BASE、MAX_SIZE 和协议版本，新主板按 V1.3.0 方案使用已定义寄存器。

## 生成发布元数据

`tool/ota/New-OtaManifest.ps1` 从 APK 的实际包名/版本编号与文件哈希生成 JSON；可同时加入固件。它只生成本地文件，不会上传或部署。

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tool\ota\New-OtaManifest.ps1 -Channel official -ApkPath 'D:\APK\Infibo_official_ota.apk' -AppUrl 'https://实际域名/Infibo_official_ota.apk' -OutputFile '.\release\official-manifest.json' -Notes '更新说明'
```

固件可增加 `-FirmwarePath`、`-FirmwareUrl`、`-FirmwareVersion '1.2.5'`。生成后先上传 APK/bin，再发布 manifest；保持下载文件不可变，避免下载到不同内容。

## 安装与实机联调

1. 采用本次取消回退入口的流程，需要重新打包更高 version_code 并覆盖安装一次。后续只从软件内安装更高编号更新。
2. 新旧 APK 的包名和签名必须兼容。当前项目沿用已有 debug 签名配置，部署前与设备上实际 APK 核对；不要直接换新签名后期待覆盖升级。
3. 本版采用安卓用户确认安装，Android 8+ 可能需要允许安装来源。软件调用安装程序不等于安装成功，重启后读取真实版本确认。
4. 当前仅在系统状态寄存器 0x0006 为 0 时升级。升级前读取当前主板版本 0x0002：<= 0x0125 使用旧 OTA 基址 0x0300，>= 0x0130 使用新基址 0x0380，0x0126～0x012F 拒绝升级。基址按当前主板版本选择，并锁定整个传输（包括失败后的 ABORT），不能按目标固件版本选择；因此 1.2.5 首次升到 1.3.0 全程仍用旧地址。
5. 主板 bin 必须是厂家提供、适配该主板的应用固件镜像（文件名任意 .bin），首向量和复位向量满足 Cortex-M 应用格式。旧主板另检查复位向量位于主板返回的 APP_BASE 范围。V1.3.0 文档未提供远程查询 Flash 布局的寄存器，不能凭空推导查询地址；发布者仍需核对固件型号与厂家提供的文件。
6. 下载与传输可以取消；主板已经重启安装后不能取消。安装结果未确认时保持供电、重新检查版本，不误报成功。
7. 尚未完成真实服务器、屏幕安装权限、已部署 APK 签名、真实主板和断电恢复测试。模拟通过不替代这些验证。

### V1.3.0 方案核对与更正（2026-10-20）

旧版说明明确规定 APP_BASE、MAX_SIZE、OTA_PROTOCOL_VERSION 位于 0x0311～0x0315，协议版本为 1。这些检查仅适用于当前版本 <= 0x0125 的旧主板。

用户提供的 `ANDROID_SCREEN_OTA_IMPLEMENTATION_GUIDE(1).md` 没有定义 0x0391～0x0395，也没有要求查询协议号才能升级。此前按旧偏移推导这些地址并要求 0x0395=1 是实现错误，已删除这个前置条件。新主板只访问文档定义的 0x0380～0x0390、0x03A0～0x03DF，以及既有系统状态 0x0006、版本 0x0002；不查询旧能力区、不试写旧 OTA/WBVV 区。

新主板仍校验文件实际长度、SHA256、CRC32、向量基本格式；按 BEGIN 返回状态、每包错误/进度、FINISH 校验就绪及重启后的真实版本判断结果。文件大小是否适配主板由接收端按方案处理；由于文档未提供新能力查询，客户端不宣称已独立核对新主板的 Flash 地址/容量。模拟器故意对新地址 0x0391～0x039F 的读取返回非法地址，以防回归测试掩盖这种错误。

### 管理员指定目标与同版本重装（2026-10-20）

主板允许同版本及降级请求，不伪造 image version、文件名或校验值。地址仍按安装前运行的主板版本锁定，降级 1.3.0→1.2.5 也必须全程使用新地址，重启后才读取真实目标版本。同版本回读无法区分成功重刷和旧程序继续运行，因此返回“传输和校验完成，主板响应相同版本；尚不能独立确认实际重装”，不宣称已证明安装成功。真实接收端和 Bootloader 的行为仍需实板验收。

## 局域网联调（2026-10-20）

- 当前电脑 WLAN 为 192.168.1.85，rk3568 为 192.168.1.96。ota-dev 后端监听 0.0.0.0:8080，下载前缀改为 http://192.168.1.85:8080/ota/files/；管理网页仍可从电脑本机使用。
- Windows 新建 Infibo-Ota-Lan-Rk3568-8080 入站规则，Private 网络、WLAN 2、JDK17 java.exe、本地 192.168.1.85:8080、远端 192.168.1.96。没有关闭防火墙或新增公网部署。
- Flutter 根目录 ota_release_config.json 的 china_test 清单地址改为 http://192.168.1.85:8080/ota/china-test.json，allow_http=true。VS Code 新增“Infibo 国内测试 OTA（局域网）”启动配置，携带相同渠道、地址、HTTP 参数；普通无参数运行仍不会读取打包 JSON。
- 新包为 release/lan-ota-20261020/Infibo_china_test_ota_v1.0.14_build10_20261020_153034.apk。签名与原安装包一致，aapt2 确认 com.infibo.app.global / 1.0.14 / Build 10；已用 adb install -r 覆盖安卓屏，没有卸载或清数据。设备 PackageManager 与实际 APK SHA256 均核对一致。
- 已移除 USB 的 tcp:8080 reverse。安卓屏通过 Wi-Fi 直接请求电脑清单得到 HTTP 200，并完整下载现有 APK 243211067 字节、固件 30372 字节，设备端 SHA256 均匹配清单。App 系统更新页实际显示已发布的 App 1.0.9、固件 1.3.0，不再报服务器未配置或连接失败。
- 本轮没有发布、下架或修改原有版本记录，没有点击主板安装按钮、没有刷写固件。蓝牙未连接提示仅使用既有“跳过”按钮关闭，没有修改蓝牙设置。
- 最后请用户物理拔掉 USB 后再点一次“检查更新”；该物理步骤尚未由本轮工具验证。上述网络验证已在 USB 转发关闭后完成。电脑需保持后端运行，两台设备需留在同一局域网。
- 电脑或安卓屏地址变化时，同步更新后端下载前缀、App 打包/调试地址、防火墙规则。当前发布 APK 为 Build 3，屏上已是 Build 10，因此不会提示安装较旧 APK；后续正常 App 升级须使用大于 10 的编号。
- 配置备份、旧 APK、下载校验、设备截图和 verification.json：C:/Users/Administrator/Documents/infibo_v1/outputs/ota-lan-20261020。

## 云端 HTTPS 使用方式（2026-10-20）

打包工具从项目根目录 ota_release_config.json 读取两渠道的 api.infibo.net HTTPS 清单地址。VS Code 调试请显式选择“Infibo 国内测试 OTA（云服务器 HTTPS）”；不带 OTA_MANIFEST_URL 的普通 flutter run 依然不会自动读取 JSON。

云端管理网页需要先在电脑执行后端 deploy/ota/Open-OtaAdmin.ps1，保持 SSH 窗口打开，浏览器访问 http://127.0.0.1:15174/。原5174网页连接本地开发库，两个管理入口的数据不同；本次迁移后不会自动双向同步。生产发布应使用云端管理入口。

新 HTTPS APK 为1.0.17/Build13，必须安装这个包或之后按云端配置打出的包，设备才会使用公网地址。云端当前发布仍为1.0.16/Build12，没有自动切换到13。显示名称今后可用1.0.0，Build继续递增，避免覆盖安装被Android拒绝。
