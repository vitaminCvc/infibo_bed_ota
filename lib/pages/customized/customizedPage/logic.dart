// 自定义方案编辑页的业务逻辑。
//
// UI 页只负责收集“方案名 + 功能 id 列表”，这个类负责判断是新增方案
// 还是编辑已有方案，并调用自定义方案列表逻辑写入本地数据库。
import 'package:get/get.dart';
import 'package:infibo_app/pages/customized/logic.dart';

// 自定义方案编辑页逻辑。
class CustomizedEditLogic {
  final CustomizedLogic _planLogic = CustomizedLogic();

  CustomizedPlanData? get editingPlan {
    final Object? args = Get.arguments;
    if (args is Map && args['plan'] is CustomizedPlanData) {
      return args['plan'] as CustomizedPlanData;
    }
    return null;
  }

  Future<void> savePlan({
    required String name,
    required List<String> featureIds,
  }) async {
    await _planLogic.init();

    final CustomizedPlanData? plan = editingPlan;
    if (plan == null) {
      await _planLogic.addPlan(name: name, featureIds: featureIds);
    } else {
      await _planLogic.updatePlan(
        plan.copyWith(name: name, featureIds: featureIds),
      );
    }
  }
}
