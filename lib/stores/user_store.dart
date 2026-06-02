// 用户状态管理。
//
// 用于存储用户登录状态、用户信息等。全局保存当前登录用户信息

//用户状态管理，setUser()：登录成功保存用户   loadUser()：App 启动读取用户   clearUser()：退出登录清空用户

import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:infibo_app/api/dio/login/login_models.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserStore extends GetxController {
  static UserStore get instance => Get.find<UserStore>();

  final Rxn<LoginResult> currentUser = Rxn<LoginResult>();

  bool get isLoggedIn => currentUser.value != null;

  int? get userId => currentUser.value?.id;

  // 当前登录账号的邮箱。
  String get email => currentUser.value?.email ?? '';

  String get role => currentUser.value?.role ?? '';

  String get roleText {
    switch (role) {
      case 'admin':
        return '管理员';
      case 'operator':
        return '操作员';
      case 'user':
        return '个人';
      default:
        return '未登录';
    }
  }

  String get avatarText {
    switch (role) {
      case 'admin':
        return 'AD';
      case 'operator':
        return 'OP';
      case 'user':
        return 'US';
      default:
        return '--';
    }
  }

  //保存当前用户信息
  Future<void> setUser(LoginResult user) async {
    currentUser.value = user;
    // 保存用户信息到 SharedPreferences
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // 保存用户ID
    prefs.setInt('userId', user.id);
    // 保存登录邮箱，供 App 下次启动时恢复登录状态。
    prefs.setString('email', user.email);
    // 保存用户角色
    prefs.setString('role', user.role);

    await prefs.setString('isLoggedIn', 'true'); // 保存登录状态
  }

  //启动之前读取上次用户信息
  Future<void> loadUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getString('isLoggedIn') == 'true';

    if (isLoggedIn) {
      final int? userId = prefs.getInt('userId');
      final String? email = prefs.getString('email');
      final String? role = prefs.getString('role');

      if (userId != null && email != null && role != null) {
        currentUser.value = LoginResult(id: userId, email: email, role: role);
      }
    }
  }

  // 退出登录时只清除用户信息，保留其他持久化设置。
  Future<void> clearUser() async {
    currentUser.value = null;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('email');
    // 清理旧版本遗留的手机号登录字段。
    await prefs.remove('phone');
    await prefs.remove('role');
    await prefs.remove('isLoggedIn');
  }
}
