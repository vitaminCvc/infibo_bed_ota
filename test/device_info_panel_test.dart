import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/pages/settingpage/DeviceInfo.dart';

void main() {
  testWidgets('device information panel uses English content and scrolls', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 436,
            height: 900,
            child: DeviceInfoPanel(showDeviceStatusHeading: false),
          ),
        ),
      ),
    );

    expect(find.text('Therapy Chamber'), findsOneWidget);
    expect(find.text('INMORTAL-MT-01'), findsOneWidget);
    expect(find.text('Version Information'), findsOneWidget);
    expect(find.text('Module Status'), findsOneWidget);
    expect(find.text('Temperature Monitor'), findsOneWidget);
    expect(find.text('Online'), findsWidgets);
    expect(find.text('Normal'), findsWidgets);

    final ScrollableState scrollable = tester.state<ScrollableState>(
      find.descendant(
        of: find.byKey(const ValueKey<String>('device-info-scroll-view')),
        matching: find.byType(Scrollable),
      ),
    );
    expect(scrollable.position.maxScrollExtent, greaterThan(0));
  });
}
