// 太赫兹设置页共享状态。
//
// 保存频率、功率、模式和波形，让页面返回后仍能恢复上次确认的设置。
import 'package:get/get.dart';
import 'package:infibo_app/utils/number_utils.dart';

class TerahertzSettingSnapshot {
  const TerahertzSettingSnapshot({
    required this.frequency,
    required this.power,
    required this.mode,
    required this.wave,
  });

  final double frequency;
  final double power;
  final String? mode;
  final String? wave;
}

class TerahertzSettingController extends GetxController {
  double _frequency = 0;
  double _power = 0;
  String? _mode;
  String? _wave;

  static TerahertzSettingController get instance {
    if (Get.isRegistered<TerahertzSettingController>()) {
      return Get.find<TerahertzSettingController>();
    }
    return Get.put(TerahertzSettingController(), permanent: true);
  }

  TerahertzSettingSnapshot snapshot() {
    return TerahertzSettingSnapshot(
      frequency: _frequency,
      power: _power,
      mode: _mode,
      wave: _wave,
    );
  }

  void save({
    required double frequency,
    required double power,
    required String? mode,
    required String? wave,
  }) {
    _frequency = clampPercentageDouble(frequency);
    _power = clampPercentageDouble(power);
    _mode = mode;
    _wave = wave;
    update();
  }
}
