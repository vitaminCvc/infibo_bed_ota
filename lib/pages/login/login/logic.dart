// 登录页跳转逻辑。
//
// 后端登录成功后，调用 login() 进入主页面。
import 'package:get/get.dart';

class LoginLogic extends GetxController {
  void login() {
    Get.offNamed('/main');
  }
}
