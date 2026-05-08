// 香氛设置页的状态控制器。
//
// 这里只保存一个 selectedFragranceId。使用 GetX permanent controller，
// 让用户确认返回后再次进入香氛页时，还能看到上次确认的香型。
import 'package:get/get.dart';

class FragranceSettingController extends GetxController {
  static const String defaultFragranceId = 'soft';

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
