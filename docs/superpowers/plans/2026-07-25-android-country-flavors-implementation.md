# Android 国家 Flavor 实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在 `infibo_app_v1.0_1610` 单一代码库中构建 global、India、Spain、Turkey 四个可独立安装的 Android App，并保留各自 Logo 与首次默认语言。

**Architecture:** 用 `AppBrandConfig` 保存国家差异，用四个 Dart 入口调用同一个 `bootstrapApp`。Android Product Flavors 只负责包名和应用名称，Flutter 页面通过当前品牌配置读取 Logo；其余业务代码完全共享。

**Tech Stack:** Flutter、Dart、GetX、SharedPreferences、Android Gradle Kotlin DSL、Flutter widget tests、PowerShell。

---

## 文件结构

- 创建 `lib/config/app_brand.dart`：不可变品牌配置和当前品牌注册点。
- 创建 `lib/bootstrap.dart`：共享启动流程和默认语言解析。
- 创建 `lib/main_global.dart`、`lib/main_india.dart`、`lib/main_spain.dart`、`lib/main_turkey.dart`：四个薄入口。
- 修改 `lib/main.dart`：兼容旧命令，默认转发到 global。
- 修改 `lib/constants/assets.dart`：仅把两个品牌 Logo 常量改成配置 getter。
- 修改三个认证页面：移除动态 Logo 对 `const AssetImage` 的使用。
- 创建 `assets/branding/<flavor>/`：四组登录和页头 Logo。
- 修改 `pubspec.yaml`：声明四个品牌资源目录。
- 修改 `android/app/build.gradle.kts`：增加 `market` 维度和四个 Product Flavor。
- 修改 `android/app/src/main/AndroidManifest.xml`：应用名称改用资源。
- 创建 `tool/build_android_flavors.ps1`：一致地构建四个 APK。
- 创建 `test/app_brand_test.dart`、`test/bootstrap_locale_test.dart`：品牌和语言回归测试。

## 工作区保护规则

- 只在 `D:\FlutterProject\1610\infibo_app_v1.0_1610` 实施。
- `India`、`spain`、`turikey` 目录只读取 Logo，不修改。
- 开始前保存 `git status --short` 和 `git diff --binary` 快照。
- 对实施前已经修改的文件，不执行整文件 `git add`；提交时只包含确认属于本任务且实施前干净的文件。
- 不修改或提交音频、音乐、API、治疗逻辑和现有测试改动。

### Task 1：建立品牌配置模型

**Files:**
- Create: `lib/config/app_brand.dart`
- Test: `test/app_brand_test.dart`

- [ ] **Step 1：写失败测试**

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/config/app_brand.dart';

void main() {
  test('four brands expose their locale and isolated logo paths', () {
    expect(AppBrands.global.defaultLocale, const Locale('en', 'US'));
    expect(AppBrands.india.defaultLocale, const Locale('en', 'US'));
    expect(AppBrands.spain.defaultLocale, const Locale('es', 'ES'));
    expect(AppBrands.turkey.defaultLocale, const Locale('tr', 'TR'));
    expect(AppBrands.spain.loginLogoAsset, contains('/spain/'));
    expect(AppBrands.turkey.headerLogoAsset, contains('/turkey/'));
  });

  test('unknown flavor is rejected', () {
    expect(() => AppBrands.fromFlavor('unknown'), throwsArgumentError);
  });
}
```

- [ ] **Step 2：运行测试并确认失败**

Run: `flutter test test/app_brand_test.dart`

Expected: FAIL，提示 `config/app_brand.dart` 或 `AppBrands` 不存在。

- [ ] **Step 3：实现最小品牌模型**

```dart
import 'package:flutter/widgets.dart';

class AppBrandConfig {
  const AppBrandConfig({
    required this.flavor,
    required this.defaultLocale,
    required this.loginLogoAsset,
    required this.headerLogoAsset,
  });

  final String flavor;
  final Locale defaultLocale;
  final String loginLogoAsset;
  final String headerLogoAsset;
}

class AppBrands {
  const AppBrands._();

