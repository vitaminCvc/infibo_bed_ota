import 'package:infibo_app/api/dio/api/api_client.dart';
import 'package:infibo_app/api/dio/api/api_response.dart';
import 'package:infibo_app/api/dio/therapy_plan/therapy_plan_models.dart';

class TherapyPlanApi {
  Map<String, Object?> _ownerHeaders(int ownerUserId) {
    return <String, Object?>{'X-User-Id': ownerUserId};
  }

  // 查询当前用户的所有自定义方案
  Future<ApiResponse<List<TherapyPlanDto>>> list({required int ownerUserId}) {
    return ApiClient.instance.get<List<TherapyPlanDto>>(
      //查询当前用户的所有自定义方案接口
      '/therapy/plan/custom/list',
      // 自定义请求头
      headers: _ownerHeaders(ownerUserId),
      fromJsonT: (Object? json) {
        //将后端返回的json转换为dart对象
        final List<dynamic> items = json as List<dynamic>? ?? <dynamic>[];

        //将后端返回的json转换为dart对象
        return items
            .map(
              (dynamic item) => TherapyPlanDto.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
      },
    );
  }

  // 查询自定义方案详情
  Future<ApiResponse<TherapyPlanDto>> detail({
    required int ownerUserId,
    required int planId,
  }) {
    return ApiClient.instance.get<TherapyPlanDto>(
      //查询自定义方案详情接口
      '/therapy/plan/custom/$planId',
      // 自定义请求头
      headers: _ownerHeaders(ownerUserId),
      // 将后端返回的json转换为dart对象
      fromJsonT: (Object? json) {
        return TherapyPlanDto.fromJson(Map<String, dynamic>.from(json as Map));
      },
    );
  }

  //新增自定义方案
  Future<ApiResponse<TherapyPlanDto>> create({
    required int ownerUserId,
    required TherapyPlanRequestDto request,
  }) {
    return ApiClient.instance.post<TherapyPlanDto>(
      //新增自定义方案接口
      '/therapy/plan/custom',
      // 自定义请求头
      headers: _ownerHeaders(ownerUserId),
      // 将请求体转换为json
      data: request.toJson(),
      // 将后端返回的json转换为dart对象
      fromJsonT: (Object? json) {
        return TherapyPlanDto.fromJson(Map<String, dynamic>.from(json as Map));
      },
    );
  }

  // 重命名自定义方案
  Future<ApiResponse<void>> rename({
    required int ownerUserId,
    required int planId,
    required String planName,
  }) {
    return ApiClient.instance.put<void>(
      //重命名自定义方案接口
      '/therapy/plan/custom/$planId/name',
      // 自定义请求头
      headers: _ownerHeaders(ownerUserId),
      // 将请求体转换为json
      data: {'planName': planName},
    );
  }

  //更新自定义方案
  Future<ApiResponse<TherapyPlanDto>> update({
    required int ownerUserId,
    required int planId,
    required TherapyPlanRequestDto request,
  }) {
    return ApiClient.instance.put<TherapyPlanDto>(
      //更新自定义方案接口
      '/therapy/plan/custom/$planId',
      // 自定义请求头
      headers: _ownerHeaders(ownerUserId),
      // 将请求体转换为json
      data: request.toJson(),
      // 将后端返回的json转换为dart对象
      fromJsonT: (Object? json) {
        return TherapyPlanDto.fromJson(Map<String, dynamic>.from(json as Map));
      },
    );
  }

  // 删除自定义方案
  Future<ApiResponse<void>> delete({
    required int ownerUserId,
    required int planId,
  }) {
    return ApiClient.instance.delete<void>(
      //删除自定义方案接口
      '/therapy/plan/custom/$planId',
      // 自定义请求头
      headers: _ownerHeaders(ownerUserId),
    );
  }
}
