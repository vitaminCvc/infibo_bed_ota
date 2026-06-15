// App 程序入口。
//
// 这里只负责启动 Flutter 应用，并把根组件交给 routes/index.dart 中的 GetX 路由配置。
import 'package:flutter/cupertino.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:infibo_app/pages/customized/logic.dart';
import 'package:infibo_app/routes/index.dart';
import 'package:infibo_app/stores/user_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main(List<String> args) async {
  // 初始化 Flutter 应用，确保在使用 GetX 前调用
  // 初始化 Flutter 应用
  WidgetsFlutterBinding.ensureInitialized();
  // 获取 UserStore 实例，确保在使用前已经注册
  final UserStore userStore = Get.put(UserStore());
  // 加载用户信息，确保在应用启动时读取用户状态
  await userStore.loadUser();
  // 初始化自定义逻辑层，确保在使用 GetX 前调用
  CustomizedLogic.preload();
  // 启动 Flutter 应用,登录的持久化通过 UserStore 的 loadUser 方法实现，根组件根据用户登录状态决定初始路由

  //启动app时先读取本地保存的语言
  final prefs = await SharedPreferences.getInstance();
  // 从 SharedPreferences 中读取语言代码和国家代码
  final String? languageCode = prefs.getString('app_language_code');
  final String? countryCode = prefs.getString('app_country_code');

  //若语言为空则使用默认语言；
  final Locale initialLocale = languageCode == null || countryCode == null
      ? const Locale('en', 'US') //默认使用英文
      : Locale(languageCode, countryCode);

  runApp(
    //登录的持久化
    // getRootWidget(
    //   initialRoute: userStore.isLoggedIn ? '/main' : '/login',
    //   locale: initialLocale,
    // ),
    getRootWidget(initialRoute: '/summary', locale: initialLocale),
  );
}
