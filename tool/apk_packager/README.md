# Infibo APK 打包工具

双击项目根目录的 `启动APK打包工具.cmd`。每个版本右侧都有自己的保存目录，可以直接修改，也可以点该行的“浏览...”选择文件夹。勾选版本后点“打包选中版本”；“一键打包全部”会按列表顺序打包所有版本，不受勾选状态影响，并把每个 APK 放进它自己的目录。窗口下方显示构建日志和结果。

每个版本的路径会记在 `%LOCALAPPDATA%\InfiboApkPackager\destinations.json`，下次打开会自动恢复。第一次使用时，各版本默认分别保存到 `下载\Infibo_APK\版本代号`。例如，可以把官方版设为桌面的 `理疗床v1.04\官方`，把国内测试版设为 `理疗床v1.04\国内测试版`。

工具在当前 Flutter 工程中执行 `flutter build apk --release`。每个 APK 成功生成后，立即从 `build/app/outputs/flutter-apk` 移到对应版本的目录。文件名含版本种类、`pubspec.yaml` 中的版本号和时间；同名时自动加序号，因此不会覆盖之前的 APK。某个版本构建失败时会停止后续构建，已经成功保存的 APK 会保留。

| 选项 | Flutter flavor | 入口文件 | API 地址 |
| --- | --- | --- | --- |
| 官方版 | global | `lib/main_global.dart` | `http://192.241.254.196` |
| 国内环境测试版 | global | `lib/main_global.dart` | `http://8.138.247.157` |
| 印度版 | india | `lib/main_india.dart` | `http://192.241.254.196` |
| 西班牙版 | spain | `lib/main_spain.dart` | `http://192.241.254.196` |
| 土耳其版 | turkey | `lib/main_turkey.dart` | `http://192.241.254.196` |
| 美国版 | america | `lib/main_america.dart` | `http://192.241.254.196` |
| 英国版 | britain | `lib/main_britain.dart` | `http://192.241.254.196` |
| 澳大利亚版 | australia | `lib/main_australia.dart` | `http://192.241.254.196` |

## 以后增加版本

只需在 [editions.json](editions.json) 里加一项。保存后重新打开打包工具，新版本就会出现在列表里。例如，要增加一个使用现有 `global` 包配置、但连接另一台测试服务器的版本，可以照着国内测试版复制一行：

```json
{ "id": "global_staging", "label": "预发布测试版", "flavor": "global", "target": "lib/main_global.dart", "apiBaseUrl": "http://你的服务器地址" }
```

`id` 不能和现有版本重复，只用小写英文字母、数字和下划线。`label` 是窗口中看到的名称。`flavor`、`target` 和 `apiBaseUrl` 分别对应 Flutter 的 `--flavor`、`--target` 和接口地址。注意前一项末尾要有逗号，整个文件仍要是合法的 JSON 数组。

如果加的是一个全新地区，而不是给现有地区换接口地址，还要先在 `android/app/build.gradle.kts` 的 `productFlavors` 中加入该 flavor，并准备对应的 `lib/main_地区.dart` 入口文件，然后在 `editions.json` 中填入它们。比如新增日本版时，`flavor` 可以填 `japan`，`target` 填 `lib/main_japan.dart`。

也可以直接用 PowerShell：

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tool\apk_packager\Build-InfiboApks.ps1 -Edition official -Destination 'D:\APK发布'
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\tool\apk_packager\Build-InfiboApks.ps1 -All -Destination 'D:\APK发布'
```

构建需要本机已安装 Flutter 和 Android SDK。当前工程的 Android `release` 构建仍使用 debug 签名配置；如果 APK 要作为正式商店安装包发布，还需要先配置正式签名。
