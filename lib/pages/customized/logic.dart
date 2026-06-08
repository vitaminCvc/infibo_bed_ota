// 自定义方案列表页的数据库逻辑。
//
// 负责保存方案名和 featureIds 字符串列表，并提供新增、编辑、删除、搜索、选择方案等方法。
import 'dart:convert';

import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:infibo_app/api/dio/api/api_response.dart';
import 'package:infibo_app/api/dio/therapy_plan/therapy_plan_api.dart';
import 'package:infibo_app/api/dio/therapy_plan/therapy_plan_models.dart';
import 'package:infibo_app/stores/user_store.dart';

// 自定义方案列表逻辑。
class CustomizedLogic {
  static const String editRoute = '/customized/edit';
  static const String choseUsersRoute = '/choseusers';

  final List<CustomizedPlanData> plans = [];

  int? highlightedIndex;

  // /////自定义方案页与后端联调：preload 方法名保留，不需要改外部调用。
  // /////等 loadPlans 改成后端 GET 后，这里仍然写 await CustomizedLogic().init();。
  static Future<void> preload() async {
    try {
      await CustomizedLogic().init();
    } catch (error, stackTrace) {
      debugPrint('自定义方案预加载失败: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  // /////自定义方案页与后端联调：这个 init 后面要改。
  // /////以后只从后端读取自定义方案，不再创建本地库，也不再写默认自定义方案。
  Future<void> init() async {
    await loadPlans();
  }

  Future<void> loadPlans() async {
    final int ownerUserId = _currentOwnerUserId();

    final ApiResponse<List<TherapyPlanDto>> response = await TherapyPlanApi()
        .list(ownerUserId: ownerUserId);

    if (!response.isSuccess) {
      throw CustomizedPlanNameException(response.message);
    }

    plans
      ..clear()
      ..addAll(
        (response.data ?? <TherapyPlanDto>[]).map(CustomizedPlanData.fromDto),
      );

    highlightedIndex = null;
  }

  /// 新增自定义方案
  Future<void> addPlan({
    required int durationMinutes,
    required String name,
    required List<String> featureIds,
  }) async {
    final int ownerUserId = _currentOwnerUserId();

    final String trimmedName = name.trim();
    final String? errorText = validatePlanName(trimmedName);
    if (errorText != null) throw CustomizedPlanNameException(errorText);

    final ApiResponse<TherapyPlanDto> response = await TherapyPlanApi().create(
      ownerUserId: ownerUserId,
      request: TherapyPlanRequestDto(
        planName: trimmedName,
        durationMinutes: durationMinutes,
        usedModulesJson: jsonEncode(featureIds),
        planConfigJson: jsonEncode(<String, Object?>{'featureIds': featureIds}),
      ),
    );

    if (!response.isSuccess || response.data == null) {
      throw CustomizedPlanNameException(response.message);
    }

    plans.add(CustomizedPlanData.fromDto(response.data!));
    highlightedIndex = null;
  }

  Future<void> updatePlan({
    required CustomizedPlanData plan,
    required int durationMinutes,
  }) async {
    if (plan.id == null) return;

    final int ownerUserId = _currentOwnerUserId();

    final String trimmedName = plan.name.trim();
    final String? errorText = validatePlanName(trimmedName, excludeId: plan.id);
    if (errorText != null) throw CustomizedPlanNameException(errorText);

    final ApiResponse<TherapyPlanDto> response = await TherapyPlanApi().update(
      ownerUserId: ownerUserId,
      planId: plan.id!,
      request: TherapyPlanRequestDto(
        planName: trimmedName,
        durationMinutes: durationMinutes,
        usedModulesJson: jsonEncode(plan.featureIds),
        planConfigJson: jsonEncode(<String, Object?>{
          'featureIds': plan.featureIds,
        }),
      ),
    );

    if (!response.isSuccess || response.data == null) {
      throw CustomizedPlanNameException(response.message);
    }

    await loadPlans();
  }

  // /////自定义方案页与后端联调：这个方法后面可先接重命名接口。
  Future<void> renamePlan(int index, String name) async {
    final CustomizedPlanData plan = plans[index].copyWith(name: name.trim());
    if (plan.id == null) return;

    final ApiResponse<void> response = await TherapyPlanApi().rename(
      ownerUserId: _currentOwnerUserId(),
      planId: plan.id!,
      planName: plan.name,
    );
    if (!response.isSuccess) {
      throw CustomizedPlanNameException(response.message);
    }

    await loadPlans();
  }

  // /////自定义方案页与后端联调：这个方法可以保留。
  // /////前端本地校验用于即时提示，但最终仍要以后端返回结果为准，避免多设备同时创建重名方案。
  String? validatePlanName(String name, {int? excludeId}) {
    final String text = name.trim();
    if (text.isEmpty) return '方案名称不能为空';

    final bool isDuplicated = plans.any(
      (plan) => plan.id != excludeId && plan.name.trim() == text,
    );
    if (isDuplicated) return '方案名称不能重复';

    return null;
  }

  // /////自定义方案页与后端联调：这个方法要整体改成 DELETE /therapy/plan/custom/{planId}。
  Future<void> deletePlan(int index) async {
    final int ownerUserId = _currentOwnerUserId();

    final CustomizedPlanData plan = plans[index];

    if (plan.id != null) {
      final ApiResponse<void> response = await TherapyPlanApi().delete(
        ownerUserId: ownerUserId,
        planId: plan.id!,
      );

      if (!response.isSuccess) {
        throw CustomizedPlanNameException(response.message);
      }
    }

    plans.removeAt(index);

    if (highlightedIndex == index) {
      highlightedIndex = null;
    } else if (highlightedIndex != null && highlightedIndex! > index) {
      highlightedIndex = highlightedIndex! - 1;
    }
  }

  int findPlanIndex(String keyword) {
    final String text = keyword.trim();
    if (text.isEmpty) return -1;

    final int exactIndex = plans.indexWhere((plan) => plan.name.trim() == text);
    if (exactIndex >= 0) return exactIndex;

    final int prefixIndex = plans.indexWhere(
      (plan) => plan.name.trim().startsWith(text),
    );
    if (prefixIndex >= 0) return prefixIndex;

    return plans.indexWhere((plan) => plan.name.contains(text));
  }

  void highlightPlan(int index) {
    highlightedIndex = index;
  }

  // /////自定义方案页与后端联调：这里保留 await loadPlans()。
  // /////等 loadPlans 改成后端 GET 后，新增页返回时会自动刷新 MySQL 数据。
  Future<bool> openAddPage() async {
    final Object? result = await Get.toNamed(editRoute);
    await loadPlans();
    return result == true;
  }

  // /////自定义方案页与后端联调：这里不用大改。
  // /////但要确认 plan.id 后面已经是后端 planId，不再是 SQLite id。
  Future<bool> openEditPage(CustomizedPlanData plan) async {
    final Object? result = await Get.toNamed(
      editRoute,
      arguments: {'plan': plan},
    );
    await loadPlans();
    return result == true;
  }

  // /////自定义方案页与后端联调：这里只传 planId，不传完整 customizedPlan。

  void selectPlan(CustomizedPlanData plan) {
    Get.toNamed(
      choseUsersRoute,
      arguments: {'modeTitle': plan.name, 'customizedPlan': plan},
    );
  }

  Future<void> dispose() async {
    // 后端接口模式下，不需要关闭本地数据库连接。
  }

  //查询当前用户ID
  int _currentOwnerUserId() {
    final int? ownerUserId = UserStore.instance.userId;
    if (ownerUserId == null) {
      throw const CustomizedPlanNameException('用户未登录，请重新登录');
    }
    return ownerUserId;
  }
}

class CustomizedPlanNameException implements Exception {
  const CustomizedPlanNameException(this.message);

  final String message;

  @override
  String toString() => message;
}

class CustomizedPlanData {
  const CustomizedPlanData({
    this.id,
    required this.name,
    required this.featureIds,
  });

  final int? id;
  final String name;
  final List<String> featureIds;

  // /////自定义方案页与后端联调：这个 fromMap 后面改成 fromDto。
  // /////删掉 fromMap 里的 feature_ids 解析。
  // /////新增类似：
  // /////  factory CustomizedPlanData.fromDto(TherapyPlanDto dto) {
  // /////    return CustomizedPlanData(
  // /////      id: dto.planId,
  // /////      name: dto.planName,
  // /////      featureIds: decodeFeatureIds(dto.planConfigJson),
  // /////    );
  // /////  }
  factory CustomizedPlanData.fromDto(TherapyPlanDto dto) {
    return CustomizedPlanData(
      id: dto.planId,
      name: dto.planName,
      featureIds: decodeFeatureIds(
        planConfigJson: dto.planConfigJson,
        usedModulesJson: dto.usedModulesJson,
      ),
    );
  }

  static List<String> decodeFeatureIds({
    required String planConfigJson,
    required String usedModulesJson,
  }) {
    try {
      final dynamic decoded = jsonDecode(planConfigJson);

      if (decoded is Map<String, dynamic>) {
        final dynamic featureIds = decoded['featureIds'];

        if (featureIds is List) {
          return featureIds
              .map((dynamic item) => item.toString())
              .where((String item) => item.trim().isNotEmpty)
              .toList();
        }
      }
    } catch (_) {
      // planConfigJson 解析失败时，继续尝试 usedModulesJson。
    }

    try {
      final dynamic decoded = jsonDecode(usedModulesJson);

      if (decoded is List) {
        return decoded
            .map((dynamic item) => item.toString())
            .where((String item) => item.trim().isNotEmpty)
            .toList();
      }
    } catch (_) {
      // usedModulesJson 也解析失败时，返回空列表。
    }

    return <String>[];
  }

  CustomizedPlanData copyWith({
    int? id,
    String? name,
    List<String>? featureIds,
  }) {
    return CustomizedPlanData(
      id: id ?? this.id,
      name: name ?? this.name,
      featureIds: featureIds ?? this.featureIds,
    );
  }
}
