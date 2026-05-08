// 主页面导航逻辑。
//
// 负责打开预设模式的用户选择页，以及进入自定义方案列表页。
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
