// 登录页跳转逻辑。
//
// 当前版本还没有接后端鉴权，调用 login() 后直接进入主页面。
import 'package:get/get.dart';

class LoginLogic extends GetxController {
  void login() {
    Get.offNamed('/main');
  }
}
