import 'dart:async';

import 'package:flutter/material.dart';

import 'connection_prompt_controller.dart';
import 'connection_prompt_dialog.dart';
import 'system_gateway.dart';

class ConnectionPromptHost extends StatefulWidget {
  const ConnectionPromptHost({
    super.key,
    required this.child,
    required this.navigatorKey,
    this.gateway,
    this.blePollInterval = const Duration(seconds: 5),
  });

  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;
  final ConnectionPromptGateway? gateway;
  final Duration blePollInterval;

  static void showManually(BuildContext context) {
    context
        .findAncestorStateOfType<ConnectionPromptHostState>()
        ?.showManually();
  }

  @override
  State<ConnectionPromptHost> createState() => ConnectionPromptHostState();
}

class ConnectionPromptHostState extends State<ConnectionPromptHost>
    with WidgetsBindingObserver {
  /// 连接提示主机状态
  late final ConnectionPromptGateway _gateway;
  late final ConnectionPromptController _controller;
  late final bool _ownsGateway;
  Timer? _blePollTimer;
  Route<void>? _backGuardRoute;
  bool _backGuardSyncScheduled = false;

  @override
  /// 初始化连接提示主机状态
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ownsGateway = widget.gateway == null;
    _gateway = widget.gateway ?? SystemWifiBluetoothGateway();
    _controller = ConnectionPromptController(gateway: _gateway);
    _controller.addListener(_scheduleBackGuardSync);
    unawaited(_controller.initialize());
    _scheduleBackGuardSync();
    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      _startBlePolling();
    }
  }

  void showManually() {
    _controller.showManually();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_controller.refresh());
      _startBlePolling();
      return;
    }
    _stopBlePolling();
  }

  void _startBlePolling() {
    _stopBlePolling();
    // 仅在前台轮询蓝牙连接快照，避免后台继续访问系统蓝牙服务。
    _blePollTimer = Timer.periodic(widget.blePollInterval, (_) {
      unawaited(_controller.refresh());
    });
  }

  void _stopBlePolling() {
    _blePollTimer?.cancel();
    _blePollTimer = null;
  }

  void _scheduleBackGuardSync() {
    if (!mounted || _backGuardSyncScheduled) return;
    _backGuardSyncScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _backGuardSyncScheduled = false;
      if (mounted) _syncBackGuardRoute();
    });
  }

  void _syncBackGuardRoute() {
    final NavigatorState? navigator = widget.navigatorKey.currentState;
    if (navigator == null) return;

    final Route<void>? route = _backGuardRoute;
    if (_controller.shouldShow) {
      if (route != null) return;
      // 根 Navigator 顶部的不可弹出路由让普通返回与预测返回都先命中 PopScope。
      final _ConnectionPromptBackGuardRoute guardRoute =
          _ConnectionPromptBackGuardRoute();
      _backGuardRoute = guardRoute;
      unawaited(
        navigator.push<void>(guardRoute).whenComplete(() {
          if (!identical(_backGuardRoute, guardRoute)) return;
          _backGuardRoute = null;
          if (mounted && _controller.shouldShow) _scheduleBackGuardSync();
        }),
      );
      return;
    }

    if (route != null) {
      _backGuardRoute = null;
      navigator.removeRoute(route);
    }
  }

  @override
  void dispose() {
    _stopBlePolling();
    WidgetsBinding.instance.removeObserver(this);
    _controller.removeListener(_scheduleBackGuardSync);
    _controller.dispose();
    if (_ownsGateway && _gateway is SystemWifiBluetoothGateway) {
      // 仅释放 Host 自己创建的系统网关，注入网关由调用方管理。
      unawaited(_gateway.dispose());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Stack(
          fit: StackFit.expand,
          children: <Widget>[
            widget.child,
            // 根级遮罩保证任意路由都不能穿透到页面内容。
            if (_controller.shouldShow) ...<Widget>[
              const ModalBarrier(dismissible: false, color: Color(0x99000000)),
              Center(
                child: WifiBluetoothConnectionDialog(controller: _controller),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ConnectionPromptBackGuardRoute extends PopupRoute<void> {
  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => false;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return const PopScope(canPop: false, child: SizedBox.expand());
  }
}
