import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/api/dio/therapy_report/therapy_report_models.dart';
import 'package:infibo_app/api/dio/login/login_models.dart';
import 'package:infibo_app/api/modbus/modbus_rtu_service.dart';
import 'package:infibo_app/components/water_level_warning_dialog.dart';
import 'package:infibo_app/pages/customized/logic.dart';
import 'package:infibo_app/pages/music/logic.dart';
import 'package:infibo_app/pages/main/ui.dart';
import 'package:infibo_app/pages/settingpage/logic.dart';
import 'package:infibo_app/pages/start/logic.dart';
import 'package:infibo_app/routes/route_observer.dart';
import 'package:infibo_app/stores/app_header_clock_store.dart';
import 'package:infibo_app/stores/hifem_setting_store.dart';
import 'package:infibo_app/stores/user_store.dart';
import 'package:infibo_app/translation/app_translations.dart';
import 'package:infibo_app/utils/email_utils.dart';
import 'package:infibo_app/utils/gender_utils.dart';
import 'package:infibo_app/utils/localized_api_message.dart';

void main() {
  test('logout labels stay compact in constrained menu', () {
    const Map<String, String> compactLabels = <String, String>{
      'pt_PT': 'Sair',
      'fr_FR': 'Quitter',
      'ar_SA': 'خروج',
    };

    final Map<String, Map<String, String>> translations =
        AppTranslations().keys;
    for (final MapEntry<String, String> expected in compactLabels.entries) {
      expect(translations[expected.key]?['logout'], expected.value);
    }
  });

  test('chakra power uses compact labels in every locale', () {
    const Map<String, String> expectedLabels = <String, String>{
      'zh_CN': '强度',
      'en_US': 'Power',
      'es_ES': 'Pot.',
      'pt_PT': 'Pot.',
      'ru_RU': 'Мощ.',
      'fr_FR': 'Puis.',
      'ko_KR': '출력',
      'ar_SA': 'قدرة',
      'de_DE': 'Leist.',
      'tr_TR': 'Güç',
    };

    final Map<String, Map<String, String>> translations =
        AppTranslations().keys;
    for (final MapEntry<String, String> expected in expectedLabels.entries) {
      expect(
        translations[expected.key]?['chakra_power'],
        expected.value,
        reason: '${expected.key} needs a compact chakra power label',
      );
    }
  });

  test('gender values are localized for the current language', () {
    Get.addTranslations(AppTranslations().keys);
    Get.updateLocale(const Locale('en', 'US'));

    expect(localizedGenderText('女'), 'F');
    expect(localizedGenderText('男'), 'M');
    expect(localizedGenderText('female'), 'F');
    expect(localizedGenderText('unknown'), 'unknown');
  });

  test('Chinese backend messages use translated fallback outside Chinese', () {
    Get.addTranslations(AppTranslations().keys);
    Get.updateLocale(const Locale('en', 'US'));

    expect(
      localizedApiMessage('登录成功', fallbackKey: 'login_success'),
      'Login successful',
    );
    expect(
      localizedApiMessage('Account locked', fallbackKey: 'login_failed'),
      'Account locked',
    );
  });

  test('authentication translation keys exist in every locale', () {
    const Set<String> requiredKeys = <String>{
      'code_sent_backend_email',
      'confirm_new_password_hint',
      'confirm_new_password_required',
      'confirm_reset',
      'email_required',
      'error',
      'login_failed',
      'login_request_failed',
      'login_success',
      'login_success_empty_user',
      'new_password_hint',
      'new_password_required',
      'password_required',
      'password_reset_failed',
      'password_reset_success',
      'passwords_not_match',
      'resetting_password',
      'verify_code_required',
    };

    final Map<String, Map<String, String>> translations =
        AppTranslations().keys;
    for (final MapEntry<String, Map<String, String>> locale
        in translations.entries) {
      for (final String key in requiredKeys) {
        expect(
          locale.value[key],
          isNotNull,
          reason: '${locale.key} is missing $key',
        );
        expect(
          locale.value[key],
          isNot(key),
          reason: '${locale.key} has not translated $key',
        );
      }
    }
  });

  test('water level warning translations exist in every locale', () {
    final Map<String, Map<String, String>> translations =
        AppTranslations().keys;

    for (final MapEntry<String, Map<String, String>> locale
        in translations.entries) {
      expect(
        locale.value['water_level_warning_title'],
        isNotNull,
        reason: '${locale.key} needs a water level warning title',
      );
      expect(
        locale.value['water_level_warning_message'],
        isNotNull,
        reason: '${locale.key} needs a water level warning message',
      );
    }
  });

  testWidgets('water level warning dialog renders localized text', (
    WidgetTester tester,
  ) async {
    Get.addTranslations(AppTranslations().keys);
    Get.updateLocale(const Locale('zh', 'CN'));

    await tester.pumpWidget(
      const GetMaterialApp(
        home: Scaffold(body: Center(child: WaterLevelWarningDialog())),
      ),
    );

    expect(find.text('设备缺水提醒'), findsOneWidget);
    expect(find.text('水箱水量不足，请及时加水后继续使用设备'), findsOneWidget);
  });

  testWidgets('water level dialog closes when 0x01E5 recovers', (
    WidgetTester tester,
  ) async {
    Get.testMode = true;
    Get.addTranslations(AppTranslations().keys);
    Get.updateLocale(const Locale('zh', 'CN'));
    Get.put(UserStore());
    addTearDown(() {
      if (Get.isRegistered<AppHeaderClockController>()) {
        Get.delete<AppHeaderClockController>(force: true);
      }
      Get.reset();
    });

    final _FakeWaterLevelModbusService modbusService =
        _FakeWaterLevelModbusService();

    await tester.pumpWidget(
      GetMaterialApp(
        navigatorObservers: [appRouteObserver],
        home: MainPage(modbusService: modbusService),
      ),
    );

    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('设备缺水提醒'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.text('设备缺水提醒'), findsNothing);
    expect(modbusService.waterLevelReads, greaterThanOrEqualTo(2));

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    if (Get.isRegistered<AppHeaderClockController>()) {
      Get.find<AppHeaderClockController>().onClose();
      Get.delete<AppHeaderClockController>(force: true);
    }
  });

  test('LoginResult parses backend login data', () {
    final LoginResult result = LoginResult.fromJson({
      'id': '0',
      'email': '00000000',
      'role': 'user',
    });

    expect(result.id, 0);
    expect(result.email, '00000000');
    expect(result.role, 'user');
  });

  test('therapy report request serializes duration seconds', () {
    final Map<String, Object?> json = SaveTherapyReportRequestDto(
      clientId: 7,
      planName: 'Relax',
      planType: 'preset',
      reportTime: DateTime(2026, 6, 9, 9, 0),
      durationSeconds: 125,
      usedModulesJson: '["redlight"]',
      therapyFeedback: '',
      modules: const [],
    ).toJson();

    expect(json['durationSeconds'], 125);
    expect(json.containsKey('durationMinutes'), isFalse);
  });

  // 测试治疗记录报告用户列表解析
  test('history report user page parses backend data', () {
    final HistoryReportUserPageDto page = HistoryReportUserPageDto.fromJson({
      'items': [
        {
          'clientId': 3,
          'userName': 'Alice',
          'userAge': 28,
          'userPhone': '13800000000',
          'lastReportId': 11,
          'lastReportTime': '2026-06-09T10:00:00',
        },
      ],
      'page': 2,
      'pageSize': 10,
      'total': 21,
      'hasMore': true,
    });

    expect(page.items, hasLength(1));
    expect(page.items.first.clientId, 3);
    expect(page.items.first.userName, 'Alice');
    expect(page.items.first.lastReportId, 11);
    expect(page.page, 2);
    expect(page.pageSize, 10);
    expect(page.total, 21);
    expect(page.hasMore, isTrue);
  });

  test('therapy report detail parses backend data', () {
    final TherapyReportDetailDto detail = TherapyReportDetailDto.fromJson({
      'report': {
        'reportId': 11,
        'clientId': 3,
        'userNameSnapshot': 'Alice',
        'userAgeSnapshot': 28,
        'userPhoneSnapshot': '13800000000',
        'planNameSnapshot': 'Deep relax',
        'reportTime': '2026-06-09T10:00:00',
        'durationSeconds': 1493,
        'energyScore': 50,
        'cellScore': 51,
        'relaxScore': 52,
        'immuneScore': 53,
        'therapyFeedback': 'felt relaxed',
      },
      'modules': [
        {
          'moduleCode': 'red',
          'moduleName': '红光',
          'runDurationMinutes': 10,
          'runStatus': 'completed',
        },
      ],
      'vitals': [
        {
          'vitalCode': 'heart_rate',
          'vitalName': '心率',
          'vitalValue': 72,
          'vitalUnit': 'bpm',
        },
      ],
    });

    expect(detail.report.reportId, 11);
    expect(detail.report.userNameSnapshot, 'Alice');
    expect(detail.report.durationSeconds, 1493);
    expect(detail.modules.single.moduleName, '红光');
    expect(detail.vitals.single.vitalCode, 'heart_rate');
  });

  test('therapy report detail page parses backend data', () {
    final TherapyReportDetailPageDto page = TherapyReportDetailPageDto.fromJson(
      {
        'items': [
          {
            'report': {
              'reportId': 12,
              'clientId': 3,
              'userNameSnapshot': 'Alice',
              'userAgeSnapshot': 28,
              'userPhoneSnapshot': '13800000000',
              'planNameSnapshot': 'Deep relax',
              'reportTime': '2026-06-09T12:00:00',
              'durationSeconds': 1500,
            },
            'modules': [
              {
                'moduleCode': 'relax',
                'moduleName': '深度放松',
                'runDurationMinutes': 25,
                'runStatus': 'completed',
              },
            ],
            'vitals': [],
          },
        ],
        'page': 1,
        'pageSize': 5,
        'total': 6,
        'hasMore': true,
      },
    );

    expect(page.items, hasLength(1));
    expect(page.items.first.report.reportId, 12);
    expect(page.items.first.modules.single.moduleName, '深度放松');
    expect(page.pageSize, 5);
    expect(page.total, 6);
    expect(page.hasMore, isTrue);
  });

  test('history record logic refreshes and loads next page', () async {
    final FakeHistoryRecordRepository repository =
        FakeHistoryRecordRepository();
    final HistoryRecordLogic logic = HistoryRecordLogic(
      repository: repository,
      ownerUserId: 9,
      pageSize: 10,
    );

    await logic.refresh(keyword: ' Ali ');

    expect(logic.users, hasLength(1));
    expect(logic.users.first.userName, 'Alice');
    expect(logic.keyword, 'Ali');
    expect(logic.page, 1);
    expect(logic.hasMore, isTrue);

    await logic.loadNextPage();

    expect(logic.users, hasLength(2));
    expect(logic.users.last.userName, 'Bob');
    expect(logic.page, 2);
    expect(logic.hasMore, isFalse);
    expect(repository.requestedPages, [1, 2]);
    expect(repository.requestedKeywords, ['Ali', 'Ali']);
  });

  test('history record logic deletes user reports from list', () async {
    final FakeHistoryRecordRepository repository =
        FakeHistoryRecordRepository();
    final HistoryRecordLogic logic = HistoryRecordLogic(
      repository: repository,
      ownerUserId: 9,
      pageSize: 10,
    );

    await logic.refresh();
    await logic.deleteUserReports(3);

    expect(logic.users, isEmpty);
    expect(repository.deletedClientIds, [3]);
  });

  test('development account is not treated as a registration email', () {
    expect(isValidEmail('00000000'), isFalse);
    expect(isValidEmail('user@example.com'), isTrue);
  });

  test('HifemRegionSetting copyWith preserves and clamps percentages', () {
    const HifemRegionSetting setting = HifemRegionSetting(
      rfPercent: 20,
      hifesPercent: 30,
    );

    final HifemRegionSetting updated = setting.copyWith(rfPercent: 120);

    expect(updated.rfPercent, 100);
    expect(updated.hifesPercent, 30);
  });

  test('customized VAT shares music and intensity across phases', () {
    final StartLogic logic = StartLogic();
    logic.configure({
      'customizedPlan': const CustomizedPlanData(
        name: 'VAT',
        featureIds: [
          'phase:0:vat',
          'vat:0:frequency=20|intensity=55|songId=Aria 2',
          'phase:1:vat',
          'vat:1:frequency=40|intensity=80|songId=Immortal Love',
        ],
      ),
    });

    expect(logic.activeVatSetting?.frequency, 20);
    expect(logic.activeVatSetting?.intensity, 55);
    expect(logic.activeVatSetting?.songId, 'Aria 2');

    logic.elapsedSeconds = StartLogic.phaseSeconds;

    expect(logic.activeVatSetting?.frequency, 40);
    expect(logic.activeVatSetting?.intensity, 55);
    expect(logic.activeVatSetting?.songId, 'Aria 2');
  });

  test('VAT default song exists in the playlist', () {
    expect(findSongById(defaultSongId), isNotNull);
  });
}

