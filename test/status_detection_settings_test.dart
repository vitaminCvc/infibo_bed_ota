import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/designCanvas/design.dart';
import 'package:infibo_app/pages/settingpage/status_detection_panel.dart';
import 'package:infibo_app/pages/settingpage/ui.dart';
import 'package:infibo_app/stores/app_header_clock_store.dart';
import 'package:infibo_app/stores/user_store.dart';
import 'package:infibo_app/translation/app_translations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const expectedAddresses = <int>[
    0x0080,
    0x0089,
    0x008E,
    0x00E0,
    0x00E4,
    0x00E5,
    0x00E6,
    0x01A0,
    0x0189,
    0x01A5,
    0x01E0,
    0x01E5,
    0x01E6,
    0x01E9,
    0x01EC,
  ];
  const readings = <int, int>{
    0x0080: 1,
    0x0089: 368,
    0x008E: 379,
    0x00E0: 2,
    0x00E4: 12,
    0x00E5: 240,
    0x00E6: 325,
    0x01A0: 0,
    0x0189: 56,
    0x01A5: 301,
    0x01E0: 5,
    0x01E5: 2,
    0x01E6: 264,
    0x01E9: 7416,
    0x01EC: 8,
  };

  Widget app(Widget child, {Locale locale = const Locale('zh', 'CN')}) =>
      GetMaterialApp(
        locale: locale,
        translations: AppTranslations(),
        home: Scaffold(body: child),
      );

  tearDown(Get.reset);

  testWidgets('reads only on status menu entry and rereads after reentry', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    Get.put(UserStore());
    await tester.binding.setSurfaceSize(const Size(800, 1280));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final addresses = <int>[];
    var value = 8;
    await tester.pumpWidget(
      app(
        DesignCanvas(
          child: SettingWidget(
            statusReadRegister: (address) async {
              addresses.add(address);
              return address == 0x01EC ? value : readings[address]!;
            },
          ),
        ),
      ),
    );
    await tester.pump();
    expect(addresses, isEmpty);
    await tester.tap(find.text('状态检测'));
    await tester.pump();
    await tester.pump();
    expect(addresses, expectedAddresses);
    expect(find.text('8'), findsOneWidget);
    expect(find.byKey(const ValueKey('status_water_quality')), findsOneWidget);
    await tester.pump(const Duration(seconds: 20));
    await tester.tap(find.text('状态检测').first);
    await tester.pump();
    expect(addresses, expectedAddresses);
    await tester.tap(find.text('语言设置'));
    await tester.pump();
    value = 10;
    await tester.tap(find.text('状态检测'));
    await tester.pump();
    await tester.pump();
    expect(addresses, [...expectedAddresses, ...expectedAddresses]);
    expect(find.text('10'), findsOneWidget);
    expect(find.text('异常'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    Get.delete<AppHeaderClockController>(force: true);
  });

  for (final value in [0, 9, 10, 25]) {
    testWidgets('TDS $value uses the ten threshold', (tester) async {
      await tester.pumpWidget(
        app(
          StatusDetectionPanel(
            readRegister: (address) async =>
                address == 0x01EC ? value : readings[address]!,
          ),
        ),
      );
      await tester.pump();
      expect(find.text('$value'), findsOneWidget);
      final quality = tester.widget<Text>(
        find.byKey(const ValueKey('status_water_quality')),
      );
      expect(quality.data, value >= 10 ? '异常' : '正常');
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }

  testWidgets('pending and failed reads never show zero or normal', (
    tester,
  ) async {
    final response = Completer<int>();
    await tester.pumpWidget(
      app(StatusDetectionPanel(readRegister: (_) => response.future)),
    );
    expect(find.text('读取中…'), findsWidgets);
    expect(find.text('0'), findsNothing);
    expect(find.byKey(const ValueKey('status_water_quality')), findsNothing);
    response.completeError(StateError('disconnected'));
    await tester.pump();
    expect(find.text('暂不可用'), findsWidgets);
    expect(find.text('0'), findsNothing);
    expect(find.byKey(const ValueKey('status_water_quality')), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('late response after leaving does not update disposed panel', (
    tester,
  ) async {
    final response = Completer<int>();
    await tester.pumpWidget(
      app(StatusDetectionPanel(readRegister: (_) => response.future)),
    );
    await tester.pumpWidget(const SizedBox.shrink());
    response.complete(8);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  String field(WidgetTester tester, String key) {
    final text = tester.widget<Text>(find.byKey(ValueKey(key)));
    return text.data ?? text.textSpan!.toPlainText();
  }

  testWidgets('reads the spreadsheet registers and converts their units', (
    tester,
  ) async {
    final addresses = <int>[];
    await tester.pumpWidget(
      app(
        StatusDetectionPanel(
          readRegister: (address) async {
            addresses.add(address);
            return readings[address]!;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(addresses, expectedAddresses);
    expect(field(tester, 'status_red_660'), '36.8 ℃');
    expect(field(tester, 'status_red_850'), '37.9 ℃');
    expect(field(tester, 'status_pemf_current'), '1.2 A');
    expect(field(tester, 'status_pemf_voltage'), '24.0 V');
    expect(field(tester, 'status_pemf_coil'), '32.5 ℃');
    expect(field(tester, 'status_vat_temperature'), '30.1 ℃');
    expect(field(tester, 'status_vat_volume'), '56%');
    expect(field(tester, 'status_hydrogen_temperature'), '26.4 ℃');
    expect(
      find.byKey(const ValueKey('status_hydrogen_runtime')),
      findsOneWidget,
    );
    expect(field(tester, 'status_hydrogen_runtime'), '123 h 36 min');
    expect(field(tester, 'status_water_level'), '正常');
    expect(field(tester, 'status_red_state'), '运行');
    expect(field(tester, 'status_pemf_state'), '暂停');
    expect(field(tester, 'status_vat_state'), '待机');
    expect(field(tester, 'status_hydrogen_state'), '禁用');
    expect(field(tester, 'status_tds_value'), '8');
    expect(
      find.byKey(const ValueKey('status_detection_checked_at')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  for (final entry in {
    0: '0 h 0 min',
    59: '0 h 59 min',
    60: '1 h 0 min',
    61: '1 h 1 min',
    65535: '1092 h 15 min',
  }.entries) {
    testWidgets('hydrogen runtime displays ${entry.key} device minutes', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          StatusDetectionPanel(
            readRegister: (address) async =>
                address == 0x01E9 ? entry.key : readings[address]!,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(field(tester, 'status_hydrogen_runtime'), entry.value);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('pending and failed runtime never display a zero total', (
    tester,
  ) async {
    final runtime = Completer<int>();
    await tester.pumpWidget(
      app(
        StatusDetectionPanel(
          readRegister: (address) => address == 0x01E9
              ? runtime.future
              : Future.value(readings[address]!),
        ),
      ),
    );
    await tester.pump();
    expect(field(tester, 'status_hydrogen_runtime'), '读取中…');
    runtime.completeError(StateError('timeout'));
    await tester.pumpAndSettle();
    expect(field(tester, 'status_hydrogen_runtime'), '暂不可用');
    expect(field(tester, 'status_hydrogen_temperature'), '26.4 ℃');
    expect(field(tester, 'status_tds_value'), '8');
  });

  testWidgets('refresh replaces prior results and prevents overlapping scans', (
    tester,
  ) async {
    final addresses = <int>[];
    final nextRead = Completer<int>();
    var refreshed = false;
    await tester.pumpWidget(
      app(
        StatusDetectionPanel(
          readRegister: (address) {
            addresses.add(address);
            if (refreshed && address == 0x0080) return nextRead.future;
            return Future.value(
              address == 0x01E9 && refreshed
                  ? 7417
                  : address == 0x01EC && refreshed
                  ? 10
                  : readings[address]!,
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(field(tester, 'status_water_quality'), '正常');
    refreshed = true;
    final refresh = find.byKey(const ValueKey('status_detection_refresh'));
    await tester.tap(refresh);
    await tester.pump();
    expect(find.byKey(const ValueKey('status_water_quality')), findsNothing);
    expect(field(tester, 'status_tds_value'), '读取中…');
    await tester.tap(refresh);
    await tester.pump();
    expect(addresses, [...expectedAddresses, 0x0080]);
    nextRead.complete(1);
    await tester.pumpAndSettle();
    expect(addresses, [...expectedAddresses, ...expectedAddresses]);
    expect(field(tester, 'status_tds_value'), '10');
    expect(field(tester, 'status_hydrogen_runtime'), '123 h 37 min');
    expect(field(tester, 'status_water_quality'), '异常');
  });

  testWidgets('one failed field does not discard successful module readings', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        StatusDetectionPanel(
          readRegister: (address) async {
            if (address == 0x00E5) throw StateError('timeout');
            return readings[address]!;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(field(tester, 'status_pemf_voltage'), '暂不可用');
    expect(field(tester, 'status_pemf_current'), '1.2 A');
    expect(field(tester, 'status_vat_volume'), '56%');
    expect(field(tester, 'status_tds_value'), '8');
    expect(field(tester, 'status_water_quality'), '正常');
  });

  testWidgets('invalid values do not appear as valid readings', (tester) async {
    await tester.pumpWidget(
      app(
        StatusDetectionPanel(
          readRegister: (address) async {
            if (address == 0x0089) return -1;
            if (address == 0x0189) return 101;
            if (address == 0x01EC) return 65536;
            return readings[address]!;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(field(tester, 'status_red_660'), '暂不可用');
    expect(field(tester, 'status_vat_volume'), '暂不可用');
    expect(field(tester, 'status_tds_value'), '暂不可用');
    expect(find.byKey(const ValueKey('status_water_quality')), findsNothing);
  });

  const stateNames = ['待机', '运行', '暂停', '故障', '完成', '禁用'];
  for (var state = 0; state < stateNames.length; state++) {
    testWidgets('decodes module state $state for all four modules', (
      tester,
    ) async {
      await tester.pumpWidget(
        app(
          StatusDetectionPanel(
            readRegister: (address) async {
              if ([0x0080, 0x00E0, 0x01A0, 0x01E0].contains(address)) {
                return state;
              }
              return readings[address]!;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final key in [
        'status_red_state',
        'status_pemf_state',
        'status_vat_state',
        'status_hydrogen_state',
      ]) {
        expect(field(tester, key), stateNames[state]);
      }
    });
  }

  const levelNames = {1: '缺水', 2: '正常', 3: '高水位'};
  for (final entry in levelNames.entries) {
    testWidgets('decodes water level ${entry.key}', (tester) async {
      await tester.pumpWidget(
        app(
          StatusDetectionPanel(
            readRegister: (address) async =>
                address == 0x01E5 ? entry.key : readings[address]!,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(field(tester, 'status_water_level'), entry.value);
    });
  }

  testWidgets('unknown enums retain the raw code instead of reporting normal', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(
        StatusDetectionPanel(
          readRegister: (address) async {
            if ([0x0080, 0x00E0, 0x01A0, 0x01E0, 0x01E5].contains(address)) {
              return 7;
            }
            return readings[address]!;
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(field(tester, 'status_red_state'), '未知（7）');
    expect(field(tester, 'status_water_level'), '未知（7）');
  });

  testWidgets('leaving while reading stops the remaining serial requests', (
    tester,
  ) async {
    final response = Completer<int>();
    final addresses = <int>[];
    await tester.pumpWidget(
      app(
        StatusDetectionPanel(
          readRegister: (address) {
            addresses.add(address);
            return response.future;
          },
        ),
      ),
    );
    expect(addresses, [0x0080]);
    await tester.pumpWidget(const SizedBox.shrink());
    response.complete(1);
    await tester.pump();
    expect(addresses, [0x0080]);
    expect(tester.takeException(), isNull);
  });

  for (final scale in [1.1, 1.5]) {
    testWidgets('hydrogen card supports enlarged system text at $scale', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(411, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        app(
          MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(scale)),
            child: StatusDetectionPanel(
              readRegister: (address) async => readings[address]!,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(field(tester, 'status_hydrogen_runtime'), '123 h 36 min');
    });
  }

  for (final locale in const [
    Locale('zh', 'CN'),
    Locale('en', 'US'),
    Locale('es', 'ES'),
    Locale('pt', 'PT'),
    Locale('ru', 'RU'),
    Locale('fr', 'FR'),
    Locale('ko', 'KR'),
    Locale('ar', 'SA'),
    Locale('de', 'DE'),
    Locale('tr', 'TR'),
  ]) {
    testWidgets('status content fits a narrow panel in $locale', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(const Size(360, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(
        app(
          StatusDetectionPanel(
            readRegister: (address) async => readings[address]!,
          ),
          locale: locale,
        ),
      );
      await tester.pumpAndSettle();
      expect(field(tester, 'status_pemf_voltage'), '24.0 V');
      expect(
        find
            .byType(Text)
            .evaluate()
            .map((element) => (element.widget as Text).data)
            .whereType<String>()
            .where((text) => text.startsWith('status_')),
        isEmpty,
      );
      expect(tester.takeException(), isNull);
    });
  }
}