  static const AppBrandConfig global = AppBrandConfig(
    flavor: 'global',
    defaultLocale: Locale('en', 'US'),
    loginLogoAsset: 'assets/branding/global/login_logo.png',
    headerLogoAsset: 'assets/branding/global/header_logo.png',
  );
  static const AppBrandConfig india = AppBrandConfig(
    flavor: 'india',
    defaultLocale: Locale('en', 'US'),
    loginLogoAsset: 'assets/branding/india/login_logo.png',
    headerLogoAsset: 'assets/branding/india/header_logo.png',
  );
  static const AppBrandConfig spain = AppBrandConfig(
    flavor: 'spain',
    defaultLocale: Locale('es', 'ES'),
    loginLogoAsset: 'assets/branding/spain/login_logo.png',
    headerLogoAsset: 'assets/branding/spain/header_logo.png',
  );
  static const AppBrandConfig turkey = AppBrandConfig(
    flavor: 'turkey',
    defaultLocale: Locale('tr', 'TR'),
    loginLogoAsset: 'assets/branding/turkey/login_logo.png',
    headerLogoAsset: 'assets/branding/turkey/header_logo.png',
  );

  static AppBrandConfig fromFlavor(String flavor) => switch (flavor) {
    'global' => global,
    'india' => india,
    'spain' => spain,
    'turkey' => turkey,
    _ => throw ArgumentError.value(flavor, 'flavor', 'Unknown app flavor'),
  };
}

class AppBrand {
  const AppBrand._();

  static AppBrandConfig _current = AppBrands.global;
  static AppBrandConfig get current => _current;
  static void configure(AppBrandConfig config) => _current = config;
}
```

- [ ] **Step 4：运行测试并确认通过**

Run: `flutter test test/app_brand_test.dart`

Expected: PASS，2 tests passed。

- [ ] **Step 5：在文件原本干净时提交**

```powershell
git add lib/config/app_brand.dart test/app_brand_test.dart
git commit -m "feat: add country brand configuration"
```

### Task 2：提取共享启动流程和语言回退

**Files:**
- Create: `lib/bootstrap.dart`
- Create: `lib/main_global.dart`
- Create: `lib/main_india.dart`
- Create: `lib/main_spain.dart`
- Create: `lib/main_turkey.dart`
- Modify: `lib/main.dart`
- Test: `test/bootstrap_locale_test.dart`

- [ ] **Step 1：写语言解析失败测试**

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/bootstrap.dart';

void main() {
  test('brand locale is used only when no complete saved locale exists', () {
    const Locale fallback = Locale('es', 'ES');
    expect(
      resolveInitialLocale(
        languageCode: null,
        countryCode: null,
        fallback: fallback,
      ),
      fallback,
    );
    expect(
      resolveInitialLocale(
        languageCode: 'tr',
        countryCode: 'TR',
        fallback: fallback,
      ),
      const Locale('tr', 'TR'),
    );
    expect(
      resolveInitialLocale(
        languageCode: 'tr',
        countryCode: null,
        fallback: fallback,
      ),
      fallback,
    );
  });
}
```

- [ ] **Step 2：运行测试并确认失败**

Run: `flutter test test/bootstrap_locale_test.dart`

Expected: FAIL，提示 `resolveInitialLocale` 不存在。

- [ ] **Step 3：实现共享启动函数**

`bootstrap.dart` 保留当前 `main.dart` 中的 `WidgetsFlutterBinding`、`UserStore.loadUser()`、`CustomizedLogic.preload()`、登录状态路由和 SharedPreferences key，只把固定英语替换为品牌默认语言：

```dart
Locale resolveInitialLocale({
  required String? languageCode,
  required String? countryCode,
  required Locale fallback,
}) {
  if (languageCode == null || countryCode == null) return fallback;
  return Locale(languageCode, countryCode);
}

Future<void> bootstrapApp(AppBrandConfig brand) async {
  WidgetsFlutterBinding.ensureInitialized();
  AppBrand.configure(brand);
  final UserStore userStore = Get.put(UserStore());
  await userStore.loadUser();
  CustomizedLogic.preload();
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final Locale initialLocale = resolveInitialLocale(
    languageCode: prefs.getString('app_language_code'),
    countryCode: prefs.getString('app_country_code'),
    fallback: brand.defaultLocale,
  );
  runApp(getRootWidget(
    initialRoute: userStore.isLoggedIn ? '/main' : '/login',
    locale: initialLocale,
  ));
}
```

- [ ] **Step 4：增加四个入口并保留旧入口兼容性**

每个国家入口只有品牌常量不同，例如：

```dart
import 'package:infibo_app/bootstrap.dart';
import 'package:infibo_app/config/app_brand.dart';

Future<void> main() => bootstrapApp(AppBrands.india);
```

