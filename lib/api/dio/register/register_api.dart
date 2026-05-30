//封装注册接口

import 'package:infibo_app/api/dio/api/api_client.dart';
import 'package:infibo_app/api/dio/api/api_response.dart';
import 'package:infibo_app/api/dio/register/register_models.dart';

class RegisterApi {
  /// 发送验证码
  Future<ApiResponse<void>> sendCode({required String phone}) {
    return ApiClient.instance.post<void>(
      '/sms/send-code',
      data: {'phone': phone},
    );
  }

  /// 注册
  Future<ApiResponse<RegisterResult>> register({
    required String phone,
    required String code,
    required String password,
    required RegisterRole role,
  }) {
    return ApiClient.instance.post<RegisterResult>(
      '/auth/register',
      data: {
        'phone': phone,
        'code': code,
        'password': password,
        'role': role.apiValue,
      },
      fromJsonT: (Object? json) {
        return RegisterResult.fromJson(Map<String, dynamic>.from(json as Map));
      },
    );
  }
}
