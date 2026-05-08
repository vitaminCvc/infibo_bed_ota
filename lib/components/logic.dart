// 公共组件辅助逻辑。
//
// 目前主要提供从任意页面回到主页面的统一入口，避免各组件里重复写路由判断。
import 'package:get/get.dart';

// 公共组件逻辑。
class AppComponentLogic {
  // 主页面路由。
  static const String mainRoute = '/main';

  // 返回主页面，当前已经在主页面时不处理。
  static void backToMainPage() {
    if (Get.currentRoute == mainRoute) return;
    Get.offAllNamed(mainRoute);
  }
}
