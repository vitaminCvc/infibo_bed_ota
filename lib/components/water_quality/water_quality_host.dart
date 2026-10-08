import 'dart:async';
import 'package:flutter/material.dart';
import 'water_quality_controller.dart';
import 'water_quality_dialog.dart';

class WaterQualityScope extends InheritedWidget {
  const WaterQualityScope({
    super.key,
    required this.controller,
    required super.child,
  });
  final WaterQualityController controller;
  static WaterQualityController? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<WaterQualityScope>()?.controller;
  @override
  bool updateShouldNotify(WaterQualityScope oldWidget) =>
      controller != oldWidget.controller;
}

/// 包裹 Navigator，而不是 push 一个弹窗路由；offNamed/offAll 不会移除浮层。
class WaterQualityHost extends StatefulWidget {
  const WaterQualityHost({
    super.key,
    required this.controller,
    required this.child,
    this.disposeController = false,
    this.pollInterval = const Duration(seconds: 3),
  });
  final WaterQualityController controller;
  final Widget child;
  final bool disposeController;
  final Duration pollInterval;
  @override
  State<WaterQualityHost> createState() => _WaterQualityHostState();
}

class _WaterQualityHostState extends State<WaterQualityHost>
    with WidgetsBindingObserver {
  Timer? _timer;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startPolling();
  }

  void _startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(
      widget.pollInterval,
      (_) => unawaited(widget.controller.poll()),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startPolling();
      unawaited(widget.controller.poll());
    } else {
      _timer?.cancel();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    if (widget.disposeController) widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => WaterQualityScope(
    controller: widget.controller,
    child: AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) => Stack(
        fit: StackFit.expand,
        children: [
          widget.child,
          if (widget.controller.visible) ...[
            const ModalBarrier(dismissible: false, color: Color(0xB3000000)),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: WaterQualityDialog(
                    key: const ValueKey('water_quality_dialog'),
                    controller: widget.controller,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

/// 只对真正的 PageRoute 导航复测；普通弹窗关闭不产生新的页面访问。
class WaterQualityRouteObserver extends NavigatorObserver {
  WaterQualityRouteObserver(this.controller);
  final WaterQualityController controller;
  int _navigation = 0;
  final Map<ModalRoute<dynamic>, _WaterQualityPopEntry> _guards = {};

  void _guard(Route<dynamic>? route) {
    if (route is! ModalRoute || _guards.containsKey(route)) return;
    final entry = _WaterQualityPopEntry(controller);
    _guards[route] = entry;
    route.registerPopEntry(entry);
    unawaited(route.completed.then((_) => _unguard(route)));
  }

  void _unguard(Route<dynamic>? route) {
    if (route is! ModalRoute) return;
    final entry = _guards.remove(route);
    if (entry == null) return;
    route.unregisterPopEntry(entry);
    entry.dispose();
  }

  void _enter(Route<dynamic>? route) {
    if (route is! PageRoute) return;
    final generation = ++_navigation;
    final name = route.settings.name ?? '';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (generation != _navigation) return;
      unawaited(controller.enterPage(name, deferRead: name == '/main'));
    });
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _guard(route);
    _enter(route);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _unguard(route);
    if (route is PageRoute) _enter(previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _unguard(oldRoute);
    _guard(newRoute);
    _enter(newRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      _unguard(route);
}

/// 水质浮层高于普通弹窗；系统返回必须先关浮层，不能关闭下面的路由。
class _WaterQualityPopEntry extends PopEntry<Object?> {
  _WaterQualityPopEntry(this.controller)
    : canPopNotifier = ValueNotifier(!controller.visible) {
    controller.addListener(_update);
  }
  final WaterQualityController controller;
  @override
  final ValueNotifier<bool> canPopNotifier;
  void _update() => canPopNotifier.value = !controller.visible;
  @override
  void onPopInvokedWithResult(bool didPop, Object? result) {
    if (!didPop && controller.visible) controller.dismiss();
  }

  void dispose() {
    controller.removeListener(_update);
    canPopNotifier.dispose();
  }
}
