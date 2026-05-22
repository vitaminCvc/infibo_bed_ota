// 选择用户页的数据和导航逻辑。
//
// 负责本地用户数据库的增删改查、搜索高亮，以及进入启动理疗页时传递模式/方案参数。
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// 选择用户页逻辑。
class ChoseUsersLogic {
  static const String _databaseName = 'infibo_app.db';
  static const String _tableName = 'therapy_users';
  static const String startRoute = '/start';
  static const String defaultModeTitle = '深度放松';

  final List<UserItemData> users = [];

  Database? _database;
  int? highlightedIndex;

  String get selectedModeTitle {
    final Object? args = Get.arguments;
    if (args is Map && args['modeTitle'] is String) {
      return args['modeTitle'] as String;
    }
    return defaultModeTitle;
  }

  Object? get selectedCustomizedPlan {
    final Object? args = Get.arguments;
    if (args is Map) return args['customizedPlan'];
    return null;
  }

  // 初始化数据库并加载用户。
  Future<void> init() async {
    final String databasePath = await getDatabasesPath();
    _database = await openDatabase(
      join(databasePath, _databaseName),
      version: 1,
      onCreate: (db, version) => _createUsersTable(db),
      onOpen: (db) => _createUsersTable(db),
    );
    await loadUsers();
  }

  // 加载已保存用户。
  Future<void> loadUsers() async {
    List<Map<String, Object?>> rows;
    try {
      rows = await _db.query(_tableName, orderBy: 'id ASC');
    } on DatabaseException catch (error) {
      if (!error.isNoSuchTableError(_tableName)) rethrow;
      await _createUsersTable(_db);
      rows = await _db.query(_tableName, orderBy: 'id ASC');
    }

    users
      ..clear()
      ..addAll(rows.map(UserItemData.fromMap));
    highlightedIndex = null;
  }

  // 添加用户。
  Future<void> addUser({
    required String name,
    required String gender,
    required String age,
    required String phone,
  }) async {
    final UserItemData user = UserItemData(
      name: name.trim(),
      gender: gender.trim(),
      age: _formatAge(age),
      phone: phone.trim(),
    );

    final int id = await _db.insert(_tableName, user.toMap());
    users.add(user.copyWith(id: id));
    highlightedIndex = null;
  }

  // 删除用户。
  Future<void> deleteUser(int index) async {
    final UserItemData user = users[index];
    if (user.id != null) {
      await _db.delete(_tableName, where: 'id = ?', whereArgs: [user.id]);
    }

    users.removeAt(index);
    if (highlightedIndex == index) {
      highlightedIndex = null;
    } else if (highlightedIndex != null && highlightedIndex! > index) {
      highlightedIndex = highlightedIndex! - 1;
    }
  }

  // 根据姓名或手机号查找用户。
  int findUserIndex(String keyword) {
    final String text = keyword.trim();
    if (text.isEmpty) return -1;

    return users.indexWhere(
      (user) => user.name.contains(text) || user.phone.contains(text),
    );
  }

  // 高亮指定用户。
  void highlightUser(int index) {
    highlightedIndex = index;
  }

  // 选择用户后进入启动页面。
  void selectUser(UserItemData user) {
    Get.toNamed(
      startRoute,
      arguments: {
        'modeTitle': selectedModeTitle,
        'user': user,
        'customizedPlan': selectedCustomizedPlan,
      },
    );
  }

  // 释放数据库。
  Future<void> dispose() async {
    await _database?.close();
    _database = null;
  }

  // 创建用户表。
  Future<void> _createUsersTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableName (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        gender TEXT NOT NULL,
        age TEXT NOT NULL,
        phone TEXT NOT NULL
      )
    ''');
  }

  // 格式化年龄显示。
  String _formatAge(String age) {
    final String text = age.trim();
    if (text.isEmpty || text.endsWith('岁')) return text;
    return '$text岁';
  }

  Database get _db => _database!;
}

// 用户列表数据。
class UserItemData {
  const UserItemData({
    this.id,
    required this.name,
    required this.gender,
    required this.age,
    required this.phone,
  });

  // 数据库主键。
  final int? id;

  // 用户姓名。
  final String name;

  // 用户性别。
  final String gender;

  // 用户年龄。
  final String age;

  // 手机号。
  final String phone;

  // 从数据库记录转换为用户数据。
  factory UserItemData.fromMap(Map<String, Object?> map) {
    return UserItemData(
      id: map['id'] as int?,
      name: map['name'] as String,
      gender: map['gender'] as String,
      age: map['age'] as String,
      phone: map['phone'] as String,
    );
  }

  // 转换为数据库记录。
  Map<String, Object?> toMap() {
    return {'name': name, 'gender': gender, 'age': age, 'phone': phone};
  }

  // 复制用户数据。
  UserItemData copyWith({int? id}) {
    return UserItemData(
      id: id ?? this.id,
      name: name,
      gender: gender,
      age: age,
      phone: phone,
    );
  }
}
