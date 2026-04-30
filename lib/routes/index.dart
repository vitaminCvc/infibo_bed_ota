// 根级路由
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/pages/choseusers/ui.dart';
import 'package:infibo_app/pages/customized/customizedPage/ui.dart';
import 'package:infibo_app/pages/customized/ui.dart';
import 'package:infibo_app/pages/login/ui.dart';
import 'package:infibo_app/pages/main/ui.dart';
import 'package:infibo_app/pages/start/ui.dart';

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
    // 选择用户页面
    GetPage(name: "/choseusers", page: () => const ChoseUsersPage()),
    // 启动理疗页面
    GetPage(name: "/start", page: () => const StartPage()),
    // 自定义页面
    GetPage(name: "/customized", page: () => const CustomizedPage()),
    // 自定义方案编辑页面
    GetPage(name: "/customized/edit", page: () => const CustomizedEditPage()),
  ];
}
