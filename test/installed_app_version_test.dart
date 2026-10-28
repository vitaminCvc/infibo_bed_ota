import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/pages/settingpage/DeviceInfo.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('infibo_app/app_info');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));
  Widget panel() => MaterialApp(
    home: Scaffold(
      body: SizedBox(
        width: 436,
        height: 900,
        child: DeviceInfoPanel(readRegister: (_) async => 0x0130),
      ),
    ),
  );

  testWidgets('settings shows version name without the internal build number', (
    tester,
  ) async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'getVersion');
      return {'versionName': '1.1.1', 'versionCode': 3};
    });
    await tester.pumpWidget(panel());
    await tester.pumpAndSettle();
    expect(find.text('V1.1.1'), findsOneWidget);
    expect(find.textContaining('Build'), findsNothing);
    expect(find.byTooltip('V1.1.1'), findsOneWidget);
    expect(find.text('V1.09'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('native failure uses an honest placeholder', (tester) async {
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => throw PlatformException(code: 'unavailable'),
    );
    await tester.pumpWidget(panel());
    await tester.pumpAndSettle();
    expect(find.text('Version unavailable'), findsOneWidget);
    expect(find.text('V1.09'), findsNothing);
  });

  testWidgets('late native response after leaving is safe', (tester) async {
    final pending = Completer<Map<String, Object>>();
    messenger.setMockMethodCallHandler(channel, (_) => pending.future);
    await tester.pumpWidget(panel());
    await tester.pumpWidget(const SizedBox.shrink());
    pending.complete({'versionName': '1.2.0', 'versionCode': 4});
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('long version and maximum build fit the settings cell', (
    tester,
  ) async {
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => {
        'versionName': '2026.10.19-internal.testing.1234567890',
        'versionCode': 2100000000,
      },
    );
    await tester.pumpWidget(panel());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
