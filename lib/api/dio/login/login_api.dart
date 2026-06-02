// 登录相关 API 接口。
//
// 这里集中导出登录相关的网络请求接口，避免在页面中重复编写。
// 这里定义了登录、注册、获取验证码等登录相关接口。

import 'package:infibo_app/api/dio/api/api_client.dart';
import 'package:infibo_app/api/dio/api/api_response.dart';
import 'package:infibo_app/api/dio/login/login_models.dart';

class LoginApi {
  /// 登录
  Future<ApiResponse<LoginResult>> login({
    required String email,
    required String password,
  }) {
    return ApiClient.instance.post<LoginResult>(
      '/auth/login',
      // 登录账号已经从手机号切换为邮箱，发送给后端的字段也同步改为 email。
      data: {'email': email, 'password': password},
      fromJsonT: (Object? json) {
        return LoginResult.fromJson(Map<String, dynamic>.from(json as Map));
      },
    );
  }
}
