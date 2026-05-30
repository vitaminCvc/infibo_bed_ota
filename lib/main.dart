// App 程序入口。
//
// 这里只负责启动 Flutter 应用，并把根组件交给 routes/index.dart 中的 GetX 路由配置。
import 'package:flutter/cupertino.dart';
import 'package:infibo_app/pages/customized/logic.dart';
import 'package:infibo_app/routes/index.dart';

void main(List<String> args) {
  // 初始化 Flutter 应用，确保在使用 GetX 前调用
  // 初始化 Flutter 应用
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化自定义逻辑层，确保在使用 GetX 前调用
  CustomizedLogic.preload();
  // 启动 Flutter 应用
  runApp(getRootWidget());
}
