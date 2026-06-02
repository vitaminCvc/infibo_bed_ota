import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/api/dio/login/login_models.dart';
import 'package:infibo_app/pages/customized/logic.dart';
import 'package:infibo_app/pages/music/logic.dart';
import 'package:infibo_app/pages/start/logic.dart';
import 'package:infibo_app/stores/hifem_setting_store.dart';
import 'package:infibo_app/utils/email_utils.dart';

void main() {
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
