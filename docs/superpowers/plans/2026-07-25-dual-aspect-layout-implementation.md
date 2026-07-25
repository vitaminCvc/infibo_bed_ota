# 16:10 与 16:9 双比例布局实施计划

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 让四个国家 App 在同一 APK 中自动选择 16:10 或 16:9 UI，并以 `1610` 工程为全部功能基线。

**Architecture:** `DesignCanvas` 根据宿主屏幕长短边比例选择逻辑画布，`AppLayoutScope` 向页面提供布局参数。16:10 参数始终是默认值；只把 `169` 工程已验证的坐标、尺寸和间距提取为 16:9 覆盖，未迁移页面自动沿用 16:10 UI。

**回退规则:** 16:10 是安全回退；方形、无效或无法识别的宿主尺寸，以及没有 16:9 专用覆盖的页面，都使用 16:10 布局。

**Tech Stack:** Flutter、MediaQuery、InheritedWidget、widget tests、Golden/截图检查、Git no-index diff。

---

## 文件边界

- 修改 `lib/constants/layout.dart`：定义 `LayoutProfile`、`AppLayout` 参数和检测规则。
- 修改 `lib/components/designCanvas/design.dart`：选择画布并安装 `AppLayoutScope`。
- 修改 `test/design_canvas_test.dart`：覆盖两种比例和方形宿主回退。
- 从 `169/test/portrait_layout_test.dart` 移植为主工程的 `test/dual_aspect_layout_test.dart`，但保留主工程现有 API/状态依赖。
- 允许迁移 UI 的页面：三个 header、登录/注册/忘记密码、主页、选择用户、启动、总结、音乐、设置、历史详情、DeviceInfo、自定义方案及其 UI 子页。
- 禁止从 `169` 迁移：`customizedPage/logic.dart`、`customized/logic.dart`、`audio_prompt_player.dart`、`app_translations.dart` 以及任何 API、状态、路由、存储逻辑。

### Task 1：建立可测试的比例检测与布局参数

**Files:**
- Modify: `lib/constants/layout.dart`
- Create: `test/layout_profile_test.dart`

- [ ] **Step 1：写比例检测失败测试**

```dart
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/constants/layout.dart';

void main() {
  test('selects 16:10 and 16:9 from either orientation', () {
    expect(AppLayout.forHostSize(const Size(800, 1280)).profile,
        LayoutProfile.ratio16x10);
    expect(AppLayout.forHostSize(const Size(1280, 800)).profile,
        LayoutProfile.ratio16x10);
    expect(AppLayout.forHostSize(const Size(1080, 1920)).profile,
        LayoutProfile.ratio16x9);
    expect(AppLayout.forHostSize(const Size(1920, 1080)).profile,
        LayoutProfile.ratio16x9);
  });

  test('16:10 is the safe fallback for square or invalid hosts', () {
    expect(AppLayout.forHostSize(const Size(1000, 1000)).profile,
        LayoutProfile.ratio16x10);
    expect(AppLayout.forHostSize(Size.zero).profile,
        LayoutProfile.ratio16x10);
  });

  test('legacy positions remain unchanged in 16:10', () {
    expect(AppLayout.ratio16x10.mainContentY(1010), 1010);
    expect(AppLayout.ratio16x10.standardContentY(860), 860);
  });
}
```

- [ ] **Step 2：运行并确认失败**

Run: `flutter test test/layout_profile_test.dart`

Expected: FAIL，缺少 `LayoutProfile` 和 `forHostSize`。

- [ ] **Step 3：实现布局对象和默认回退**

```dart
enum LayoutProfile { ratio16x10, ratio16x9 }

class AppLayout {
  const AppLayout._({required this.profile, required this.designHeight});

  static const double designWidth = 800;
  static const double legacyViewportHeight = 1280;
  static const double headerTop = 25;
  static const double horizontalPageInset = 44;
  static const AppLayout ratio16x10 = AppLayout._(
    profile: LayoutProfile.ratio16x10,
    designHeight: legacyViewportHeight,
  );
  static const AppLayout ratio16x9 = AppLayout._(
    profile: LayoutProfile.ratio16x9,
    designHeight: designWidth * 16 / 9,
  );

  final LayoutProfile profile;
  final double designHeight;
  bool get is16x9 => profile == LayoutProfile.ratio16x9;
  Size get designSize => Size(designWidth, designHeight);
  double get addedHeight => designHeight - legacyViewportHeight;
  double get contentTopOffset => is16x9 ? 40 : 0;
  double get standardContentHeight => 1160 + addedHeight;
  double get expandedContentHeight => 1088 + addedHeight;
  double get mainContentHeight => 1230 + addedHeight;

  static AppLayout forHostSize(Size size) {
    if (size.shortestSide <= 0) return ratio16x10;
    final double longToShort = size.longestSide / size.shortestSide;
    const double threshold = 1.69;
    return longToShort >= threshold ? ratio16x9 : ratio16x10;
  }

  double spreadY(double legacyY, double legacyHeight, double targetHeight) =>
      legacyY * targetHeight / legacyHeight;
  double mainContentY(double legacyY) => is16x9
      ? spreadY(legacyY, 1230, 1230 + addedHeight) + contentTopOffset
      : legacyY;
  double standardContentY(double legacyY) => is16x9
      ? spreadY(legacyY, 1160, 1160 + addedHeight) + contentTopOffset
      : legacyY;
  double expandedContentY(double legacyY) => is16x9
      ? spreadY(legacyY, 1088, 1088 + addedHeight) + contentTopOffset
      : legacyY;
  double viewportContentY(double legacyY) => is16x9
      ? spreadY(legacyY, legacyViewportHeight, designHeight) + contentTopOffset
      : legacyY;
}
```

