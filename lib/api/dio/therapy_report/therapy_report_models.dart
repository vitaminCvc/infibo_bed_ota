//创建保存疗程报告请求DTO
class SaveTherapyReportRequestDto {
  const SaveTherapyReportRequestDto({
    required this.clientId,
    this.planId,
    required this.planName,
    required this.planType,
    required this.reportTime,
    required this.durationMinutes,
    required this.usedModulesJson,
    this.energyScore = 0,
    this.cellScore = 0,
    this.relaxScore = 0,
    this.immuneScore = 0,
    this.scoreAlgorithmVersion = 'frontend-v1',
    this.scoreDetailJson = '{}',
    required this.therapyFeedback,
    required this.modules,
    this.vitals = const [],
  });
  final int clientId;
  final int? planId;
  final String planName;
  final String planType;

  // 前端生成的疗程报告时间。
  final DateTime reportTime;

  final int durationMinutes;
  final String usedModulesJson;
  final String therapyFeedback;
  final List<ReportModuleRequestDto> modules;
  final int energyScore;
  final int cellScore;
  final int relaxScore;
  final int immuneScore;
  final String scoreAlgorithmVersion;
  final String scoreDetailJson;
  final List<Map<String, Object?>> vitals;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'clientId': clientId,
      'planId': planId,
      'planName': planName,
      'planType': planType,
      // 将Dart里的DateTime时间对象转换成后端能接收的字符串格式，之后放入Json中
      'reportTime': reportTime.toIso8601String(),
      'durationMinutes': durationMinutes,
      'usedModulesJson': usedModulesJson,
      'energyScore': energyScore,
      'cellScore': cellScore,
      'relaxScore': relaxScore,
      'immuneScore': immuneScore,
      'scoreAlgorithmVersion': scoreAlgorithmVersion,
      'scoreDetailJson': scoreDetailJson,
      'therapyFeedback': therapyFeedback,
      'modules': modules.map((item) => item.toJson()).toList(),
      'vitals': vitals,
    };
  }
}

//创建疗程报告模块请求DTO
class ReportModuleRequestDto {
  const ReportModuleRequestDto({
    required this.moduleCode,
    required this.moduleName,
    required this.runDurationMinutes,
    required this.runStatus,
    this.paramsJson = '{}',
  });

  final String moduleCode;
  final String moduleName;
  final int runDurationMinutes;
  final String runStatus;
  final String paramsJson;

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'moduleCode': moduleCode,
      'moduleName': moduleName,
      'runDurationMinutes': runDurationMinutes,
      'runStatus': runStatus,
      'paramsJson': paramsJson,
    };
  }
}
