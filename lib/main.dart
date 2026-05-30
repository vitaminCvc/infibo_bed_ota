// App 程序入口。
//
// 这里只负责启动 Flutter 应用，并把根组件交给 routes/index.dart 中的 GetX 路由配置。
import 'package:flutter/cupertino.dart';
import 'package:infibo_app/pages/customized/logic.dart';
import 'package:infibo_app/routes/index.dart';

void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();
  CustomizedLogic.preload();
  runApp(getRootWidget());
}