- [ ] **Step 4：运行测试并确认通过**

Run: `flutter test test/layout_profile_test.dart`

Expected: PASS，3 tests passed。

### Task 2：让 DesignCanvas 安装当前布局

**Files:**
- Modify: `lib/components/designCanvas/design.dart`
- Modify: `test/design_canvas_test.dart`

- [ ] **Step 1：增加 16:9 画布失败测试**

```dart
testWidgets('uses a 9:16 logical canvas on a 1080x1920 host', (tester) async {
  await tester.binding.setSurfaceSize(const Size(1080, 1920));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  Size? logicalSize;
  LayoutProfile? profile;
  await tester.pumpWidget(MaterialApp(home: DesignCanvas(
    child: Builder(builder: (context) {
      logicalSize = MediaQuery.sizeOf(context);
      profile = AppLayoutScope.of(context).profile;
      return const SizedBox.expand();
    }),
  )));
  expect(logicalSize, AppLayout.ratio16x9.designSize);
  expect(profile, LayoutProfile.ratio16x9);
});
```

- [ ] **Step 2：运行并确认当前固定 800×1280 导致失败**

Run: `flutter test test/design_canvas_test.dart`

Expected: FAIL，16:9 用例得到 800×1280 或缺少 `AppLayoutScope`。

- [ ] **Step 3：实现 Scope 并改为按宿主选择画布**

```dart
class AppLayoutScope extends InheritedWidget {
  const AppLayoutScope({
    super.key,
    required this.layout,
    required super.child,
  });
  final AppLayout layout;
  static AppLayout of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<AppLayoutScope>()
      ?.layout ?? AppLayout.ratio16x10;
  @override
  bool updateShouldNotify(AppLayoutScope oldWidget) => layout != oldWidget.layout;
}
```

在 `LayoutBuilder` 内执行：

```dart
final AppLayout layout = AppLayout.forHostSize(constraints.biggest);
final Size designSize = layout.designSize;
```

所有 inset 映射使用局部 `designSize`，并在逻辑 `MediaQuery` 外包裹：

```dart
AppLayoutScope(
  layout: layout,
  child: MediaQuery(data: designMediaQuery, child: child),
)
```

- [ ] **Step 4：运行画布和比例测试**

Run: `flutter test test/layout_profile_test.dart test/design_canvas_test.dart`

Expected: PASS；800×1280、1080×1920 和方形宿主均得到预期布局。

### Task 3：移植 169 的布局测试但保持 1610 功能依赖

**Files:**
- Create: `test/dual_aspect_layout_test.dart`
- Reference only: `D:\FlutterProject\169\infibo_app_v1.0_169\test\portrait_layout_test.dart`

- [ ] **Step 1：复制纯 UI 测试骨架**

保留以下测试类型及实际期望值：9:16 画布、三种 header top、登录间距 `[145, 38, 38, 64, 30, 110]`、注册间距 `[90, 46, 46, 92, 30, 120]`、忘记密码间距 `[145, 44, 44, 44, 82]`、键盘可见性、启动页与总结页无溢出。

不要复制 `169` 的 `localized_api_message.dart` 依赖或 API 断言。测试导入主工程当前存在的 `auth_feedback.dart`、控制器和页面类型。

- [ ] **Step 2：运行并记录失败页面**

Run: `flutter test test/dual_aspect_layout_test.dart --reporter expanded`

Expected: 画布基础用例通过，尚未迁移的页面间距或位置用例失败；不得出现编译失败或业务依赖缺失。

- [ ] **Step 3：建立明确迁移清单**

只允许对下列文件迁移 UI hunk：

