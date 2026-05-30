//封装dio网络请求，统一处理网络请求异常
import 'package:dio/dio.dart';
import 'package:infibo_app/api/dio/api/api_response.dart';

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  final Dio _dio = Dio(
    BaseOptions(
      //wifi环境
      // baseUrl: 'http://192.168.1.75:8080',
      //安卓模拟器环境
      baseUrl: 'http://10.0.2.2:8080',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<ApiResponse<T>> post<T>(
    String path, {
    Object? data,
    T Function(Object? json)? fromJsonT,
  }) async {
    try {
      final Response response = await _dio.post(path, data: data);

      final Map<String, dynamic> json = Map<String, dynamic>.from(
        response.data as Map,
      );

      return ApiResponse<T>.fromJson(json, fromJsonT: fromJsonT);
    } on DioException catch (e) {
      return ApiResponse<T>(code: -1, message: e.message ?? '网络请求失败');
    } catch (e) {
      return ApiResponse<T>(code: -1, message: '未知错误：$e');
    }
  }
}
