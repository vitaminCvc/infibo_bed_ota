// 主页面导航逻辑。
//
// 负责打开预设模式的用户选择页，以及进入自定义方案列表页。
import 'package:get/get.dart';
import 'package:infibo_app/preset/a_cankao/preset_models.dart';
import 'package:infibo_app/preset/a_cankao/preset_registry.dart';

// 主页面逻辑控制器。
class MainLogic extends GetxController {
  // 跳转到模式对应页面。
  void openModeDetail(String titleKey) {
    final PresetMode? preset = presetByTitleKey(titleKey);
    if (preset == null) return;

    Get.toNamed(
      '/choseusers',
      arguments: {
        'modeTitle': preset.titleKey.tr,
        'presetCode': preset.code,
        'presetTitleKey': preset.titleKey,
      },
    );
  }

  // 跳转到自定义页面。
  void openCustomizedPage() {
    Get.toNamed('/customized');
  }
}
