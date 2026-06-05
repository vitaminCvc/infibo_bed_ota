// 自定义方案列表页的本地数据库逻辑。
//
// 负责保存方案名和 featureIds 字符串列表，并提供新增、编辑、删除、搜索、选择方案等方法。
import 'package:get/get.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// 自定义方案列表逻辑。
/////自定义方案页与后端联调，之后这里要删除 sqflite/path 依赖和 infibo_app.db/customized_plans 状态，改成后端仓库或 API 成员变量。
class CustomizedLogic {
  static const String _databaseName = 'infibo_app.db';
  static const String _tableName = 'customized_plans';
  static const String editRoute = '/customized/edit';
  static const String choseUsersRoute = '/choseusers';
  static Database? _sharedDatabase;
  static Future<Database>? _openingDatabase;
  static bool _didEnsureSchema = false;

  final List<CustomizedPlanData> plans = [];

  int? highlightedIndex;

  /////自定义方案页与后端联调，之后预加载要调用后端方案列表接口，不再打开本地 SQLite。
  static Future<void> preload() async {
    try {
      await CustomizedLogic().init();
    } catch (error, stackTrace) {
      debugPrint('Customized database preload failed: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  /////自定义方案页与后端联调，之后 init 只需要调用 loadPlans；loadPlans 内部从 GET /therapy/plan/custom/list 取数据。
  Future<void> init() async {
    await _openDatabaseIfNeeded();
    await loadPlans();
    await _seedDefaultPlansIfNeeded();
  }

  /////自定义方案页与后端联调，之后整个本地数据库打开逻辑可以删除，换成类似选择用户页的 BackendCustomizedPlanRepository。
  Future<void> _openDatabaseIfNeeded() async {
    if (_sharedDatabase?.isOpen == true) {
      if (!_didEnsureSchema) {
        await _createPlansTable(_sharedDatabase!);
        _didEnsureSchema = true;
      }
      return;
    }

    _openingDatabase ??= _openSharedDatabase();
    _sharedDatabase = await _openingDatabase;
    _openingDatabase = null;
  }

  /////自定义方案页与后端联调，之后这里不再创建 infibo_app.db，数据库由后端 MySQL 的 therapy_plan 表负责。
  Future<Database> _openSharedDatabase() async {
    final String databasePath = await getDatabasesPath();
    final Database database = await openDatabase(
      join(databasePath, _databaseName),
      version: 1,
      onCreate: (db, version) async {
        await _createPlansTable(db);
      },
      onOpen: (db) async {
        if (!_didEnsureSchema) {
          await _createPlansTable(db);
        }
      },
    );
    _didEnsureSchema = true;
    return database;
  }

  /////自定义方案页与后端联调，之后这里改成调用 GET /therapy/plan/custom/list，并把后端返回的 plan_config_json/used_modules_json 转成 CustomizedPlanData。
  Future<void> loadPlans() async {
    await _openDatabaseIfNeeded();

    List<Map<String, Object?>> rows;
    try {
      rows = await _db.query(_tableName, orderBy: 'id ASC');
    } on DatabaseException catch (error) {
      if (!error.toString().contains('database_closed')) rethrow;

      _sharedDatabase = null;
      _openingDatabase = null;
      _didEnsureSchema = false;
      await _openDatabaseIfNeeded();
      rows = await _db.query(_tableName, orderBy: 'id ASC');
    }

    plans
      ..clear()
      ..addAll(rows.map(CustomizedPlanData.fromMap));
    highlightedIndex = null;
  }

  /////自定义方案页与后端联调，之后这里改成 POST /therapy/plan/custom；featureIds 需要序列化到 planConfigJson 或 usedModulesJson。
  Future<void> addPlan({
    required String name,
    required List<String> featureIds,
  }) async {
    await _openDatabaseIfNeeded();
    final String trimmedName = name.trim();
    final String? errorText = validatePlanName(trimmedName);
    if (errorText != null) throw CustomizedPlanNameException(errorText);

    final CustomizedPlanData plan = CustomizedPlanData(
      name: trimmedName,
      featureIds: featureIds,
    );
    final int id = await _db.insert(_tableName, plan.toMap());
    plans.add(plan.copyWith(id: id));
    highlightedIndex = null;
  }

  /////自定义方案页与后端联调，之后这里改成后端更新接口；如果只是改名可调用 PUT /therapy/plan/custom/{planId}/name，编辑完整配置时需要补一个后端更新配置接口。
  Future<void> updatePlan(CustomizedPlanData plan) async {
    if (plan.id == null) return;
    await _openDatabaseIfNeeded();
    final String trimmedName = plan.name.trim();
    final String? errorText = validatePlanName(trimmedName, excludeId: plan.id);
    if (errorText != null) throw CustomizedPlanNameException(errorText);

    await _db.update(
      _tableName,
      plan.copyWith(name: trimmedName).toMap(),
      where: 'id = ?',
      whereArgs: [plan.id],
    );
    await loadPlans();
  }

  /////自定义方案页与后端联调，之后 renamePlan 保留入口，但内部应调用 PUT /therapy/plan/custom/{planId}/name。
  Future<void> renamePlan(int index, String name) async {
    final CustomizedPlanData plan = plans[index].copyWith(name: name.trim());
    await updatePlan(plan);
  }

  /////自定义方案页与后端联调，之后重名校验可以保留前端即时提示，但最终应以后端返回结果为准，避免不同设备并发创建重名方案。
  String? validatePlanName(String name, {int? excludeId}) {
    final String text = name.trim();
    if (text.isEmpty) return '方案名称不能为空';

    final bool isDuplicated = plans.any(
      (plan) => plan.id != excludeId && plan.name.trim() == text,
    );
    if (isDuplicated) return '方案名称不能重复';

    return null;
  }

  /////自定义方案页与后端联调，之后这里改成 DELETE /therapy/plan/custom/{planId}，成功后再从 plans 移除。
  Future<void> deletePlan(int index) async {
    await _openDatabaseIfNeeded();

    final CustomizedPlanData plan = plans[index];
    if (plan.id != null) {
      await _db.delete(_tableName, where: 'id = ?', whereArgs: [plan.id]);
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

  /////自定义方案页与后端联调，之后新增页保存成功后应刷新后端列表，避免本地 plans 与 MySQL 不一致。
  Future<bool> openAddPage() async {
    final Object? result = await Get.toNamed(editRoute);
    await loadPlans();
    return result == true;
  }

  /////自定义方案页与后端联调，之后编辑页需要携带后端 planId 和完整 planConfigJson，保存后刷新后端列表。
  Future<bool> openEditPage(CustomizedPlanData plan) async {
    final Object? result = await Get.toNamed(
      editRoute,
      arguments: {'plan': plan},
    );
    await loadPlans();
    return result == true;
  }

  /////自定义方案页与后端联调，之后选择方案时建议只传 planId/planName，启动页再按 planId 调 GET /therapy/plan/custom/{planId} 获取最新配置。
  void selectPlan(CustomizedPlanData plan) {
    Get.toNamed(
      choseUsersRoute,
      arguments: {'modeTitle': plan.name, 'customizedPlan': plan},
    );
  }

  Future<void> dispose() async {
    // 不在页面 dispose 时主动关闭 sqflite 连接。
    // 页面跳转返回时可能还有 loadPlans() 在等待执行，立即 close 会导致 database_closed。
  }

  /////自定义方案页与后端联调，之后本地表创建方法可以删除；后端表是 therapy_plan。
  Future<void> _createPlansTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        feature_ids TEXT NOT NULL
      )
    ''');
  }

  /////自定义方案页与后端联调，之后默认方案不要写入本地 customized_plans；预设方案继续放 Flutter 本地，自定义方案只从后端读取。
  Future<void> _seedDefaultPlansIfNeeded() async {
    if (plans.isNotEmpty) return;

    final List<CustomizedPlanData> defaults = [
      const CustomizedPlanData(
        name: '耐力赋能',
        featureIds: ['redlight', 'pemf', 'vat', 'expand'],
      ),
      const CustomizedPlanData(
        name: '免疫加固',
        featureIds: ['redlight', 'pemf', 'vat', 'expand'],
      ),
      const CustomizedPlanData(
        name: '肌肉修护',
        featureIds: ['redlight', 'hydrogen', 'pemf', 'vat', 'expand'],
      ),
      const CustomizedPlanData(
        name: '代谢激活',
        featureIds: ['pemf', 'vat', 'expand'],
      ),
    ];

    for (final CustomizedPlanData plan in defaults) {
      await _db.insert(_tableName, plan.toMap());
    }
    await loadPlans();
  }

  /////自定义方案页与后端联调，之后删除 _db getter，所有增删改查都通过后端 API。
  Database get _db => _sharedDatabase!;
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

  /////自定义方案页与后端联调，之后 fromMap 改成 fromDto/fromJson，字段来源从 feature_ids 变成后端 planConfigJson/usedModulesJson。
  factory CustomizedPlanData.fromMap(Map<String, Object?> map) {
    final String featureText = map['feature_ids'] as String? ?? '';
    return CustomizedPlanData(
      id: map['id'] as int?,
      name: map['name'] as String,
      featureIds: featureText
          .split(',')
          .where((String id) => id.trim().isNotEmpty)
          .toList(),
    );
  }

  /////自定义方案页与后端联调，之后 toMap 改成 toRequestDto/toJson，发送 planName、durationMinutes、usedModulesJson、planConfigJson 给后端。
  Map<String, Object?> toMap() {
    return {'name': name, 'feature_ids': featureIds.join(',')};
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
