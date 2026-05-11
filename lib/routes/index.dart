// App 根级路由表。
//
// 这里集中注册所有页面路由；正式入口不会展示调试页，但保留 /debug/serial-test 隐藏路由便于现场排查串口。
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/pages/choseusers/ui.dart';
import 'package:infibo_app/pages/customized/customizedPage/mailun/ui.dart';
import 'package:infibo_app/pages/customized/customizedPage/ui.dart';
import 'package:infibo_app/pages/customized/ui.dart';
import 'package:infibo_app/pages/debug/serial_test_page.dart';
import 'package:infibo_app/pages/login/ui.dart';
import 'package:infibo_app/pages/main/ui.dart';
import 'package:infibo_app/pages/music/ui.dart';
import 'package:infibo_app/pages/start/ui.dart';

const String _initialRoute = String.fromEnvironment(
  'INFIBO_INITIAL_ROUTE',
  defaultValue: '/login',
);

// 获取根级路由
Widget getRootWidget() {
  return GetMaterialApp(
    // 初始路由为登录页
    initialRoute: _initialRoute,
    defaultTransition: Transition.noTransition,
    transitionDuration: Duration.zero,
    getPages: getRoutes(),
  );
}

List<GetPage> getRoutes() {
  return [
    // 登录页
    GetPage(name: "/login", page: () => const LoginPage()),
    // 主页面
    GetPage(name: "/main", page: () => const MainPage()),
    // 选择用户页面
    GetPage(name: "/choseusers", page: () => const ChoseUsersPage()),
    // 启动理疗页面
    GetPage(name: "/start", page: () => const StartPage()),
    // 自定义页面
    GetPage(name: "/customized", page: () => const CustomizedPage()),
    // 自定义方案编辑页面
    GetPage(name: "/customized/edit", page: () => const CustomizedEditPage()),
    // 自定义方案脉轮设置页面
    GetPage(
      name: "/customized/edit/mailun",
      page: () => const ChakraExpandPage(),
    ),
    // 音乐选择页
    GetPage(name: "/music", page: () => const MusicSelectPage()),
    // 隐藏调试路由：不在正式页面提供入口。
    GetPage(name: "/debug/serial-test", page: () => const SerialTestPage()),
  ];
}
