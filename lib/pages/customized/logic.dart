// 自定义方案列表页的本地数据库逻辑。
//
// 负责保存方案名和 featureIds 字符串列表，并提供新增、编辑、删除、搜索、选择方案等方法。
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// 自定义方案列表逻辑。
class CustomizedLogic {
  static const String _databaseName = 'infibo_app.db';
  static const String _tableName = 'customized_plans';
  static const String editRoute = '/customized/edit';
  static const String choseUsersRoute = '/choseusers';

  final List<CustomizedPlanData> plans = [];

  Database? _database;
  int? highlightedIndex;

  Future<void> init() async {
    await _openDatabaseIfNeeded();
    await loadPlans();
    await _seedDefaultPlansIfNeeded();
  }

  Future<void> _openDatabaseIfNeeded() async {
    if (_database?.isOpen != true) {
      final String databasePath = await getDatabasesPath();
      _database = await openDatabase(
        join(databasePath, _databaseName),
        version: 1,
        onCreate: (db, version) async {
          await _createPlansTable(db);
        },
        onOpen: (db) async {
          await _createPlansTable(db);
        },
      );
    }

    await _createPlansTable(_db);
  }

  Future<void> loadPlans() async {
    await _openDatabaseIfNeeded();

    final List<Map<String, Object?>> rows = await _db.query(
      _tableName,
      orderBy: 'id ASC',
    );

    plans
      ..clear()
      ..addAll(rows.map(CustomizedPlanData.fromMap));
    highlightedIndex = null;
  }

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

  Future<void> renamePlan(int index, String name) async {
    final CustomizedPlanData plan = plans[index].copyWith(name: name.trim());
    await updatePlan(plan);
  }

  String? validatePlanName(String name, {int? excludeId}) {
    final String text = name.trim();
    if (text.isEmpty) return '方案名称不能为空';

    final bool isDuplicated = plans.any(
      (plan) => plan.id != excludeId && plan.name.trim() == text,
    );
    if (isDuplicated) return '方案名称不能重复';

    return null;
  }

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

  Future<bool> openAddPage() async {
    final Object? result = await Get.toNamed(editRoute);
    await loadPlans();
    return result == true;
  }

  Future<bool> openEditPage(CustomizedPlanData plan) async {
    final Object? result = await Get.toNamed(
      editRoute,
      arguments: {'plan': plan},
    );
    await loadPlans();
    return result == true;
  }

  void selectPlan(CustomizedPlanData plan) {
    Get.toNamed(
      choseUsersRoute,
      arguments: {'modeTitle': plan.name, 'customizedPlan': plan},
    );
  }

  Future<void> dispose() async {
    await _database?.close();
    _database = null;
  }

  Future<void> _createPlansTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        feature_ids TEXT NOT NULL
      )
    ''');
  }

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

  Database get _db => _database!;
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