```text
lib/components/index.dart
lib/components/settingindex.dart
lib/components/userindex.dart
lib/pages/choseusers/ui.dart
lib/pages/customized/ui.dart
lib/pages/customized/customizedPage/ui.dart
lib/pages/customized/customizedPage/hifem/ui.dart
lib/pages/customized/customizedPage/mailun/ui.dart
lib/pages/customized/customizedPage/setting_page_helpers.dart
lib/pages/customized/customizedPage/taihezi/ui.dart
lib/pages/customized/customizedPage/xiangfen/ui.dart
lib/pages/login/login/ui.dart
lib/pages/login/register/register.dart
lib/pages/login/forgetpassword/forget.dart
lib/pages/main/ui.dart
lib/pages/music/ui.dart
lib/pages/settingpage/DeviceInfo.dart
lib/pages/settingpage/history_detail.dart
lib/pages/start/ui.dart
lib/pages/summary/summary.dart
```

### Task 4：迁移公共页头、认证页和主页面的 16:9 UI

**Files:**
- Modify: three header files, three auth files, `lib/pages/main/ui.dart`
- Test: `test/dual_aspect_layout_test.dart`

- [ ] **Step 1：迁移只改变位置的 header hunk**

三个页头统一使用不会随比例变化的 `top: AppLayout.headerTop` 和 `AppLayout.horizontalPageInset`。不得复制用户菜单、退出登录或时钟逻辑差异。

- [ ] **Step 2：迁移认证页面 UI 分支**

保持当前表单提交、`auth_feedback.dart`、接口和导航代码不动。通过 `final bool is16x9 = AppLayoutScope.of(context).is16x9;` 选择间距；16:10 使用当前值，16:9 使用 `169` 测试中的期望值。品牌 Logo 的 16:9 overlay 使用键 `auth-brand-logo`，16:10 保持当前 flow 布局。

- [ ] **Step 3：迁移主页坐标映射**

将 `169` 中的静态调用改为 scope 参数，例如：

```dart
final AppLayout layout = AppLayoutScope.of(context);
top: layout.mainContentY(item.top),
```

人体图仅在 16:9 使用 `left: 98, width: 600, height: 900`；16:10 保持 `left: 160, width: 479, height: 800`。不迁移音频播放、水位检测或路由生命周期差异。

- [ ] **Step 4：运行目标测试**

Run: `flutter test test/dual_aspect_layout_test.dart test/auth_feedback_test.dart`

Expected: header、认证、主页布局断言通过，认证功能测试继续通过。

### Task 5：迁移其余已完成页面的纯 UI hunk

**Files:**
- Modify: Task 3 白名单中剩余页面
- Test: `test/dual_aspect_layout_test.dart`

- [ ] **Step 1：逐文件查看 no-index diff**

Run template:

```powershell
git diff --no-index --unified=3 -- D:\FlutterProject\1610\infibo_app_v1.0_1610\lib\pages\start\ui.dart D:\FlutterProject\169\infibo_app_v1.0_169\lib\pages\start\ui.dart
```

只接受这些 hunk：导入 layout、数字坐标转 `AppLayoutScope.of(context)` 映射、纯尺寸/间距、用于测试的 UI key。拒绝 import API/utility 变化、函数调用变化、状态字段变化和翻译文本变化。

- [ ] **Step 2：按现有 169 测试覆盖顺序迁移**

顺序为：选择用户、启动、总结、音乐、设置、历史详情、DeviceInfo、自定义列表、自定义编辑和五个自定义子页面。每完成一组就运行：

Run: `flutter test test/dual_aspect_layout_test.dart --reporter expanded`

Expected: 已迁移用例转为 PASS；尚无 16:9 专用断言的页面仍使用 16:10 回退且不溢出。

- [ ] **Step 3：审计禁止迁移文件**

Run:

```powershell
git diff -- lib/pages/customized/logic.dart lib/pages/customized/customizedPage/logic.dart lib/pages/start/audio_prompt_player.dart lib/translation/app_translations.dart
```

Expected: 输出与实施前快照完全一致，没有来自 `169` 的新增差异。

### Task 6：完成双比例回归验证

**Files:**
- Test only

- [ ] **Step 1：运行格式化和静态分析**

Run: `dart format --output=none --set-exit-if-changed lib test`

Expected: exit 0；如需格式化，先运行 `dart format` 再重跑。

Run: `flutter analyze`

Expected: exit 0，或仅保留实施前已有告警且没有新增告警。

- [ ] **Step 2：运行完整测试**

Run: `flutter test`

Expected: exit 0，全部测试通过。

- [ ] **Step 3：在两种尺寸运行四个 Flavor**

至少对 global 执行 800×1280 和 1080×1920 的截图检查，再对 India、Spain、Turkey 的登录页和主页执行 1080×1920 检查。Expected：无溢出、无重叠、Logo 正确、未迁移页面保持 16:10 UI。

- [ ] **Step 4：最终差异审计**

对照实施前 `git diff --binary` 快照，列出本任务实际新增的每个 hunk。任何无法解释为品牌或 UI 布局的差异都移除；不删除两个来源工程。

- [ ] **Step 5：提交策略**

只提交实施前干净的文件和可明确分离的新增文件。对原本已有用户修改的 UI 文件保持未提交，并在交付说明中逐项列出，避免把用户工作伪装成本任务提交。
