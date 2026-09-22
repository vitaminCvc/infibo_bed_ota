// 自定义方案编辑页的业务逻辑。
//
// UI 页只负责收集“方案名 + 功能 id 列表”，这个类负责判断是新增方案
// 还是编辑已有方案，并调用自定义方案列表逻辑保存到后端。
import 'package:get/get.dart';
import 'package:infibo_app/pages/customized/logic.dart';

// 自定义方案编辑页逻辑。
class CustomizedEditLogic {
  CustomizedEditLogic({CustomizedLogic? planLogic})
    : _planLogic = planLogic ?? CustomizedLogic();

  /////自定义方案页与后端联调，这里之后可以保留，但 CustomizedLogic 内部必须已经改成后端 API。
  /////如果你做 Repository 分层，则把这一行改成：
  /////  final CustomizedPlanRepository _repository = BackendCustomizedPlanRepository();
  /////然后 savePlan 里直接调用 _repository.create/_repository.update。
  final CustomizedLogic _planLogic;

  /////自定义方案页与后端联调，这里要确认传进来的 plan.id 是后端 planId。
  /////如果 customized/logic.dart 的 select/openEditPage 以后只传 planId，则这里要改成从 arguments['planId'] 读取，再调用后端详情接口拿完整方案。
  CustomizedPlanData? get editingPlan {
    final Object? args = Get.arguments;
    if (args is Map && args['plan'] is CustomizedPlanData) {
      return args['plan'] as CustomizedPlanData;
    }
    return null;
  }

  //保存方案方法
  Future<void> savePlan({
    required CustomizedPlanData? editingPlan,
    required String name,
    required List<String> featureIds,
    required int durationMinutes,
  }) async {
    await _planLogic.init();

    if (editingPlan == null) {
      await _planLogic.addPlan(
        name: name,
        featureIds: featureIds,
        durationMinutes: durationMinutes,
      );
    } else {
      if (editingPlan.id == null) {
        throw CustomizedPlanNameException('custom_plan_edit_invalid'.tr);
      }
      await _planLogic.updatePlan(
        plan: editingPlan.copyWith(name: name, featureIds: featureIds),
        durationMinutes: durationMinutes,
      );
    }
  }
}
