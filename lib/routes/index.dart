// App 根级路由表。
//
// 这里集中注册所有页面路由；正式入口不会展示调试页，但保留 /debug/serial-test 隐藏路由便于现场排查串口。
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/designCanvas/design.dart';
import 'package:infibo_app/pages/login/forgetpassword/forget.dart';
import 'package:infibo_app/pages/login/register/register.dart';
import 'package:infibo_app/pages/summary/summary.dart';
import 'package:infibo_app/routes/route_observer.dart';
import 'package:infibo_app/translation/app_translations.dart';
import 'package:infibo_app/pages/choseusers/ui.dart';
import 'package:infibo_app/pages/customized/customizedPage/mailun/ui.dart';
import 'package:infibo_app/pages/customized/customizedPage/ui.dart';
import 'package:infibo_app/pages/customized/ui.dart';
import 'package:infibo_app/pages/login/login/ui.dart';
import 'package:infibo_app/pages/main/ui.dart';
import 'package:infibo_app/pages/music/ui.dart';
import 'package:infibo_app/pages/settingpage/history_detail.dart';
import 'package:infibo_app/pages/settingpage/ui.dart';
import 'package:infibo_app/pages/start/ui.dart';
import 'package:infibo_app/pages/WifiBluetooth/connection_prompt_controller.dart';
import 'package:infibo_app/pages/WifiBluetooth/connection_prompt_host.dart';

const String _initialRoute = String.fromEnvironment(
  'INFIBO_INITIAL_ROUTE',
  // defaultValue: '/summary',
  //根级路由登录界面，需main.dart中设置。
  defaultValue: '/login',
);

// 获取根级路由
Widget getRootWidget({
  String? initialRoute,
  required Locale locale,
  ConnectionPromptGateway? connectionPromptGateway,
}) {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  return GetMaterialApp(
    navigatorKey: navigatorKey,
    builder: (BuildContext context, Widget? child) {
      return DesignCanvas(
        child: ConnectionPromptHost(
          navigatorKey: navigatorKey,
          gateway: connectionPromptGateway,
          child: child ?? const SizedBox.shrink(),
        ),
      );
    },
    theme: ThemeData(
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(enableFeedback: false),
      ),
    ),

    // 国际化语言配置
    translations: AppTranslations(),
    locale: locale,
    fallbackLocale: const Locale('en', 'US'),
    // 初始路由为登录页
    initialRoute: initialRoute ?? _initialRoute,
    // 国际化配置
    defaultTransition: Transition.noTransition,
    transitionDuration: Duration.zero,
    getPages: getRoutes(),
    navigatorObservers: [GetObserver(), appRouteObserver],
  );
}

List<GetPage> getRoutes() {
  return [
    // 登录页
    GetPage(name: "/login", page: () => const LoginPage()),
    // 注册页
    GetPage(name: "/register", page: () => const RegisterPage()),
    // 忘记密码页
    GetPage(name: "/forgetpassword", page: () => const ForgetPage()),
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
    // 设置页
    GetPage(name: "/setting", page: () => const SettingWidget()),
    GetPage(
      name: "/setting/history-detail",
      page: () => const HistoryDetailPage(),
    ),
    // 总结页
    GetPage(name: "/summary", page: () => const SummaryPage()),
  ];
}
