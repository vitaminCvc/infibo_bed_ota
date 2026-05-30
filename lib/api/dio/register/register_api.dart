//封装注册接口

import 'package:infibo_app/api/dio/api/api_client.dart';
import 'package:infibo_app/api/dio/api/api_response.dart';
import 'package:infibo_app/api/dio/register/register_models.dart';

class RegisterApi {
  /// 发送验证码
  Future<ApiResponse<String>> sendCode({required String phone}) {
    return ApiClient.instance.post<String>(
      '/sms/send-code',
      data: {'phone': phone},
      fromJsonT: (Object? json) {
        return json?.toString() ?? '';
      },
    );
  }

  /// 注册
  Future<ApiResponse<void>> register({
    required String phone,
    required String code,
    required String password,
    required RegisterRole role,
  }) {
    return ApiClient.instance.post<void>(
      '/auth/register',
      data: {
        'phone': phone,
        'code': code,
        'password': password,
        'role': role.apiValue,
      },
    );
  }
}