class _FakeWaterLevelModbusService extends ModbusRtuService {
  _FakeWaterLevelModbusService() : super();

  int waterLevelReads = 0;

  @override
  Future<int> readHoldingRegister(int address) async {
    if (address == 0x01E5) {
      waterLevelReads++;
      return waterLevelReads == 1 ? 0 : 1;
    }
    if (address == 0x0012) return 1;
    if (address == 0x0006) return 0;
    return 1;
  }

  @override
  Future<void> sendCommandQueue(List<ModbusWriteCommand> commands) async {}
}

class FakeHistoryRecordRepository implements HistoryRecordRepository {
  final List<int> requestedPages = [];
  final List<String> requestedKeywords = [];
  final List<int> deletedClientIds = [];

  @override
  Future<HistoryReportUserPageDto> historyUsers({
    required int ownerUserId,
    required int page,
    required int pageSize,
    required String keyword,
  }) async {
    requestedPages.add(page);
    requestedKeywords.add(keyword);

    if (page == 1) {
      return HistoryReportUserPageDto(
        items: [
          HistoryReportUserItemDto(
            clientId: 3,
            userName: 'Alice',
            userAge: 28,
            userPhone: '13800000000',
            lastReportId: 11,
            lastReportTime: DateTime(2026, 6, 9, 10),
          ),
        ],
        page: 1,
        pageSize: pageSize,
        total: 2,
        hasMore: true,
      );
    }

    return HistoryReportUserPageDto(
      items: [
        HistoryReportUserItemDto(
          clientId: 4,
          userName: 'Bob',
          userAge: 36,
          userPhone: '13900000000',
          lastReportId: 12,
          lastReportTime: DateTime(2026, 6, 9, 11),
        ),
      ],
      page: 2,
      pageSize: pageSize,
      total: 2,
      hasMore: false,
    );
  }

  @override
  Future<void> deleteHistoryUser({
    required int ownerUserId,
    required int clientId,
  }) async {
    deletedClientIds.add(clientId);
  }
}
