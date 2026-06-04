import 'package:infibo_app/api/dio/api/api_client.dart';
import 'package:infibo_app/api/dio/api/api_response.dart';

class ResetPasswordApi {
  /// 发送重置密码验证码方法
  Future<ApiResponse<String>> sendResetCode({required String email}) {
    return ApiClient.instance.post<String>(
      '/email/send-reset-code',
      data: {'email': email},
      fromJsonT: (Object? json) => json?.toString() ?? '',
    );
  }

  /// 重置密码方法
  Future<ApiResponse<void>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) {
    return ApiClient.instance.post<void>(
      '/auth/reset-password',
      data: {'email': email, 'code': code, 'newPassword': newPassword},
    );
  }
}
