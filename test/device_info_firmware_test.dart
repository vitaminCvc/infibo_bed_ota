import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/pages/settingpage/DeviceInfo.dart';

void main() {
  testWidgets(
    'firmware starts unavailable instead of showing a fixed version',
    (WidgetTester tester) async {
      final pending = Completer<int>();
      await tester.pumpWidget(_panel((_) => pending.future));

      expect(find.text('---'), findsOneWidget);
      expect(find.text('V2.1.0'), findsNothing);
    },
  );

  for (final fixture in <int, String>{
    0x0125: 'V1.2.5',
    0x0130: 'V1.3.0',
    0x0200: 'V2.0.0',
    0x0000: 'V0.0.0',
  }.entries) {
    testWidgets('formats register ${fixture.key} as ${fixture.value}', (
      WidgetTester tester,
    ) async {
      final addresses = <int>[];
      await tester.pumpWidget(
        _panel((address) async {
          addresses.add(address);
          return fixture.key;
        }),
      );
      await tester.pump();

      expect(addresses, <int>[0x0002]);
      expect(find.text(fixture.value), findsOneWidget);
      expect(find.text('---'), findsNothing);
    });
  }

  for (final invalid in <int>[-1, 0x10000]) {
    testWidgets('invalid register $invalid leaves firmware unavailable', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(_panel((_) async => invalid));
      await tester.pump();

      expect(find.text('---'), findsOneWidget);
      expect(find.text('V2.1.0'), findsNothing);
    });
  }

  testWidgets('read failure stays unavailable without retrying', (
    WidgetTester tester,
  ) async {
    final addresses = <int>[];
    await tester.pumpWidget(
      _panel((address) async {
        addresses.add(address);
        throw TimeoutException('No board response');
      }),
    );
    await tester.pump(const Duration(seconds: 30));

    expect(find.text('---'), findsOneWidget);
    expect(addresses, <int>[0x0002]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rebuilds and scrolling do not reread firmware', (
    WidgetTester tester,
  ) async {
    final addresses = <int>[];
    Future<int> read(int address) async {
      addresses.add(address);
      return 0x0125;
    }

    await tester.pumpWidget(_panel(read));
    await tester.pump();
    await tester.pumpWidget(_panel(read));
    await tester.drag(
      find.byKey(const ValueKey<String>('device-info-scroll-view')),
      const Offset(0, -100),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(minutes: 1));

    expect(addresses, <int>[0x0002]);
    expect(find.text('V1.2.5'), findsOneWidget);
  });

  testWidgets('reopening reads again and clears the previous version', (
    WidgetTester tester,
  ) async {
    final secondRead = Completer<int>();
    final addresses = <int>[];
    Future<int> read(int address) {
      addresses.add(address);
      return addresses.length == 1
          ? Future<int>.value(0x0125)
          : secondRead.future;
    }

    await tester.pumpWidget(_panel(read));
    await tester.pump();
    expect(find.text('V1.2.5'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(_panel(read));

    expect(addresses, <int>[0x0002, 0x0002]);
    expect(find.text('---'), findsOneWidget);
    expect(find.text('V1.2.5'), findsNothing);
    secondRead.completeError(TimeoutException('No board response'));
    await tester.pump();
    expect(find.text('---'), findsOneWidget);
  });

  testWidgets('reopening after a failure can show a new version', (
    WidgetTester tester,
  ) async {
    var reads = 0;
    Future<int> read(int _) async {
      if (++reads == 1) throw TimeoutException('No board response');
      return 0x0200;
    }

    await tester.pumpWidget(_panel(read));
    await tester.pump();
    expect(find.text('---'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpWidget(_panel(read));
    await tester.pump();

    expect(reads, 2);
    expect(find.text('V2.0.0'), findsOneWidget);
  });

  for (final fails in <bool>[false, true]) {
    testWidgets('late ${fails ? 'failure' : 'success'} after leaving is safe', (
      WidgetTester tester,
    ) async {
      final pending = Completer<int>();
      await tester.pumpWidget(_panel((_) => pending.future));
      await tester.pumpWidget(const SizedBox.shrink());
      if (fails) {
        pending.completeError(TimeoutException('Late board response'));
      } else {
        pending.complete(0x0125);
      }
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  }
}

Widget _panel(Future<int> Function(int address) readRegister) {
  return MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 436,
        height: 900,
        child: DeviceInfoPanel(
          showDeviceStatusHeading: false,
          readRegister: readRegister,
        ),
      ),
    ),
  );
}
