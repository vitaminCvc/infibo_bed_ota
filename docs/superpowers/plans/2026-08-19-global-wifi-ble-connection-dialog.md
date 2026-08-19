# Global Wi-Fi / BLE Connection Dialog Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 在应用任意页面全局显示 Wi-Fi / BLE 连接提醒弹窗，并实现“当前运行期间跳过、恢复后新断线重新提醒”的状态机。

**Architecture:** 在现有 `DesignCanvas` 内用一个根级 `ConnectionPromptHost` 包裹 Navigator，通过 `Stack` 渲染不可点击穿透的遮罩和弹窗。独立 `ConnectionPromptController` 只处理连接快照、跳过状态和手动显示；现有 `SystemWifiBluetoothGateway` 增加系统 BLE 连接快照和 Wi-Fi 变化流，避免新建第二套平台实现。

**Tech Stack:** Flutter、Dart、GetX 根路由、`connectivity_plus`、`universal_ble`、`app_settings`、`flutter_test`

**Spec:** `docs/superpowers/specs/2026-08-19-global-wifi-ble-connection-dialog-design.md`

## Global Constraints

- 采用最小修改范围，不改动与连接提醒无关的业务页面和现有全屏 Wi-Fi/BLE 页。
- 使用 `assets/WifiBLE/bg.png`、`wifi.png`、`ble.png`、`enter.png`，弹窗设计尺寸为 448 × 480。
- Wi-Fi 只判断是否接入 Wi-Fi，不判断互联网可达性。
- 任意一个系统已连接 BLE 设备即可，不校验名称、MAC 或 Service UUID。
- “跳过”只保存在当前进程内；页面跳转和前后台切换不重复提示同一断线事件。
- 两项恢复连接后清除跳过状态；随后任一项再次断开时重新提示。
- 前台每 5 秒刷新一次 BLE 系统连接快照。
- 新增状态字段、生命周期处理和关键分支写必要的中文注释，不增加解释显而易见语句的噪声注释。
- Android 完整支持任意系统 BLE 连接检测；Apple 平台保持无 UUID 条件下的尽力检测。

---

### Task 1: Connection prompt state machine and gateway snapshot

**Files:**
- Create: `lib/pages/WifiBluetooth/connection_prompt_controller.dart`
- Modify: `lib/pages/WifiBluetooth/system_gateway.dart`
- Test: `test/wifi_bluetooth_connection_prompt_controller_test.dart`

**Interfaces:**
- Consumes: `WifiConnectionStatus` from `lib/pages/WifiBluetooth/logic.dart`.
- Produces: `ConnectionPromptGateway`, `ConnectionPromptController`, `ConnectionCheckStatus`, `shouldShow`, `refresh()`, `skipForCurrentRun()`, `showManually()`, `openWifiSettings()`, and `openBluetoothSettings()`.
- `SystemWifiBluetoothGateway` implements both existing `WifiBluetoothGateway` and new `ConnectionPromptGateway`.

- [ ] **Step 1: Write failing controller state-machine tests**

Create a focused fake implementing only `ConnectionPromptGateway`. Add literal behavior tests for:

```dart
test('shows when either connection is missing', () async {
  final gateway = FakeConnectionPromptGateway(
    wifiConnected: true,
    bleConnected: false,
  );
  final controller = ConnectionPromptController(gateway: gateway);

  await controller.initialize();

  expect(controller.wifiStatus, ConnectionCheckStatus.connected);
  expect(controller.bleStatus, ConnectionCheckStatus.disconnected);
  expect(controller.shouldShow, isTrue);
});

test('skip survives refresh until both connections recover', () async {
  final gateway = FakeConnectionPromptGateway(
    wifiConnected: false,
    bleConnected: false,
  );
  final controller = ConnectionPromptController(gateway: gateway);
  await controller.initialize();

  controller.skipForCurrentRun();
  await controller.refresh();
  expect(controller.shouldShow, isFalse);

  gateway
    ..wifiConnected = true
    ..bleConnected = true;
  await controller.refresh();
  expect(controller.shouldShow, isFalse);

  gateway.bleConnected = false;
  await controller.refresh();
  expect(controller.shouldShow, isTrue);
});

test('manual display stays open while connected until skipped', () async {
  final gateway = FakeConnectionPromptGateway(
    wifiConnected: true,
    bleConnected: true,
  );
  final controller = ConnectionPromptController(gateway: gateway);
  await controller.initialize();

  controller.showManually();
  await controller.refresh();
  expect(controller.shouldShow, isTrue);

  controller.skipForCurrentRun();
  expect(controller.shouldShow, isFalse);
});
```

