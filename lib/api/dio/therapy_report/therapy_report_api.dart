import 'package:infibo_app/api/dio/api/api_client.dart';
import 'package:infibo_app/api/dio/api/api_response.dart';
import 'package:infibo_app/api/dio/therapy_report/therapy_report_models.dart';

class TherapyReportApi {
  // 保存治疗记录报告方法
  Future<ApiResponse<Map<String, dynamic>>> save({
    required int ownerUserId,
    required SaveTherapyReportRequestDto request,
  }) {
    return ApiClient.instance.post<Map<String, dynamic>>(
      '/therapy/report',
      headers: <String, Object?>{'X-User-Id': ownerUserId},
      data: request.toJson(),
      fromJsonT: (Object? json) {
        return Map<String, dynamic>.from(json as Map);
      },
    );
  }

  // 获取治疗记录报告用户列表方法
  Future<ApiResponse<HistoryReportUserPageDto>> historyUsers({
    required int ownerUserId,
    required int page,
    int pageSize = 10,
    String keyword = '',
  }) {
    return ApiClient.instance.get<HistoryReportUserPageDto>(
      '/therapy/report/history/users',
      headers: <String, Object?>{'X-User-Id': ownerUserId},
      queryParameters: <String, Object?>{
        'page': page,
        'pageSize': pageSize,
        if (keyword.trim().isNotEmpty) 'keyword': keyword.trim(),
      },
      fromJsonT: (Object? json) {
        return HistoryReportUserPageDto.fromJson(
          Map<String, dynamic>.from(json as Map),
        );
      },
    );
  }

  // 获取治疗记录报告详情方法
  Future<ApiResponse<TherapyReportDetailDto>> detail({
    required int ownerUserId,
    required int reportId,
  }) {
    return ApiClient.instance.get<TherapyReportDetailDto>(
      '/therapy/report/$reportId',
      headers: <String, Object?>{'X-User-Id': ownerUserId},
      fromJsonT: (Object? json) {
        return TherapyReportDetailDto.fromJson(
          Map<String, dynamic>.from(json as Map),
        );
      },
    );
  }

  // 获取某个理疗用户的报告详情分页列表方法
  Future<ApiResponse<TherapyReportDetailPageDto>> historyUserReports({
    required int ownerUserId,
    required int clientId,
    required int page,
    int pageSize = 5,
  }) {
    return ApiClient.instance.get<TherapyReportDetailPageDto>(
      '/therapy/report/history/users/$clientId/reports',
      headers: <String, Object?>{'X-User-Id': ownerUserId},
      queryParameters: <String, Object?>{
        'page': page,
        'pageSize': pageSize,
      },
      fromJsonT: (Object? json) {
        return TherapyReportDetailPageDto.fromJson(
          Map<String, dynamic>.from(json as Map),
        );
      },
    );
  }

  Future<ApiResponse<void>> deleteHistoryUser({
    required int ownerUserId,
    required int clientId,
  }) {
    return ApiClient.instance.delete<void>(
      '/therapy/report/history/users/$clientId',
      headers: <String, Object?>{'X-User-Id': ownerUserId},
    );
  }
}
