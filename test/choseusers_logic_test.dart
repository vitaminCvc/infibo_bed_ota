import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/pages/choseusers/logic.dart';

void main() {
  test('loads therapy users from backend repository', () async {
    final FakeChoseUsersRepository repository = FakeChoseUsersRepository(
      initialUsers: [
        const UserItemData(
          id: 7,
          name: 'Alice',
          gender: 'female',
          age: '28',
          phone: '13800000000',
        ),
      ],
    );
    final ChoseUsersLogic logic = ChoseUsersLogic(repository: repository);

    await logic.init();

    expect(logic.users, hasLength(1));
    expect(logic.users.first.id, 7);
    expect(logic.users.first.name, 'Alice');
    expect(repository.listCallCount, 1);
  });

  test('adds therapy user through backend repository and refreshes list', () async {
    final FakeChoseUsersRepository repository = FakeChoseUsersRepository();
    final ChoseUsersLogic logic = ChoseUsersLogic(repository: repository);
    await logic.init();

    await logic.addUser(
      name: 'Bob',
      gender: 'male',
      age: '36',
      phone: '13900000000',
    );

    expect(repository.createdUsers.single.name, 'Bob');
    expect(logic.users.single.id, 1);
    expect(logic.users.single.phone, '13900000000');
  });

  test('deletes therapy user through backend repository', () async {
    final FakeChoseUsersRepository repository = FakeChoseUsersRepository(
      initialUsers: [
        const UserItemData(
          id: 3,
          name: 'Alice',
          gender: 'female',
          age: '28',
          phone: '13800000000',
        ),
      ],
    );
    final ChoseUsersLogic logic = ChoseUsersLogic(repository: repository);
    await logic.init();

    await logic.deleteUser(0);

    expect(repository.deletedIds, [3]);
    expect(logic.users, isEmpty);
  });
}

class FakeChoseUsersRepository implements ChoseUsersRepository {
  FakeChoseUsersRepository({List<UserItemData> initialUsers = const []})
    : _users = List<UserItemData>.from(initialUsers);

  final List<UserItemData> _users;
  final List<UserItemData> createdUsers = [];
  final List<int> deletedIds = [];
  int listCallCount = 0;
  int _nextId = 1;

  @override
  Future<List<UserItemData>> listUsers() async {
    listCallCount++;
    return List<UserItemData>.from(_users);
  }

  @override
  Future<UserItemData> addUser(UserItemData user) async {
    createdUsers.add(user);
    final UserItemData saved = user.copyWith(id: _nextId++);
    _users.add(saved);
    return saved;
  }

  @override
  Future<void> deleteUser(int id) async {
    deletedIds.add(id);
    _users.removeWhere((UserItemData user) => user.id == id);
  }

  @override
  Future<void> dispose() async {}
}
