//创建保存疗程报告请求DTO
class SaveTherapyReportRequestDto {
  const SaveTherapyReportRequestDto({
    required this.clientId,
    this.planId,
    required this.planName,
    required this.planType,
    required this.reportTime,
    required this.durationSeconds,
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

  final int durationSeconds;
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
      'durationSeconds': durationSeconds,
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

//创建历史记录报告用户项DTO
// 用于获取用户历史记录报告的用户项
class HistoryReportUserItemDto {
  const HistoryReportUserItemDto({
    required this.clientId,
    required this.userName,
    this.userGender,
    this.userAge,
    required this.userPhone,
    required this.lastReportId,
    required this.lastReportTime,
  });

  final int clientId;
  final String userName;
  final String? userGender;
  final int? userAge;
  final String userPhone;
  final int lastReportId;
  final DateTime lastReportTime;

  //工厂函数，转换为json模式
  factory HistoryReportUserItemDto.fromJson(Map<String, dynamic> json) {
    return HistoryReportUserItemDto(
      clientId: int.tryParse(json['clientId']?.toString() ?? '') ?? 0,
      userName: json['userName']?.toString() ?? '',
      userGender: json['userGender']?.toString() ?? '',
      userAge: int.tryParse(json['userAge']?.toString() ?? ''),
      userPhone: json['userPhone']?.toString() ?? '',
      lastReportId: int.tryParse(json['lastReportId']?.toString() ?? '') ?? 0,
      lastReportTime:
          DateTime.tryParse(json['lastReportTime']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}

//创建历史记录报告用户分页DTO
// 用于获取用户历史记录报告的分页数据
class HistoryReportUserPageDto {
  const HistoryReportUserPageDto({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.hasMore,
  });

  final List<HistoryReportUserItemDto> items;
  final int page;
  final int pageSize;
  final int total;
  final bool hasMore;

  //工厂函数，转换为json模式
  factory HistoryReportUserPageDto.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawItems =
        json['items'] as List<dynamic>? ?? <dynamic>[];

    return HistoryReportUserPageDto(
      items: rawItems
          .map(
            (dynamic item) => HistoryReportUserItemDto.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      page: int.tryParse(json['page']?.toString() ?? '') ?? 1,
      pageSize: int.tryParse(json['pageSize']?.toString() ?? '') ?? 10,
      total: int.tryParse(json['total']?.toString() ?? '') ?? 0,
      hasMore: json['hasMore'] == true,
    );
  }
}

class TherapyReportDto {
  const TherapyReportDto({
    required this.reportId,
    required this.clientId,
    required this.userNameSnapshot,
    this.userAgeSnapshot,
    required this.userPhoneSnapshot,
    this.planNameSnapshot = '',
    required this.reportTime,
    required this.durationSeconds,
    this.energyScore = 0,
    this.cellScore = 0,
    this.relaxScore = 0,
    this.immuneScore = 0,
    this.therapyFeedback = '',
  });

  final int reportId;
  final int clientId;
  final String userNameSnapshot;
  final int? userAgeSnapshot;
  final String userPhoneSnapshot;
  final String planNameSnapshot;
  final DateTime reportTime;
  final int durationSeconds;
  final int energyScore;
  final int cellScore;
  final int relaxScore;
  final int immuneScore;
  final String therapyFeedback;

  factory TherapyReportDto.fromJson(Map<String, dynamic> json) {
    return TherapyReportDto(
      reportId: int.tryParse(json['reportId']?.toString() ?? '') ?? 0,
      clientId: int.tryParse(json['clientId']?.toString() ?? '') ?? 0,
      userNameSnapshot: json['userNameSnapshot']?.toString() ?? '',
      userAgeSnapshot: int.tryParse(json['userAgeSnapshot']?.toString() ?? ''),
      userPhoneSnapshot: json['userPhoneSnapshot']?.toString() ?? '',
      planNameSnapshot: json['planNameSnapshot']?.toString() ?? '',
      reportTime:
          DateTime.tryParse(json['reportTime']?.toString() ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      durationSeconds:
          int.tryParse(json['durationSeconds']?.toString() ?? '') ?? 0,
      energyScore: int.tryParse(json['energyScore']?.toString() ?? '') ?? 0,
      cellScore: int.tryParse(json['cellScore']?.toString() ?? '') ?? 0,
      relaxScore: int.tryParse(json['relaxScore']?.toString() ?? '') ?? 0,
      immuneScore: int.tryParse(json['immuneScore']?.toString() ?? '') ?? 0,
      therapyFeedback: json['therapyFeedback']?.toString() ?? '',
    );
  }
}

class TherapyReportModuleDto {
  const TherapyReportModuleDto({
    required this.moduleCode,
    required this.moduleName,
    required this.runDurationMinutes,
    required this.runStatus,
  });

  final String moduleCode;
  final String moduleName;
  final int runDurationMinutes;
  final String runStatus;

  factory TherapyReportModuleDto.fromJson(Map<String, dynamic> json) {
    return TherapyReportModuleDto(
      moduleCode: json['moduleCode']?.toString() ?? '',
      moduleName: json['moduleName']?.toString() ?? '',
      runDurationMinutes:
          int.tryParse(json['runDurationMinutes']?.toString() ?? '') ?? 0,
      runStatus: json['runStatus']?.toString() ?? '',
    );
  }
}

class TherapyReportVitalDto {
  const TherapyReportVitalDto({
    required this.vitalCode,
    required this.vitalName,
    required this.vitalValue,
    required this.vitalUnit,
  });

  final String vitalCode;
  final String vitalName;
  final String vitalValue;
  final String vitalUnit;

  factory TherapyReportVitalDto.fromJson(Map<String, dynamic> json) {
    return TherapyReportVitalDto(
      vitalCode: json['vitalCode']?.toString() ?? '',
      vitalName: json['vitalName']?.toString() ?? '',
      vitalValue: json['vitalValue']?.toString() ?? '',
      vitalUnit: json['vitalUnit']?.toString() ?? '',
    );
  }
}

class TherapyReportDetailDto {
  const TherapyReportDetailDto({
    required this.report,
    required this.modules,
    required this.vitals,
  });

  final TherapyReportDto report;
  final List<TherapyReportModuleDto> modules;
  final List<TherapyReportVitalDto> vitals;

  factory TherapyReportDetailDto.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawModules =
        json['modules'] as List<dynamic>? ?? <dynamic>[];
    final List<dynamic> rawVitals =
        json['vitals'] as List<dynamic>? ?? <dynamic>[];

    return TherapyReportDetailDto(
      report: TherapyReportDto.fromJson(
        Map<String, dynamic>.from(
          json['report'] as Map? ?? <String, dynamic>{},
        ),
      ),
      modules: rawModules
          .map(
            (dynamic item) => TherapyReportModuleDto.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      vitals: rawVitals
          .map(
            (dynamic item) => TherapyReportVitalDto.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
  }
}

class TherapyReportDetailPageDto {
  const TherapyReportDetailPageDto({
    required this.items,
    required this.page,
    required this.pageSize,
    required this.total,
    required this.hasMore,
  });

  final List<TherapyReportDetailDto> items;
  final int page;
  final int pageSize;
  final int total;
  final bool hasMore;

  factory TherapyReportDetailPageDto.fromJson(Map<String, dynamic> json) {
    final List<dynamic> rawItems =
        json['items'] as List<dynamic>? ?? <dynamic>[];

    return TherapyReportDetailPageDto(
      items: rawItems
          .map(
            (dynamic item) => TherapyReportDetailDto.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      page: int.tryParse(json['page']?.toString() ?? '') ?? 1,
      pageSize: int.tryParse(json['pageSize']?.toString() ?? '') ?? 5,
      total: int.tryParse(json['total']?.toString() ?? '') ?? 0,
      hasMore: json['hasMore'] == true,
    );
  }
}
