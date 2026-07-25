# Android 国家版本 Flavor 设计

## 目标

将目前复制出的四个 Flutter 工程收敛为一个源代码仓库，并从其中构建四个可以独立安装的 Android 应用：

| Flavor | 应用名称 | Application ID | 首次启动默认语言 |
| --- | --- | --- | --- |
| global | Infibo | `com.infibo.app.global` | `en_US` |
| india | Infibo India | `com.infibo.app.india` | `en_US` |
| spain | Infibo Spain | `com.infibo.app.spain` | `es_ES` |
| turkey | Infibo Turkey | `com.infibo.app.turkey` | `tr_TR` |

正式发布至 Google Play 前，必须确认最终的 Application ID。它们需要是发布主体拥有的唯一标识；上表的值是本次迁移采用的实现默认值。

## 范围

共享 Flutter 实现只保留在一个仓库中：

`D:\FlutterProject\1610\infibo_app_v1.0_1610`

原来的 `India`、`spain`、`turikey` 文件夹保留为迁移参考，不再作为构建目标，迁移完成后不应继续向其中提交功能修改。

每个 Flavor 仅在以下内容上有所不同：

- Android Application ID 和可见应用名称。
- 首次启动时的默认语言，同时保留用户手动选择的语言。
- 登录页和公共页头使用的 Logo 资源。

业务逻辑、路由、翻译、依赖和非品牌资源全部共用。

## Flutter 设计

创建不可变的 `AppBrandConfig`，包含以下内容：

- Flavor 标识；
- 默认 `Locale`；
- 登录页 Logo 资源路径；
- 页头 Logo 资源路径。

创建四个很小的入口文件：`main_global.dart`、`main_india.dart`、`main_spain.dart` 和 `main_turkey.dart`。每个入口把对应的 `AppBrandConfig` 传给共享的启动函数。现有的启动流程、用户会话恢复和路由逻辑继续留在这个共享函数中。

启动函数仅在 `SharedPreferences` 中缺少 `app_language_code` 或 `app_country_code` 时使用配置的默认语言。因为每个 Flavor 都有独立的 Application ID，Android 会为每个应用提供独立的偏好设置存储；在一个国家版本中选择语言不会改变其他国家版本。

登录页面和公共页头的 Logo 引用将从当前配置中读取。其他 `Assets` 内容保持不变。

品牌资源使用明确的目录隔离：

```text
assets/branding/
  global/login_logo.png
  global/header_logo.png
  india/login_logo.png
  india/header_logo.png
  spain/login_logo.png
  spain/header_logo.png
  turkey/login_logo.png
  turkey/header_logo.png
```

迁移时会先比较每个现有工程与 global 版本的对应资源，再复制国家版本特有的资源。初次迁移不删除现有资源。

## Android 设计

在 Gradle 中增加一个名为 `market` 的 Flavor 维度和四个 `productFlavors`：`global`、`india`、`spain` 和 `turkey`。

每个 Flavor 设置独立的 `applicationId` 和 Android 应用名称资源，同时共用 Android 实现和签名配置。Android Manifest 使用 `@string/app_name`，不再硬编码应用名称。

这会生成可以独立安装的应用包。例如，India 和 Spain 版本可以同时安装在同一台设备上。

## 开发流程

所有功能修改只在主仓库完成。使用该仓库构建所需国家版本的 APK：

```powershell
flutter build apk --release --flavor global -t lib/main_global.dart
flutter build apk --release --flavor india -t lib/main_india.dart
flutter build apk --release --flavor spain -t lib/main_spain.dart
flutter build apk --release --flavor turkey -t lib/main_turkey.dart
```

日常调试使用相应的 `flutter run --flavor ... -t ...` 命令。项目中会提供一个受版本控制的 PowerShell 辅助脚本，用于一致地构建全部四个版本。

## 迁移与验证

1. 对四个当前文件夹创建快照，不覆盖原有内容。
2. 在主工程中加入 Flavor 和品牌配置基础设施。
3. 导入国家版本特有的 Logo 资源，并让登录页和页头代码通过配置获取资源路径。
4. 从主工程构建四个 debug APK。
5. 验证每个 APK 的包名、应用名称、首次启动默认语言和两类国家 Logo 是否符合预期。
6. 运行现有 Flutter 测试，并补充默认语言回退和品牌配置的针对性测试。
7. 仅在提供发布签名配置后构建 release APK。当前项目使用 debug key 签署 release 构建，不适合商店发布。

## 错误处理

- 在 debug 模式下，未知或缺失的品牌配置会在启动时失败，避免悄悄使用错误的国家品牌。
- 资源测试会验证每个配置的 Logo 路径均已在 `pubspec.yaml` 声明且文件真实存在。
- 构建辅助脚本会在任一 Flavor 构建失败时停止，并报告失败的 Flavor 名称。

## 非目标

- 本次不迁移 iOS、Windows、Linux、macOS 或 Web 的打包配置。
- 除首次启动默认语言外，不改变用户可见的业务行为或翻译文本。
- 本次不删除原有三个独立工程文件夹。
