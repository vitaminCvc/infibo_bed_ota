import 'package:flutter_test/flutter_test.dart';
import 'package:infibo_app/preset/a_cankao/preset_registry.dart';

void main() {
  test('registry contains P01 through P10 in order', () {
    expect(allPresetModes, hasLength(10));
    expect(allPresetModes.map((preset) => preset.code), <String>[
      'P01',
      'P02',
      'P03',
      'P04',
      'P05',
      'P06',
      'P07',
      'P08',
      'P09',
      'P10',
    ]);
  });

  test('registry finds presets by code and title key', () {
    expect(presetByCode('P01')?.titleKey, 'deep_relax');
    expect(presetByCode('P10')?.titleKey, 'mental_healing');
    expect(presetByTitleKey('immune_boost')?.code, 'P07');
    expect(presetByCode('P99'), isNull);
    expect(presetByTitleKey('missing'), isNull);
  });
}
