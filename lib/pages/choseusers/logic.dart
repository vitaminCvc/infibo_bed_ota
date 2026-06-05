import 'package:get/get.dart';
import 'package:infibo_app/api/dio/api/api_response.dart';
import 'package:infibo_app/api/dio/therapy_client/therapy_client_api.dart';
import 'package:infibo_app/api/dio/therapy_client/therapy_client_models.dart';
import 'package:infibo_app/stores/user_store.dart';
import 'package:infibo_app/utils/age_utils.dart';

abstract class ChoseUsersRepository {
  Future<List<UserItemData>> listUsers();

  Future<UserItemData> addUser(UserItemData user);

  Future<void> deleteUser(int id);

  Future<void> dispose();
}

class BackendChoseUsersRepository implements ChoseUsersRepository {
  BackendChoseUsersRepository({TherapyClientApi? api})
    : _api = api ?? TherapyClientApi();

  final TherapyClientApi _api;

  @override
  Future<List<UserItemData>> listUsers() async {
    final ApiResponse<List<TherapyClientDto>> response = await _api.list(
      ownerUserId: _currentOwnerUserId(),
    );
    if (!response.isSuccess)
      throw ChoseUsersRepositoryException(response.message);
    return (response.data ?? <TherapyClientDto>[])
        .map(UserItemData.fromDto)
        .toList();
  }

  @override
  Future<UserItemData> addUser(UserItemData user) async {
    final ApiResponse<TherapyClientDto> response = await _api.create(
      ownerUserId: _currentOwnerUserId(),
      request: TherapyClientRequestDto(
        name: user.name,
        gender: user.gender,
        age: int.tryParse(user.age.replaceAll(RegExp(r'[^0-9]'), '')),
        phone: user.phone,
      ),
    );
    if (!response.isSuccess || response.data == null) {
      throw ChoseUsersRepositoryException(response.message);
    }
    return UserItemData.fromDto(response.data!);
  }

  @override
  Future<void> deleteUser(int id) async {
    final ApiResponse<void> response = await _api.delete(
      ownerUserId: _currentOwnerUserId(),
      clientId: id,
    );
    if (!response.isSuccess)
      throw ChoseUsersRepositoryException(response.message);
  }

  @override
  Future<void> dispose() async {}

  int _currentOwnerUserId() {
    final int? userId = UserStore.instance.userId;
    if (userId == null) {
      throw const ChoseUsersRepositoryException(
        'current user is not logged in',
      );
    }
    return userId;
  }
}

class ChoseUsersRepositoryException implements Exception {
  const ChoseUsersRepositoryException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ChoseUsersLogic {
  ChoseUsersLogic({ChoseUsersRepository? repository})
    : _repository = repository ?? BackendChoseUsersRepository();

  static const String startRoute = '/start';
  static const String defaultModeTitle = '娣卞害鏀炬澗';

  final ChoseUsersRepository _repository;
  final List<UserItemData> users = [];

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

  Future<void> init() async {
    await loadUsers();
  }

  Future<void> loadUsers() async {
    final List<UserItemData> loadedUsers = await _repository.listUsers();
    users
      ..clear()
      ..addAll(loadedUsers);
    highlightedIndex = null;
  }

  Future<void> addUser({
    required String name,
    required String gender,
    required String age,
    required String phone,
  }) async {
    final UserItemData user = UserItemData(
      name: name.trim(),
      gender: gender.trim(),
      age: age.trim(),
      phone: phone.trim(),
    );

    final UserItemData savedUser = await _repository.addUser(user);
    users.add(savedUser);
    highlightedIndex = null;
  }

  Future<void> deleteUser(int index) async {
    final UserItemData user = users[index];
    final int? id = user.id;
    if (id == null) return;

    await _repository.deleteUser(id);
    users.removeAt(index);
    if (highlightedIndex == index) {
      highlightedIndex = null;
    } else if (highlightedIndex != null && highlightedIndex! > index) {
      highlightedIndex = highlightedIndex! - 1;
    }
  }

  int findUserIndex(String keyword) {
    final String text = keyword.trim();
    if (text.isEmpty) return -1;

    return users.indexWhere(
      (user) => user.name.contains(text) || user.phone.contains(text),
    );
  }

  void highlightUser(int index) {
    highlightedIndex = index;
  }

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

  Future<void> dispose() async {
    await _repository.dispose();
  }
}

class UserItemData {
  const UserItemData({
    this.id,
    required this.name,
    required this.gender,
    required this.age,
    required this.phone,
  });

  final int? id;
  final String name;
  final String gender;
  final String age;
  final String phone;

  factory UserItemData.fromDto(TherapyClientDto dto) {
    return UserItemData(
      id: dto.clientId,
      name: dto.name,
      gender: dto.gender,
      age: dto.age?.toString() ?? '',
      phone: dto.phone,
    );
  }

  UserItemData copyWith({int? id, String? name}) {
    return UserItemData(
      id: id ?? this.id,
      name: name ?? this.name,
      gender: gender,
      age: age,
      phone: phone,
    );
  }
}
