import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infibo_app/pages/choseusers/logic.dart';
import 'package:infibo_app/pages/choseusers/ui.dart';
import 'package:infibo_app/stores/app_header_clock_store.dart';
import 'package:infibo_app/stores/user_store.dart';

void main() {
  testWidgets('chose users page stays fixed when keyboard opens', (
    WidgetTester tester,
  ) async {
    Get.testMode = true;
    tester.view.physicalSize = const Size(800, 1280);
    tester.view.devicePixelRatio = 1;
    Get.put(UserStore());
    Get.put<AppHeaderClockController>(_TestClockController());
    addTearDown(() {
      tester.view.resetViewInsets();
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      Get.reset();
    });

    await tester.pumpWidget(
      GetMaterialApp(
        home: ChoseUsersPage(
          logic: ChoseUsersLogic(repository: _EmptyChoseUsersRepository()),
        ),
      ),
    );
    await tester.pump();

    final Finder pageBody = find.byType(SafeArea).first;
    final Size sizeBeforeKeyboard = tester.getSize(pageBody);

    tester.view.viewInsets = const FakeViewPadding(bottom: 284);
    await tester.pump();

    expect(tester.getSize(pageBody), sizeBeforeKeyboard);
  });
}

class _TestClockController extends AppHeaderClockController {
  @override
  void startClock() {}
}

class _EmptyChoseUsersRepository implements ChoseUsersRepository {
  @override
  Future<List<UserItemData>> listUsers() async => <UserItemData>[];

  @override
  Future<UserItemData> addUser(UserItemData user) async => user;

  @override
  Future<void> deleteUser(int id) async {}

  @override
  Future<void> dispose() async {}
}
