// 香氛设置页共享状态。
//
// 保存用户最后确认的香型，让页面返回后仍能恢复上次选择。
import 'package:get/get.dart';

class FragranceSettingController extends GetxController {
  static const String defaultFragranceId = '';

  String _selectedFragranceId = defaultFragranceId;

  String get selectedFragranceId => _selectedFragranceId;

  static FragranceSettingController get instance {
    if (Get.isRegistered<FragranceSettingController>()) {
      return Get.find<FragranceSettingController>();
    }
    return Get.put(FragranceSettingController(), permanent: true);
  }

  void saveSelectedFragrance(String id) {
    if (id.trim().isEmpty) return;
    _selectedFragranceId = id;
    update();
  }
}
