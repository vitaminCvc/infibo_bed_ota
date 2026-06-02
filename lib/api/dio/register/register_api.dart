//封装注册接口

import 'package:infibo_app/api/dio/api/api_client.dart';
import 'package:infibo_app/api/dio/api/api_response.dart';
import 'package:infibo_app/api/dio/register/register_models.dart';

class RegisterApi {
  /// 发送验证码
  Future<ApiResponse<String>> sendCode({required String email}) {
    return ApiClient.instance.post<String>(
      // 邮箱验证码接口需要后端提供对应路由。
      '/email/send-code',
      data: {'email': email},
      fromJsonT: (Object? json) {
        return json?.toString() ?? '';
      },
    );
  }

  /// 注册
  Future<ApiResponse<void>> register({
    required String email,
    required String code,
    required String password,
    required RegisterRole role,
  }) {
    return ApiClient.instance.post<void>(
      '/auth/register',
      data: {
        'email': email,
        'code': code,
        'password': password,
        'role': role.apiValue,
      },
    );
  }
}