The fake exposes a broadcast `wifiStatusStream`, mutable booleans, and counters for both settings actions. Each test calls `controller.dispose()` and closes the fake stream.

- [ ] **Step 2: Run the new test and verify RED**

Run:

```powershell
flutter test test/wifi_bluetooth_connection_prompt_controller_test.dart
```

Expected: compilation fails because `connection_prompt_controller.dart` and its public types do not exist.

- [ ] **Step 3: Implement the minimal controller contract**

Create:

```dart
enum ConnectionCheckStatus { checking, disconnected, connected }

abstract interface class ConnectionPromptGateway {
  Stream<WifiConnectionStatus> get wifiStatusStream;
  Future<WifiConnectionStatus> readWifiStatus();
  Future<bool> hasConnectedBleDevice();
  Future<void> openWifiSettings();
  Future<void> openBluetoothSettings();
}
```

Implement `ConnectionPromptController extends ChangeNotifier` with these exact rules:

```dart
bool get allConnected =>
    wifiStatus == ConnectionCheckStatus.connected &&
    bleStatus == ConnectionCheckStatus.connected;

bool get shouldShow =>
    _manualVisible || (_initialized && !_skippedForCurrentOutage && !allConnected);
```

`initialize()` subscribes once to `wifiStatusStream` and calls `refresh()`. `refresh()` uses a single in-flight future to coalesce overlapping checks, awaits `readWifiStatus()` and `hasConnectedBleDevice()` together, maps failures to disconnected, and clears `_skippedForCurrentOutage` only after `allConnected` becomes true. `skipForCurrentRun()` clears manual visibility and marks the current outage skipped. `showManually()` sets manual visibility without mutating connection state. Settings methods delegate to the gateway and catch/log failures. Guard every async notification after disposal; add Chinese comments to the skip-reset and coalescing branches.

- [ ] **Step 4: Add system connection snapshot support**

Modify `SystemWifiBluetoothGateway` to implement `ConnectionPromptGateway`:

```dart
@override
Stream<WifiConnectionStatus> get wifiStatusStream =>
    _connectivity.onConnectivityChanged.map(_mapWifiStatus).distinct();

@override
Future<bool> hasConnectedBleDevice() async {
  final AvailabilityState availability =
      await UniversalBle.getBluetoothAvailabilityState();
  if (availability != AvailabilityState.poweredOn) return false;
  final List<BleDevice> devices =
      await UniversalBle.getSystemDevices(withServices: <String>[]);
  return devices.isNotEmpty;
}
```

Extract `_mapWifiStatus(List<ConnectivityResult> results)` and use it from both `wifiStatusStream` and existing `readWifiStatus()` so the mapping has one source.

- [ ] **Step 5: Run controller and existing Wi-Fi/BLE tests and verify GREEN**

Run:

```powershell
flutter test test/wifi_bluetooth_connection_prompt_controller_test.dart test/wifi_bluetooth_logic_test.dart test/wifi_bluetooth_page_test.dart
```

Expected: all tests pass with no uncaught asynchronous errors.

- [ ] **Step 6: Commit the isolated state-machine change**

Use path-limited staging/commit because the worktree already contains unrelated user changes:

```powershell
git add -- lib/pages/WifiBluetooth/connection_prompt_controller.dart lib/pages/WifiBluetooth/system_gateway.dart test/wifi_bluetooth_connection_prompt_controller_test.dart
git commit --only -m "feat: add global connection prompt state" -- lib/pages/WifiBluetooth/connection_prompt_controller.dart lib/pages/WifiBluetooth/system_gateway.dart test/wifi_bluetooth_connection_prompt_controller_test.dart
```

---

### Task 2: Dialog visual and global host

**Files:**
- Create: `lib/pages/WifiBluetooth/connection_prompt_dialog.dart`
- Create: `lib/pages/WifiBluetooth/connection_prompt_host.dart`
- Create: `test/wifi_bluetooth_connection_prompt_widget_test.dart`

