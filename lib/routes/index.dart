// 根级路由
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/pages/login/ui.dart';
import 'package:infibo_app/pages/main/logic.dart';
import 'package:infibo_app/pages/main/ui.dart';

// 获取根级路由
Widget getRootWidget() {
  return GetMaterialApp(
    // 初始路由为登录页
    initialRoute: "/login",
    getPages: getRoutes(),
  );
}

// 返回App路由配置
List<GetPage> getRoutes() {
  return [
    // 登录页
    GetPage(name: "/login", page: () => const LoginPage()),
    // 主页面
    GetPage(name: "/main", page: () => const MainPage()),
    // 模式详情页
    GetPage(
      name: MainLogic.modeDetailRoute,
      page: () => ModeDetailPage(title: Get.arguments as String? ?? '理疗模式'),
    ),
  ];
}