四个入口分别使用 `AppBrands.global`、`AppBrands.india`、`AppBrands.spain`、`AppBrands.turkey`。`lib/main.dart` 使用同样形式转发到 `AppBrands.global`。

- [ ] **Step 5：运行语言和现有启动相关测试**

Run: `flutter test test/bootstrap_locale_test.dart test/design_canvas_test.dart`

Expected: PASS，且现有根组件仍只安装一个 `DesignCanvas`。

- [ ] **Step 6：在这些文件原本干净时提交**

```powershell
git add lib/bootstrap.dart lib/main.dart lib/main_global.dart lib/main_india.dart lib/main_spain.dart lib/main_turkey.dart test/bootstrap_locale_test.dart
git commit -m "feat: bootstrap country app entrypoints"
```

### Task 3：导入品牌 Logo 并连接页面资源

**Files:**
- Create: `assets/branding/global/login_logo.png`
- Create: `assets/branding/global/header_logo.png`
- Create: `assets/branding/india/login_logo.png`
- Create: `assets/branding/india/header_logo.png`
- Create: `assets/branding/spain/login_logo.png`
- Create: `assets/branding/spain/header_logo.png`
- Create: `assets/branding/turkey/login_logo.png`
- Create: `assets/branding/turkey/header_logo.png`
- Modify: `pubspec.yaml`
- Modify: `lib/constants/assets.dart`
- Modify: `lib/pages/login/login/ui.dart`
- Modify: `lib/pages/login/register/register.dart`
- Modify: `lib/pages/login/forgetpassword/forget.dart`
- Test: `test/app_brand_test.dart`

- [ ] **Step 1：扩展测试，验证八个资源文件存在**

```dart
import 'dart:io';

for (final AppBrandConfig brand in <AppBrandConfig>[
  AppBrands.global,
  AppBrands.india,
  AppBrands.spain,
  AppBrands.turkey,
]) {
  expect(File(brand.loginLogoAsset).existsSync(), isTrue);
  expect(File(brand.headerLogoAsset).existsSync(), isTrue);
}
```

- [ ] **Step 2：运行测试并确认资源缺失失败**

Run: `flutter test test/app_brand_test.dart`

Expected: FAIL，首个 `File(...).existsSync()` 为 false。

- [ ] **Step 3：从四个来源复制已核对的二进制资源**

```powershell
Copy-Item assets\Loginimages\logo.png assets\branding\global\login_logo.png
Copy-Item assets\Mainimages\mainlogo.png assets\branding\global\header_logo.png
Copy-Item D:\FlutterProject\1610\India\assets\Loginimages\logo.png assets\branding\india\login_logo.png
Copy-Item D:\FlutterProject\1610\India\assets\Mainimages\mainlogo.png assets\branding\india\header_logo.png
Copy-Item D:\FlutterProject\1610\spain\assets\Loginimages\logo.png assets\branding\spain\login_logo.png
Copy-Item D:\FlutterProject\1610\spain\assets\Mainimages\mainlogo.png assets\branding\spain\header_logo.png
Copy-Item D:\FlutterProject\1610\turikey\assets\Loginimages\logo.png assets\branding\turkey\login_logo.png
Copy-Item D:\FlutterProject\1610\turikey\assets\Mainimages\mainlogo.png assets\branding\turkey\header_logo.png
```

复制前创建四个目标目录。复制后用 SHA-256 验证来源与目标相同。

- [ ] **Step 4：声明资源并将 `Assets` 连接到品牌配置**

在 `pubspec.yaml` 的 `flutter.assets` 中加入四个目录：

```yaml
    - assets/branding/global/
    - assets/branding/india/
    - assets/branding/spain/
    - assets/branding/turkey/
```

在 `assets.dart` 导入 `app_brand.dart`，仅替换两个字段：

```dart
static String get logo => AppBrand.current.loginLogoAsset;
static String get mainLogo => AppBrand.current.headerLogoAsset;
```

- [ ] **Step 5：移除三个认证页面中的无效 const**

把三处 `precacheImage(const AssetImage(Assets.logo), context)` 改为：

```dart
precacheImage(AssetImage(Assets.logo), context);
```

不改变认证页面的其他代码，尤其保留 `auth_feedback.dart` 和当前 API 消息逻辑。

- [ ] **Step 6：运行资源和认证测试**

Run: `flutter pub get`

