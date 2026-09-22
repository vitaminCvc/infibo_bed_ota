import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:infibo_app/api/dio/api/api_response.dart';

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: const String.fromEnvironment(
        'API_BASE_URL',
        // 正式环境
        defaultValue: 'http://192.241.254.196',
        // 国内测试环境
        // defaultValue: 'http://8.138.247.157',
      ),
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      sendTimeout: const Duration(seconds: 10),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, Object?>? headers,
    Map<String, Object?>? queryParameters,
    T Function(Object? json)? fromJsonT,
  }) async {
    try {
      final Response response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: Options(headers: headers),
      );
      return ApiResponse<T>.fromJson(
        _responseJson(response),
        fromJsonT: fromJsonT,
      );
    } on DioException {
      return ApiResponse<T>(code: -1, message: 'network_error'.tr);
    } catch (e) {
      return ApiResponse<T>(code: -1, message: '${'unknown_error'.tr}: $e');
    }
  }

  Future<ApiResponse<T>> post<T>(
    String path, {
    Object? data,
    Map<String, Object?>? headers,
    T Function(Object? json)? fromJsonT,
  }) async {
    try {
      final Response response = await _dio.post(
        path,
        data: data,
        options: Options(headers: headers),
      );
      return ApiResponse<T>.fromJson(
        _responseJson(response),
        fromJsonT: fromJsonT,
      );
    } on DioException {
      return ApiResponse<T>(code: -1, message: 'network_error'.tr);
    } catch (e) {
      return ApiResponse<T>(code: -1, message: '${'unknown_error'.tr}: $e');
    }
  }

  Future<ApiResponse<T>> delete<T>(
    String path, {
    Map<String, Object?>? headers,
    T Function(Object? json)? fromJsonT,
  }) async {
    try {
      final Response response = await _dio.delete(
        path,
        options: Options(headers: headers),
      );
      return ApiResponse<T>.fromJson(
        _responseJson(response),
        fromJsonT: fromJsonT,
      );
    } on DioException {
      return ApiResponse<T>(code: -1, message: 'network_error'.tr);
    } catch (e) {
      return ApiResponse<T>(code: -1, message: '${'unknown_error'.tr}: $e');
    }
  }

  Future<ApiResponse<T>> put<T>(
    String path, {
    Object? data,
    Map<String, Object?>? headers,
    T Function(Object? json)? fromJsonT,
  }) async {
    try {
      final Response response = await _dio.put(
        path,
        data: data,
        options: Options(headers: headers),
      );
      return ApiResponse<T>.fromJson(
        _responseJson(response),
        fromJsonT: fromJsonT,
      );
    } on DioException {
      return ApiResponse<T>(code: -1, message: 'network_error'.tr);
    } catch (e) {
      return ApiResponse<T>(code: -1, message: '${'unknown_error'.tr}: $e');
    }
  }

  Map<String, dynamic> _responseJson(Response response) {
    return Map<String, dynamic>.from(response.data as Map);
  }
}