**Interfaces:**
- Consumes: `ConnectionPromptController` and `ConnectionPromptGateway` from Task 1.
- Produces: `WifiBluetoothConnectionDialog`, `ConnectionPromptHost`, and `ConnectionPromptHost.showManually(BuildContext context)`.

- [ ] **Step 1: Write failing widget tests for visual behavior and actions**

Pump `ConnectionPromptHost` through `MaterialApp.builder` with a fake gateway and a long test poll interval. Cover these user-visible behaviors:

```dart
expect(find.text('未连接WIFI 或 蓝牙'), findsOneWidget);
expect(find.byKey(const ValueKey('connection_prompt_wifi_row')), findsOneWidget);
expect(find.byKey(const ValueKey('connection_prompt_ble_row')), findsOneWidget);
expect(find.text('跳过'), findsOneWidget);

await tester.tap(find.byKey(const ValueKey('connection_prompt_wifi_row')));
await tester.tap(find.byKey(const ValueKey('connection_prompt_ble_row')));
expect(gateway.openWifiSettingsCalls, 1);
expect(gateway.openBluetoothSettingsCalls, 1);
```

Add a second test that taps “跳过”, pushes another route through the real Navigator, emits the same disconnected Wi-Fi state, and verifies the dialog stays hidden. Then mutate the fake to both connected, simulate `AppLifecycleState.resumed`, mutate BLE to disconnected, simulate resume again, and verify the dialog returns.

Add a third test that places a tappable counter under the Host, taps the modal barrier, and verifies the counter remains zero.

- [ ] **Step 2: Run widget test and verify RED**

Run:

```powershell
flutter test test/wifi_bluetooth_connection_prompt_widget_test.dart
```

Expected: compilation fails because the Host and dialog widgets do not exist.

- [ ] **Step 3: Implement the 448 × 480 dialog**

Build `WifiBluetoothConnectionDialog` as a stateless presentation widget receiving the controller. Use `Image.asset('assets/WifiBLE/bg.png')` as the positioned background and the three supplied icon assets in the two 384 × 104 rows. Give the rows the exact keys used by tests, display `检测中 / 已连接 / 未连接`, use green `0xFF44E875` and red `0xFFFF5B62` status dots, and call the controller settings methods on row taps. The bottom “跳过” text calls `skipForCurrentRun()`.

Use a `Stack` so text and rows follow the supplied 448 × 480 canvas. Add Chinese comments only around asset-coordinate grouping and status color mapping.

- [ ] **Step 4: Implement the root Host lifecycle and overlay**

`ConnectionPromptHost` is a `StatefulWidget` with:

```dart
const ConnectionPromptHost({
  super.key,
  required this.child,
  this.gateway,
  this.blePollInterval = const Duration(seconds: 5),
});

static void showManually(BuildContext context) {
  context.findAncestorStateOfType<ConnectionPromptHostState>()
      ?.showManually();
}
```

The state owns the real gateway only when no gateway was injected, owns/disposes `ConnectionPromptController`, registers `WidgetsBindingObserver`, and starts a periodic BLE refresh only while resumed. `didChangeAppLifecycleState(resumed)` refreshes immediately and restarts polling. Override `didPopRoute()` to return `true` while the prompt is visible so Android back cannot dismiss it.

Render:

```dart
Stack(
  fit: StackFit.expand,
  children: <Widget>[
    widget.child,
    if (_controller.shouldShow) ...<Widget>[
      const ModalBarrier(dismissible: false, color: Color(0x99000000)),
      Center(child: WifiBluetoothConnectionDialog(controller: _controller)),
    ],
  ],
)
```

Add Chinese comments to the global overlay, foreground polling, and owned-gateway disposal branches.

- [ ] **Step 5: Run widget and controller tests and verify GREEN**

Run:

```powershell
flutter test test/wifi_bluetooth_connection_prompt_widget_test.dart test/wifi_bluetooth_connection_prompt_controller_test.dart
```

Expected: all tests pass; no taps reach the page beneath the modal barrier.

- [ ] **Step 6: Commit the isolated UI/Host change**