Run: `flutter test test/app_brand_test.dart test/auth_feedback_test.dart`

Expected: PASS，资源测试和当前认证反馈测试全部通过。

- [ ] **Step 7：只提交本任务新增且未混入旧改动的内容**

认证页面实施前已经修改，不整体暂存；保留在工作区并在最终报告中列出。可独立提交品牌资源、配置和 `pubspec.yaml` 中本任务的补丁。

### Task 4：配置四个 Android Product Flavor

**Files:**
- Modify: `android/app/build.gradle.kts`
- Modify: `android/app/src/main/AndroidManifest.xml`

- [ ] **Step 1：在 Gradle 中增加 Flavor 配置**

在 `android` 块中加入：

```kotlin
flavorDimensions += "market"
productFlavors {
    create("global") {
        dimension = "market"
        applicationId = "com.infibo.app.global"
        resValue("string", "app_name", "Infibo")
    }
    create("india") {
        dimension = "market"
        applicationId = "com.infibo.app.india"
        resValue("string", "app_name", "Infibo India")
    }
    create("spain") {
        dimension = "market"
        applicationId = "com.infibo.app.spain"
        resValue("string", "app_name", "Infibo Spain")
    }
    create("turkey") {
        dimension = "market"
        applicationId = "com.infibo.app.turkey"
        resValue("string", "app_name", "Infibo Turkey")
    }
}
```

保留当前 namespace、SDK、AAR 依赖和 buildTypes；不要改签名配置。

- [ ] **Step 2：让 Manifest 使用 Flavor 名称资源**

```xml
<application
    android:usesCleartextTraffic="true"
    android:label="@string/app_name"
    android:name="${applicationName}"
    android:icon="@mipmap/ic_launcher">
```

- [ ] **Step 3：验证 Gradle 能列出四组任务**

Run: `Set-Location android; .\gradlew.bat tasks --all`

Expected: 输出包含 `assembleGlobalDebug`、`assembleIndiaDebug`、`assembleSpainDebug`、`assembleTurkeyDebug`。

- [ ] **Step 4：在文件原本干净时提交**

```powershell
git add android/app/build.gradle.kts android/app/src/main/AndroidManifest.xml
git commit -m "feat: configure Android country flavors"
```

### Task 5：增加统一构建脚本并验证四个 APK

**Files:**
- Create: `tool/build_android_flavors.ps1`

- [ ] **Step 1：创建遇错即停的构建脚本**

```powershell
$ErrorActionPreference = 'Stop'
$variants = @(
    @{ Flavor = 'global'; Target = 'lib/main_global.dart' },
    @{ Flavor = 'india'; Target = 'lib/main_india.dart' },
    @{ Flavor = 'spain'; Target = 'lib/main_spain.dart' },
    @{ Flavor = 'turkey'; Target = 'lib/main_turkey.dart' }
)

foreach ($variant in $variants) {
    Write-Host "Building $($variant.Flavor)..."
    & flutter build apk --debug --flavor $variant.Flavor --target $variant.Target
    if ($LASTEXITCODE -ne 0) {
        throw "Build failed for flavor: $($variant.Flavor)"
    }
}
```

- [ ] **Step 2：执行所有静态分析与测试**

Run: `flutter analyze`

Expected: exit 0；若仓库已有分析告警，记录基线并确认本任务未新增告警。

Run: `flutter test`

Expected: exit 0，所有测试通过。

- [ ] **Step 3：构建四个 debug APK**

Run: `powershell -ExecutionPolicy Bypass -File tool/build_android_flavors.ps1`

Expected: 四次构建均 exit 0，并在 `build/app/outputs/flutter-apk/` 生成四个带 Flavor 名称的 debug APK。

- [ ] **Step 4：核对最终包名和应用名称**

用 Android SDK 的 `apkanalyzer manifest application-id <apk>` 和 `apkanalyzer manifest print <apk>` 检查四个 APK。Expected Application ID：

```text
com.infibo.app.global
com.infibo.app.india
com.infibo.app.spain
com.infibo.app.turkey
```

- [ ] **Step 5：提交独立构建脚本**

```powershell
git add tool/build_android_flavors.ps1
git commit -m "build: add country flavor APK script"
```

- [ ] **Step 6：记录发布限制**

当前 release 构建仍使用 debug key。只交付 debug 验证结果，不宣称可上架；正式发布前另行配置由发布主体保管的 keystore，并最终确认四个 Application ID。
