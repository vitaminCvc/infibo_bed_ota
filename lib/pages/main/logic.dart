import 'package:get/get.dart';

// 主页面逻辑控制器。
class MainLogic extends GetxController {
  // 模式详情页路由。
  static const String modeDetailRoute = '/modeDetail';

  // 跳转到模式对应页面。
  void openModeDetail(String title) {
    Get.toNamed('/choseusers', arguments: {'modeTitle': title});
  }
}
