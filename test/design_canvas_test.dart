import 'dart:math' as math;
import 'dart:ui' show DisplayFeature, DisplayFeatureState, DisplayFeatureType;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/components/designCanvas/design.dart';
import 'package:infibo_app/constants/layout.dart';
import 'package:infibo_app/pages/WifiBluetooth/connection_prompt_controller.dart';
import 'package:infibo_app/pages/WifiBluetooth/connection_prompt_host.dart';
import 'package:infibo_app/pages/WifiBluetooth/logic.dart';
import 'package:infibo_app/routes/index.dart';

void main() {
  testWidgets('uses the 16:9 profile and fills a 1080x1920 host', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1080, 1920));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final GlobalKey canvasChildKey = GlobalKey();
    Size? logicalSize;
    LayoutProfile? profile;
    double? logicalDevicePixelRatio;

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(800, 1280),
          devicePixelRatio: 2,
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: DesignCanvas(
            child: _CanvasProbe(key: canvasChildKey),
          ),
        ),
      ),
    );

    final BuildContext childContext = tester.element(
      find.byKey(canvasChildKey),
    );
    logicalSize = MediaQuery.sizeOf(childContext);
    profile = AppLayoutScope.of(childContext).profile;
    logicalDevicePixelRatio = MediaQuery.devicePixelRatioOf(childContext);

    expect(logicalSize, AppLayout.ratio16x9.designSize);
    expect(profile, LayoutProfile.ratio16x9);
    expect(logicalDevicePixelRatio, closeTo(2.7, 0.000001));
    expect(tester.getTopLeft(find.byKey(canvasChildKey)), Offset.zero);
    expect(
      tester.getBottomRight(find.byKey(canvasChildKey)),
      const Offset(1080, 1920),
    );
  });

  testWidgets('uses the legacy 16:10 profile for an 800x1280 host', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1280));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final GlobalKey canvasChildKey = GlobalKey();

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(800, 1280)),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: DesignCanvas(
            child: _CanvasProbe(key: canvasChildKey),
          ),
        ),
      ),
    );

    final BuildContext childContext = tester.element(
      find.byKey(canvasChildKey),
    );
    expect(MediaQuery.sizeOf(childContext), AppLayout.ratio16x10.designSize);
    expect(
      AppLayoutScope.of(childContext).profile,
      LayoutProfile.ratio16x10,
    );
    expect(tester.getTopLeft(find.byKey(canvasChildKey)), Offset.zero);
    expect(
      tester.getBottomRight(find.byKey(canvasChildKey)),
      const Offset(800, 1280),
    );
  });

  testWidgets('uses a fixed logical viewport and centered contain scale', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(1000, 1000));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final GlobalKey canvasChildKey = GlobalKey();
    Size? logicalSize;
    EdgeInsets? logicalPadding;
    EdgeInsets? logicalViewPadding;
    EdgeInsets? logicalViewInsets;
    EdgeInsets? logicalSystemGestureInsets;
    List<DisplayFeature>? logicalDisplayFeatures;
    double? logicalDevicePixelRatio;

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(1000, 1000),
          devicePixelRatio: 2,
          padding: EdgeInsets.all(24),
          viewPadding: EdgeInsets.all(24),
          viewInsets: EdgeInsets.only(bottom: 300),
          systemGestureInsets: EdgeInsets.all(12),
          displayFeatures: <DisplayFeature>[
            DisplayFeature(
              bounds: Rect.fromLTWH(490, 0, 20, 1000),
              type: DisplayFeatureType.hinge,
              state: DisplayFeatureState.postureFlat,
            ),
          ],
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: DesignCanvas(
            child: Builder(
              builder: (BuildContext context) {
                logicalSize = MediaQuery.sizeOf(context);
                logicalPadding = MediaQuery.paddingOf(context);
                final MediaQueryData mediaQuery = MediaQuery.of(context);
                logicalViewPadding = mediaQuery.viewPadding;
                logicalViewInsets = mediaQuery.viewInsets;
                logicalSystemGestureInsets = mediaQuery.systemGestureInsets;
                logicalDisplayFeatures = mediaQuery.displayFeatures;
                logicalDevicePixelRatio = mediaQuery.devicePixelRatio;
                return ColoredBox(key: canvasChildKey, color: Colors.red);
              },
            ),
          ),
        ),
      ),
    );

    expect(logicalSize, const Size(800, 1280));
    expect(
      AppLayoutScope.of(tester.element(find.byKey(canvasChildKey))).profile,
      LayoutProfile.ratio16x10,
    );
    expect(logicalPadding?.left, 0);
    expect(logicalPadding?.top, closeTo(30.72, 0.001));
    expect(logicalPadding?.right, 0);
    expect(logicalPadding?.bottom, 0);
    expect(logicalViewPadding?.left, 0);
    expect(logicalViewPadding?.top, closeTo(30.72, 0.001));
    expect(logicalViewPadding?.right, 0);
    expect(logicalViewPadding?.bottom, closeTo(30.72, 0.001));
    expect(logicalSystemGestureInsets, EdgeInsets.zero);
    expect(logicalDisplayFeatures, isEmpty);
    expect(logicalViewInsets?.bottom, closeTo(384, 0.001));
    expect(logicalDevicePixelRatio, closeTo(1.5625, 0.000001));
    _expectPaddingInvariant(
      padding: logicalPadding!,
      viewPadding: logicalViewPadding!,
      viewInsets: logicalViewInsets!,
    );
    final Offset topLeft = tester.getTopLeft(find.byKey(canvasChildKey));
    final Offset bottomRight = tester.getBottomRight(
      find.byKey(canvasChildKey),
    );

    expect(topLeft.dx, closeTo(187.5, 0.001));
    expect(topLeft.dy, closeTo(0, 0.001));
    expect(bottomRight.dx, closeTo(812.5, 0.001));
    expect(bottomRight.dy, closeTo(1000, 0.001));
  });

  testWidgets('root keeps one connection prompt host above the Navigator', (
    WidgetTester tester,
  ) async {
    final _ConnectedGateway gateway = _ConnectedGateway();

    await tester.pumpWidget(
      getRootWidget(
        initialRoute: '/login',
        locale: const Locale('zh', 'CN'),
        connectionPromptGateway: gateway,
      ),
    );
    await tester.pump();

    expect(find.byType(DesignCanvas), findsOneWidget);
    expect(find.byType(ConnectionPromptHost), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ConnectionPromptHost),
        matching: find.byType(Navigator),
      ),
      findsOneWidget,
    );

    final ConnectionPromptHostState hostBeforeNavigation = tester
        .state<ConnectionPromptHostState>(find.byType(ConnectionPromptHost));
    final NavigatorState navigator = tester.state<NavigatorState>(
      find.byType(Navigator),
    );

    navigator.pushNamed<void>('/register');
    await tester.pumpAndSettle();

    expect(find.byType(ConnectionPromptHost), findsOneWidget);
    expect(
      tester.state<ConnectionPromptHostState>(
        find.byType(ConnectionPromptHost),
      ),
      same(hostBeforeNavigation),
    );
  });

  testWidgets('updates layout scope and MediaQuery when the same host resizes', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1280));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final List<LayoutProfile> profiles = <LayoutProfile>[];
    final List<Size> logicalSizes = <Size>[];

    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(size: Size(800, 1280)),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: DesignCanvas(
            child: Builder(
              builder: (BuildContext context) {
                profiles.add(AppLayoutScope.of(context).profile);
                logicalSizes.add(MediaQuery.sizeOf(context));
                return const SizedBox.expand();
              },
            ),
          ),
        ),
      ),
    );

    expect(profiles, <LayoutProfile>[LayoutProfile.ratio16x10]);
    expect(logicalSizes, <Size>[AppLayout.ratio16x10.designSize]);

    await tester.binding.setSurfaceSize(const Size(1080, 1920));
    await tester.pump();

    expect(
      profiles,
      <LayoutProfile>[LayoutProfile.ratio16x10, LayoutProfile.ratio16x9],
    );
    expect(
      logicalSizes,
      <Size>[
        AppLayout.ratio16x10.designSize,
        AppLayout.ratio16x9.designSize,
      ],
    );
  });

  testWidgets('layout scope defaults to the legacy profile when absent', (
    WidgetTester tester,
  ) async {
    AppLayoutMetrics? layout;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Builder(
          builder: (BuildContext context) {
            layout = AppLayoutScope.of(context);
            return const SizedBox();
          },
        ),
      ),
    );

    expect(layout, same(AppLayout.ratio16x10));
  });

  testWidgets('uses a safe device pixel ratio when the host value is invalid', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1280));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final GlobalKey canvasChildKey = GlobalKey();
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(800, 1280),
          devicePixelRatio: double.nan,
        ),
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: DesignCanvas(
            child: _CanvasProbe(key: canvasChildKey),
          ),
        ),
      ),
    );

    expect(
      MediaQuery.devicePixelRatioOf(
        tester.element(find.byKey(canvasChildKey)),
      ),
      1,
    );
  });
}

class _CanvasProbe extends StatelessWidget {
  const _CanvasProbe({super.key});

  @override
  Widget build(BuildContext context) => const ColoredBox(color: Colors.red);
}

class _ConnectedGateway implements ConnectionPromptGateway {
  @override
  Stream<WifiConnectionStatus> get wifiStatusStream =>
      Stream<WifiConnectionStatus>.empty();

  @override
  Future<bool> hasConnectedBleDevice() async => true;

  @override
  Future<void> openBluetoothSettings() async {}

  @override
  Future<void> openWifiSettings() async {}

  @override
  Future<WifiConnectionStatus> readWifiStatus() async =>
      WifiConnectionStatus.connected;
}

void _expectPaddingInvariant({
  required EdgeInsets padding,
  required EdgeInsets viewPadding,
  required EdgeInsets viewInsets,
}) {
  expect(padding.left, math.max(viewPadding.left - viewInsets.left, 0));
  expect(padding.top, math.max(viewPadding.top - viewInsets.top, 0));
  expect(padding.right, math.max(viewPadding.right - viewInsets.right, 0));
  expect(padding.bottom, math.max(viewPadding.bottom - viewInsets.bottom, 0));
}
