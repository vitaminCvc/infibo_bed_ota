// /////自定义方案页与后端联调：这个文件负责定义自定义方案接口用到的数据模型。
// /////参考文件：
// /////  lib/api/dio/therapy_client/therapy_client_models.dart
// /////这里建议新增两个类：
// /////  TherapyPlanDto
// /////  TherapyPlanRequestDto

// /////第一步：新增 TherapyPlanDto。
// /////这个类用来解析后端返回的 therapy_plan 数据。
// /////字段建议：
// /////  final int planId;
// /////  final String planName;
// /////  final int durationMinutes;
// /////  final String usedModulesJson;
// /////  final String planConfigJson;
// /////  final int status;
// /////代码建议：
// /////  class TherapyPlanDto {
// /////    const TherapyPlanDto({
// /////      required this.planId,
// /////      required this.planName,
// /////      required this.durationMinutes,
// /////      required this.usedModulesJson,
// /////      required this.planConfigJson,
// /////      required this.status,
// /////    });
// /////
// /////    final int planId;
// /////    final String planName;
// /////    final int durationMinutes;
// /////    final String usedModulesJson;
// /////    final String planConfigJson;
// /////    final int status;
// /////  }

// /////第二步：在 TherapyPlanDto 里面新增 fromJson。
// /////后端返回字段一般是驼峰 JSON：
// /////  planId、planName、durationMinutes、usedModulesJson、planConfigJson、status
// /////代码建议：
// /////  factory TherapyPlanDto.fromJson(Map<String, dynamic> json) {
// /////    return TherapyPlanDto(
// /////      planId: int.tryParse(json['planId']?.toString() ?? '') ?? 0,
// /////      planName: json['planName']?.toString() ?? '',
// /////      durationMinutes: int.tryParse(json['durationMinutes']?.toString() ?? '') ?? 30,
// /////      usedModulesJson: json['usedModulesJson']?.toString() ?? '[]',
// /////      planConfigJson: json['planConfigJson']?.toString() ?? '{}',
// /////      status: int.tryParse(json['status']?.toString() ?? '') ?? 1,
// /////    );
// /////  }

// /////第三步：新增 TherapyPlanRequestDto。
// /////这个类用来新增或更新自定义方案时发送给后端。
// /////字段建议：
// /////  final String planName;
// /////  final int durationMinutes;
// /////  final String usedModulesJson;
// /////  final String planConfigJson;
// /////代码建议：
// /////  class TherapyPlanRequestDto {
// /////    const TherapyPlanRequestDto({
// /////      required this.planName,
// /////      required this.durationMinutes,
// /////      required this.usedModulesJson,
// /////      required this.planConfigJson,
// /////    });
// /////
// /////    final String planName;
// /////    final int durationMinutes;
// /////    final String usedModulesJson;
// /////    final String planConfigJson;
// /////  }

// /////第四步：在 TherapyPlanRequestDto 里面新增 toJson。
// /////代码建议：
// /////  Map<String, Object?> toJson() {
// /////    return <String, Object?>{
// /////      'planName': planName,
// /////      'durationMinutes': durationMinutes,
// /////      'usedModulesJson': usedModulesJson,
// /////      'planConfigJson': planConfigJson,
// /////    };
// /////  }

// /////第五步：featureIds 建议放到 planConfigJson。
// /////当前 CustomizedPlanData.featureIds 是字符串数组，例如：
// /////  ["phase:0:redlight|pemf", "redlight:0:...", "pemf:0:..."]
// /////保存时建议：
// /////  planConfigJson: jsonEncode({'featureIds': featureIds})
// /////读取时建议：
// /////  final decoded = jsonDecode(dto.planConfigJson);
// /////  final featureIds = decoded['featureIds'];

// /////第六步：usedModulesJson 只放模块摘要，不放完整参数。
// /////例如：
// /////  ["redlight", "pemf", "vat", "hydrogen", "expand"]
// /////完整参数仍然放在 planConfigJson。

import 'package:flutter/foundation.dart';

//创建自定义方案数据模型
class TherapyPlanDto {
  const TherapyPlanDto({
    required this.planId,
    required this.planName,
    required this.durationMinutes,
    required this.usedModulesJson,
    required this.planConfigJson,
    required this.status,
  });

  final int planId;
  final String planName;
  final int durationMinutes;
  final String usedModulesJson;
  final String planConfigJson;
  final int status;
  factory TherapyPlanDto.fromJson(Map<String, dynamic> json) {
    return TherapyPlanDto(
      planId: int.tryParse(json['planId']?.toString() ?? '') ?? 0,
      planName: json['planName']?.toString() ?? '',
      durationMinutes:
          int.tryParse(json['durationMinutes']?.toString() ?? '') ?? 30,
      usedModulesJson: json['usedModulesJson']?.toString() ?? '[]',
      planConfigJson: json['planConfigJson']?.toString() ?? '{}',
      status: int.tryParse(json['status']?.toString() ?? '') ?? 1,
    );
  }
}

//创建自定义方案请求数据模型
class TherapyPlanRequestDto {
  const TherapyPlanRequestDto({
    required this.planName,
    required this.durationMinutes,
    required this.usedModulesJson,
    required this.planConfigJson,
  });

  final String planName;
  final int durationMinutes;
  final String usedModulesJson;
  final String planConfigJson;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'planName': planName,
      'durationMinutes': durationMinutes,
      'usedModulesJson': usedModulesJson,
      'planConfigJson': planConfigJson,
    };
  }
}
