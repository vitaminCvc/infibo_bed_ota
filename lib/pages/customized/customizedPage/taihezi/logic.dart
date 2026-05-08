// 太赫兹设置页的状态模型和控制器。
//
// 保存频率、功率、模式、波形四个值。controller 常驻在 GetX 里，
// 用来支持“确认返回后再次进入页面继续修改”。
import 'package:get/get.dart';

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
    _frequency = frequency.clamp(0, 100).toDouble();
    _power = power.clamp(0, 100).toDouble();
    _mode = mode;
    _wave = wave;
    update();
  }
}
