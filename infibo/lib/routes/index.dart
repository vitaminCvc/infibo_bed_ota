//根级路由
import 'package:flutter/material.dart';
import 'package:infibo/pages/login/index.dart';
import 'package:infibo/pages/main/index.dart';
//获取根级路由
Widget getRootWidget() {
  return MaterialApp(
    //命名路由
    initialRoute: "/",
    routes: getRoutes(),
  );
}
//返回该app的路由配置
Map<String, Widget Function(BuildContext)> getRoutes() {
  return {
    '/': (context) => MainPage(),
    "/login":(context)=>LoginPage(),
  };
}