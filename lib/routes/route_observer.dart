// App 路由观察器。
//
// 需要感知页面进入和离开的组件可以订阅这个全局观察器。
import 'package:flutter/material.dart';

/// Describes the route currently causing synchronous RouteAware callbacks.
/// Popup dismissal must not count as entering a page again.
class AppRouteObserver extends RouteObserver<ModalRoute<void>> {
  bool isPageTransition = true;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final previous = isPageTransition;
    isPageTransition = route is PageRoute;
    try {
      super.didPush(route, previousRoute);
    } finally {
      isPageTransition = previous;
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    final previous = isPageTransition;
    isPageTransition = route is PageRoute;
    try {
      super.didPop(route, previousRoute);
    } finally {
      isPageTransition = previous;
    }
  }
}

final appRouteObserver = AppRouteObserver();
