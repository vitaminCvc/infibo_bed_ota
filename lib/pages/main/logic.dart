import 'package:get/get.dart';

// 主页面逻辑控制器。
class MainLogic extends GetxController {
  // 跳转到模式对应页面。
  void openModeDetail(String title) {
    Get.toNamed('/choseusers', arguments: {'modeTitle': title});
  }
  // 跳转到自定义页面。
  void openCustomizedPage() {
    Get.toNamed('/customized');
  }
}
