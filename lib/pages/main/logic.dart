// 主页面导航逻辑。
//
// 负责打开预设模式的用户选择页，以及进入自定义方案列表页。
import 'package:get/get.dart';
import 'package:infibo_app/preset/a_cankao/preset_models.dart';
import 'package:infibo_app/preset/a_cankao/preset_registry.dart';
import 'package:infibo_app/utils/network_checker.dart';

// 主页面逻辑控制器。
class MainLogic extends GetxController {
  // 跳转到模式对应页面。
  Future<void> openModeDetail(String titleKey) async {
    final PresetMode? preset = presetByTitleKey(titleKey);
    if (preset == null) return;

    bool online = false;
    try {
      online = await NetworkChecker.isConnected();
    } catch (_) {
      // 网络检测失败时默认走在线模式，保证原有流程不受影响。
      online = true;
    }

    if (!online) {
      // 离线模式：跳过用户选择，直接进入启动页。
      Get.toNamed(
        '/start',
        arguments: {
          'modeTitle': preset.titleKey.tr,
          'presetCode': preset.code,
          'presetTitleKey': preset.titleKey,
          'isOfflineMode': true,
        },
      );
      return;
    }

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
