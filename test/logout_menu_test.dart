import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/components/logout_menu.dart';

void main() {
  testWidgets('disabled logout menu absorbs all user button taps', (
    WidgetTester tester,
  ) async {
    int childTapCount = 0;
    int logoutCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LogoutMenu(
            enabled: false,
            onLogout: () async => logoutCount++,
            child: GestureDetector(
              key: const ValueKey<String>('user_button'),
              onTap: () => childTapCount++,
              child: const SizedBox(width: 108, height: 48),
            ),
          ),
        ),
      ),
    );

    await tester.tapAt(
      tester.getCenter(find.byKey(const ValueKey<String>('user_button'))),
    );
    await tester.pump();

    expect(childTapCount, 0);
    expect(logoutCount, 0);
    expect(find.byIcon(Icons.logout), findsNothing);
  });

  testWidgets('enabled logout menu opens and runs logout action', (
    WidgetTester tester,
  ) async {
    int logoutCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LogoutMenu(
            enabled: true,
            onLogout: () async => logoutCount++,
            child: const SizedBox(
              key: ValueKey<String>('user_button'),
              width: 108,
              height: 48,
            ),
          ),
        ),
      ),
    );

    await tester.tapAt(
      tester.getCenter(find.byKey(const ValueKey<String>('user_button'))),
    );
    await tester.pump();
    expect(find.byIcon(Icons.logout), findsOneWidget);

    await tester.tap(find.byIcon(Icons.logout));
    await tester.pump();
    expect(logoutCount, 1);
  });
}
