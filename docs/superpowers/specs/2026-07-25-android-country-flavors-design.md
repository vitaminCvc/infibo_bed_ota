# Android 国家版本 Flavor 设计

## 目标

将目前复制出的四个国家版本 Flutter 工程收敛为一个源代码仓库，并从其中构建四个可以独立安装的 Android 应用。每个应用同时支持 16:10 和 16:9 屏幕比例：

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

现有 16:9 工程：

`D:\FlutterProject\169\infibo_app_v1.0_169`

该工程只作为已经调整过的 16:9 UI 位置参考，不作为业务功能来源。所有功能、数据处理和交互行为以 16:10 主工程为准。

每个 Flavor 仅在以下内容上有所不同：

- Android Application ID 和可见应用名称。
- 首次启动时的默认语言，同时保留用户手动选择的语言。
- 登录页和公共页头使用的 Logo 资源。

业务逻辑、路由、翻译、依赖和非品牌资源全部共用。16:10 与 16:9 不生成不同 APK；同一个国家 APK 在运行时根据设备屏幕比例选择布局。

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

## 屏幕比例设计

创建独立于 `AppBrandConfig` 的 `LayoutProfile`，品牌和屏幕比例互不影响：

- `ratio16x10`：默认布局，也是所有页面的功能和 UI 基线；
- `ratio16x9`：仅覆盖已在 16:9 工程中完成调整的 UI 参数。

运行时根据 `MediaQuery` 提供的屏幕长短边比例选择 `LayoutProfile`，不依赖国家 Flavor。四个国家版本因此都能自动使用相同的两套布局规则。

布局差异通过共享页面中的布局参数或小型布局配置对象表达，不复制业务页面。16:9 配置只覆盖位置、尺寸、间距等纯 UI 参数，不允许覆盖控制器、接口调用、状态管理、路由、持久化或其他业务逻辑。

迁移以 16:10 文件为主，逐个页面查看 16:9 工程的差异，只提取 UI 坐标和尺寸。对于尚未完成 16:9 调整的页面，不创建推测性的布局：该页面直接使用 16:10 布局作为回退。后续可逐页补充 16:9 覆盖，不影响其他页面。

## Android 设计

在 Gradle 中增加一个名为 `market` 的 Flavor 维度和四个 `productFlavors`：`global`、`india`、`spain` 和 `turkey`。

每个 Flavor 设置独立的 `applicationId` 和 Android 应用名称资源，同时共用 Android 实现和签名配置。Android Manifest 使用 `@string/app_name`，不再硬编码应用名称。

这会生成可以独立安装的应用包。例如，India 和 Spain 版本可以同时安装在同一台设备上。

屏幕比例不增加 Android Flavor，因此不会把四个国家版本扩展成八个 APK。

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
4. 对比 16:9 工程与 16:10 主工程，只迁移已完成的 UI 位置和尺寸调整；业务实现始终保留 16:10 版本。
5. 对未完成 16:9 调整的页面启用 16:10 布局回退。
6. 从主工程构建四个 debug APK。
7. 验证每个 APK 的包名、应用名称、首次启动默认语言和两类国家 Logo 是否符合预期。
8. 在 16:10 与 16:9 测试尺寸下分别验证关键页面；确认已迁移页面使用对应布局，未迁移页面使用 16:10 回退。
9. 运行现有 Flutter 测试，并补充默认语言回退、品牌配置、屏幕比例识别和布局回退的针对性测试。
10. 仅在提供发布签名配置后构建 release APK。当前项目使用 debug key 签署 release 构建，不适合商店发布。

## 错误处理

- 在 debug 模式下，未知或缺失的品牌配置会在启动时失败，避免悄悄使用错误的国家品牌。
- 资源测试会验证每个配置的 Logo 路径均已在 `pubspec.yaml` 声明且文件真实存在。
- 16:9 页面没有专用布局覆盖时自动使用 16:10 参数，不因缺少覆盖而启动失败。
- 构建辅助脚本会在任一 Flavor 构建失败时停止，并报告失败的 Flavor 名称。

## 非目标

- 本次不迁移 iOS、Windows、Linux、macOS 或 Web 的打包配置。
- 除首次启动默认语言外，不改变用户可见的业务行为或翻译文本。
- 不从 16:9 工程迁移、回退或覆盖任何业务功能。
- 不要求在本次迁移中补齐所有尚未调整的 16:9 页面。
- 本次不删除原有三个独立工程文件夹。
