// App 路由观察器。
//
// 需要感知页面进入和离开的组件可以订阅这个全局观察器。
import 'package:flutter/material.dart';

final RouteObserver<ModalRoute<void>> appRouteObserver =
    RouteObserver<ModalRoute<void>>();
