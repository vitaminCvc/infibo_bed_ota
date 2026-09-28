import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/designCanvas/design.dart';
import 'package:infibo_app/pages/summary/summary.dart';
import 'package:infibo_app/stores/app_header_clock_store.dart';
import 'package:infibo_app/stores/user_store.dart';

void main() {
  testWidgets('returns home after keyboard closes even with stale MediaQuery', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.view.resetViewInsets();
      Get.reset();
    });

    Get.put(UserStore());
    await tester.pumpWidget(
      GetMaterialApp(
        initialRoute: '/summary',
        builder: (BuildContext context, Widget? child) {
          final MediaQueryData staleMediaQuery = MediaQuery.of(
            context,
          ).copyWith(viewInsets: const EdgeInsets.only(bottom: 300));
          return MediaQuery(
            data: staleMediaQuery,
            child: DesignCanvas(child: child ?? const SizedBox.shrink()),
          );
        },
        getPages: <GetPage<dynamic>>[
          GetPage(name: '/summary', page: () => const SummaryPage()),
          GetPage(
            name: '/main',
            page: () => const Scaffold(body: Text('Main placeholder')),
          ),
        ],
      ),
    );

    await tester.pump(const Duration(seconds: 3));
    expect(find.byType(SummaryPage), findsOneWidget);

    tester.view.viewInsets = FakeViewPadding.zero;
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();

    expect(find.text('Main placeholder'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    Get.delete<AppHeaderClockController>(force: true);
  });
}
