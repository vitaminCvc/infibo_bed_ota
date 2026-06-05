// 自定义方案编辑页的业务逻辑。
//
// UI 页只负责收集“方案名 + 功能 id 列表”，这个类负责判断是新增方案
// 还是编辑已有方案，并调用自定义方案列表逻辑写入本地数据库。
import 'package:get/get.dart';
import 'package:infibo_app/pages/customized/logic.dart';

// 自定义方案编辑页逻辑。
class CustomizedEditLogic {
  /////自定义方案页与后端联调，之后这里不要再直接 new CustomizedLogic 操作本地库，应复用后端方案仓库/API。
  final CustomizedLogic _planLogic = CustomizedLogic();

  /////自定义方案页与后端联调，之后编辑已有方案时需要确保 arguments 里有后端 planId 和完整配置，不只是一组本地 featureIds。
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
    /////自定义方案页与后端联调，之后这里保存时要把 featureIds 组装成后端 request：planName、durationMinutes、usedModulesJson、planConfigJson。
    await _planLogic.init();

    final CustomizedPlanData? plan = editingPlan;
    if (plan == null) {
      /////自定义方案页与后端联调，之后新增分支调用 POST /therapy/plan/custom。
      await _planLogic.addPlan(name: name, featureIds: featureIds);
    } else {
      /////自定义方案页与后端联调，之后编辑分支需要调用后端更新方案配置接口；当前后端只有重命名接口时，要先补后端完整更新接口。
      await _planLogic.updatePlan(
        plan.copyWith(name: name, featureIds: featureIds),
      );
    }
  }
}
