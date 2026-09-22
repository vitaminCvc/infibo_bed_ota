import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/designCanvas/design.dart';
import 'package:infibo_app/components/index.dart' as index_components;
import 'package:infibo_app/components/settingindex.dart' as setting_components;
import 'package:infibo_app/config/app_brand.dart';
import 'package:infibo_app/constants/layout.dart';
import 'package:infibo_app/stores/app_header_clock_store.dart';
import 'package:infibo_app/stores/user_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues(<String, Object>{});
    AppBrand.configure(AppBrands.global);
    Get.put<UserStore>(UserStore());
    Get.put<AppHeaderClockController>(_StaticClockController());
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('common header pages shift their complete stack by 30 on 16:9', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(AppLayout.ratio16x9.designSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final pageBuilder in _pageBuilders) {
      final Key contentKey = UniqueKey();

      await tester.pumpWidget(
        _buildTestApp(
          layout: AppLayout.ratio16x9,
          page: pageBuilder(
            Positioned(
              left: 0,
              top: 100,
              child: SizedBox(key: contentKey, width: 10, height: 10),
            ),
          ),
        ),
      );

      expect(tester.getTopLeft(find.byKey(contentKey)).dy, 130);
    }
  });

  testWidgets('common header pages preserve coordinates on 16:10', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(AppLayout.ratio16x10.designSize);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    for (final pageBuilder in _pageBuilders) {
      final Key contentKey = UniqueKey();

      await tester.pumpWidget(
        _buildTestApp(
          layout: AppLayout.ratio16x10,
          page: pageBuilder(
            Positioned(
              left: 0,
              top: 100,
              child: SizedBox(key: contentKey, width: 10, height: 10),
            ),
          ),
        ),
      );

      expect(tester.getTopLeft(find.byKey(contentKey)).dy, 100);
    }
  });
}

typedef _PageBuilder = Widget Function(Widget child);

final List<_PageBuilder> _pageBuilders = <_PageBuilder>[
  (Widget child) => index_components.AppHeaderPage(children: <Widget>[child]),
  (Widget child) =>
      setting_components.AppSettingHeaderPage(children: <Widget>[child]),
];

Widget _buildTestApp({required AppLayoutMetrics layout, required Widget page}) {
  return MaterialApp(
    home: AppLayoutScope(layout: layout, child: page),
  );
}

class _StaticClockController extends AppHeaderClockController {
  final RxString _dateText = '2026-08-27'.obs;
  final RxString _timeText = '12:00'.obs;

  @override
  String get dateText => _dateText.value;

  @override
  void startClock() {}

  @override
  String get timeText => _timeText.value;
}