```powershell
git add -- lib/pages/WifiBluetooth/connection_prompt_dialog.dart lib/pages/WifiBluetooth/connection_prompt_host.dart test/wifi_bluetooth_connection_prompt_widget_test.dart
git commit --only -m "feat: add global wifi ble prompt overlay" -- lib/pages/WifiBluetooth/connection_prompt_dialog.dart lib/pages/WifiBluetooth/connection_prompt_host.dart test/wifi_bluetooth_connection_prompt_widget_test.dart
```

---

### Task 3: Root integration, assets, and homepage manual entry

**Files:**
- Modify: `lib/routes/index.dart`
- Modify: `lib/pages/main/ui.dart`
- Modify: `pubspec.yaml`
- Modify: `test/design_canvas_test.dart`
- Test: `test/wifi_bluetooth_connection_prompt_widget_test.dart`

**Interfaces:**
- Consumes: `ConnectionPromptHost` and `ConnectionPromptHost.showManually(BuildContext)` from Task 2.
- Produces: one production Host wrapping every app route and a homepage button that force-opens it.

- [ ] **Step 1: Extend the root integration test and verify RED**

Update the existing `getRootWidget` test setup to inject a fake `ConnectionPromptGateway` and assert the real root tree contains exactly one `ConnectionPromptHost` above the Navigator. Add a route navigation assertion showing the same Host instance remains mounted after navigation.

Run:

```powershell
flutter test test/design_canvas_test.dart
```

Expected: compilation or assertion failure because `getRootWidget` does not accept a gateway and does not build the Host.

- [ ] **Step 2: Register assets and wrap the root Navigator**

Add exactly one asset directory entry:

```yaml
    - assets/WifiBLE/
```

Extend `getRootWidget` with an optional `ConnectionPromptGateway? connectionPromptGateway` used only for dependency injection. Change the existing builder body to:

```dart
return DesignCanvas(
  child: ConnectionPromptHost(
    gateway: connectionPromptGateway,
    child: child ?? const SizedBox.shrink(),
  ),
);
```

Keep the existing `/wifi-bluetooth` route and full page untouched to minimize deletion risk.

- [ ] **Step 3: Make the homepage button open the global prompt**

Replace the inert callback in `_go(BuildContext context)` with:

```dart
onPressed: () => ConnectionPromptHost.showManually(context),
```

Add the Host import. Do not change the button position, label, or style.

- [ ] **Step 4: Run focused integration tests and verify GREEN**

Run:

```powershell
flutter test test/design_canvas_test.dart test/wifi_bluetooth_connection_prompt_widget_test.dart test/widget_test.dart
```

Expected: root canvas, prompt overlay, homepage button, and existing main-page dialog tests all pass.

- [ ] **Step 5: Run formatting and the complete verification set**

Run:

```powershell
dart format lib/pages/WifiBluetooth/connection_prompt_controller.dart lib/pages/WifiBluetooth/connection_prompt_dialog.dart lib/pages/WifiBluetooth/connection_prompt_host.dart lib/pages/WifiBluetooth/system_gateway.dart lib/routes/index.dart lib/pages/main/ui.dart test/wifi_bluetooth_connection_prompt_controller_test.dart test/wifi_bluetooth_connection_prompt_widget_test.dart test/design_canvas_test.dart
flutter analyze
flutter test
```

Expected: formatter exits 0; analyzer reports no issues; all tests pass.

- [ ] **Step 6: Inspect the final scoped diff**

Run:

```powershell
git diff --check
git diff -- lib/pages/WifiBluetooth/connection_prompt_controller.dart lib/pages/WifiBluetooth/connection_prompt_dialog.dart lib/pages/WifiBluetooth/connection_prompt_host.dart lib/pages/WifiBluetooth/system_gateway.dart lib/routes/index.dart lib/pages/main/ui.dart pubspec.yaml test/wifi_bluetooth_connection_prompt_controller_test.dart test/wifi_bluetooth_connection_prompt_widget_test.dart test/design_canvas_test.dart
```

Confirm no unrelated lines changed and the necessary Chinese comments remain around lifecycle and state-machine decisions.

- [ ] **Step 7: Commit the root integration**

```powershell
git add -- lib/routes/index.dart lib/pages/main/ui.dart pubspec.yaml test/design_canvas_test.dart
git commit --only -m "feat: show connection prompt across app" -- lib/routes/index.dart lib/pages/main/ui.dart pubspec.yaml test/design_canvas_test.dart
```

