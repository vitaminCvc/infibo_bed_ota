import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/pages/start/logic.dart';

void main() {
  test('StartLogic loads a preset plan by preset code', () {
    final StartLogic logic = StartLogic();

    logic.configure(<String, Object>{'presetCode': 'P02'});

    expect(logic.isPresetPlan, isTrue);
    expect(logic.totalSeconds, 20 * 60);
    expect(logic.activeDevices(''), <String>['red', 'pemf', 'vat', 'hydrogen']);
    expect(logic.activePemfSetting?.frequency, 20);
    expect(logic.activePemfSetting?.intensity, 40);
    expect(logic.activePemfSetting?.waveformNumber, 6);
    expect(logic.activePemfSetting?.burstFrequencyHz, 2);
    expect(logic.activeRedLightSetting?.pulseFrequencyHz, 20);
    expect(logic.activeRedLightSetting?.dutyCyclePercent, 70);
    expect(logic.activeVatSetting?.frequency, 20);
    expect(logic.activeVatSetting?.intensity, 40);
    expect(logic.activeVatSetting?.volume, 50);
    expect(logic.activeVatSetting?.songId, '2');
    expect(logic.activeVatSetting?.musicIndex, 2);
    expect(logic.activeHydrogenSetting?.concentration, 50);
  });
}
