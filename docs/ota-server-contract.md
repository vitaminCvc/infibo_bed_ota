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

软件按 version_code 比较，不按文件名或展示文字比较；每次正式更新都递增内部编号。主板以寄存器编码比较，拒绝降级。固件只接受 APP_OTA.bin，校验大小/SHA256/CRC32，以及主板 APP_BASE、MAX_SIZE 和协议版本。

## 生成发布元数据

`tool/ota/New-OtaManifest.ps1` 从 APK 的实际包名/版本编号与文件哈希生成 JSON；可同时加入固件。它只生成本地文件，不会上传或部署。

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tool\ota\New-OtaManifest.ps1 -Channel official -ApkPath 'D:\APK\Infibo_official_ota.apk' -AppUrl 'https://实际域名/Infibo_official_ota.apk' -OutputFile '.\release\official-manifest.json' -Notes '更新说明'
```

固件可增加 `-FirmwarePath`、`-FirmwareUrl`、`-FirmwareVersion '1.2.5'`。生成后先上传 APK/bin，再发布 manifest；保持下载文件不可变，避免下载到不同内容。

## 安装与实机联调

1. 第一个包含 OTA 功能的 APK 仍使用 U 盘安装。之后更高 version_code 的 APK 才能从软件内更新。
2. 新旧 APK 的包名和签名必须兼容。当前项目沿用已有 debug 签名配置，部署前与设备上实际 APK 核对；不要直接换新签名后期待覆盖升级。
3. 本版采用安卓用户确认安装，Android 8+ 可能需要允许安装来源。软件调用安装程序不等于安装成功，重启后读取真实版本确认。
4. 当前仅在系统状态寄存器 0x0006 为 0 时升级，OTA 协议版本寄存器 0x0315 必须为 1。这两项须与硬件团队再次核对；未知状态拒绝烧写。
5. 主板 bin 必须链接到主板返回的 APP_BASE，首向量和复位向量满足 Cortex-M 应用格式。不是工厂 HEX 或 Bootloader 文件。
6. 下载与传输可以取消；主板已经重启安装后不能取消。安装结果未确认时保持供电、重新检查版本，不误报成功。
7. 尚未完成真实服务器、屏幕安装权限、已部署 APK 签名、真实主板和断电恢复测试。模拟通过不替代这些验证。
