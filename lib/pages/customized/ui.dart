// 自定义方案列表页。
//
// 展示用户保存过的自定义理疗方案，支持搜索、编辑、删除和选择方案进入用户选择页。
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/designCanvas/design.dart';
import 'package:infibo_app/components/index.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/constants/layout.dart';
import 'package:infibo_app/pages/customized/logic.dart';
import 'package:infibo_app/pages/customized/plan_features.dart';

// 自定义方案列表页面。
class CustomizedPage extends StatefulWidget {
  const CustomizedPage({super.key});

  @override
  State<CustomizedPage> createState() => _CustomizedPageState();
}

class _CustomizedPageState extends State<CustomizedPage> {
  // 自定义方案页按 800x1160 的设计稿坐标摆放，再根据屏幕宽度整体缩放。
  static const double _designWidth = 800;
  static const double _minPageScale = 0.72;

  // 自定义方案列表逻辑。
  final CustomizedLogic _logic = CustomizedLogic();
  // 搜索框控制器。
  final TextEditingController _searchController = TextEditingController();
  // 方案列表滚动控制器，用于搜索成功后定位到方案。
  final ScrollController _listController = ScrollController();

  // 方案数据是否已经加载完成。
  bool _isReady = false;
  // 长按 2 秒进入编辑页的计时器。
  Timer? _editTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPlans());
  }

  @override
  void dispose() {
    _editTimer?.cancel();
    _searchController.dispose();
    _listController.dispose();
    unawaited(_logic.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLayoutMetrics layout = AppLayoutScope.of(context);
    final double scale =
        ((MediaQuery.sizeOf(context).width - 32) / _designWidth)
            .clamp(_minPageScale, 1.0)
            .toDouble();

    return AppHeaderPage(
      resizeToAvoidBottomInset: false,
      children: [
        Positioned.fill(
          top: 75,
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  width: _designWidth * scale,
                  height: layout.standardContentHeight * scale,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: _designWidth,
                      height: layout.standardContentHeight,
                      child: _buildCanvas(layout),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// 加载自定义方案列表。
  Future<void> _loadPlans() async {
    try {
      await _logic.init();
    } catch (error) {
      if (!mounted) return;
      _showMessage('${'custom_plan_load_failed'.tr}$error');
    }
    if (!mounted) return;
    setState(() => _isReady = true);
  }

  /// 构建自定义方案页主画布。
  Widget _buildCanvas(AppLayoutMetrics layout) {
    return Stack(
      children: [
        Positioned(
          left: 52,
          top: layout.standardContentY(44),
          child: _buildPageTitle(),
        ),
        Positioned(
          left: 45,
          top: layout.standardContentY(130),
          child: _buildSearchBar(),
        ),
        Positioned(
          left: 45,
          top: layout.standardContentY(220),
          child: _buildPlanList(layout),
        ),
        Positioned(
          left: 175,
          bottom: layout.is16x9 ? 46 : 34,
          child: _buildAddButton(),
        ),
      ],
    );
  }

  /// 构建自定义方案页标题。
  Widget _buildPageTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'custom_plan_title'.tr,
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontFamily: 'Microsoft YaHei',
          ),
        ),
      ],
    );
  }

  /// 构建方案搜索框。
  Widget _buildSearchBar() {
    return SizedBox(
      width: 710,
      height: 55,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          //搜素框背景占满整个区域
          Positioned.fill(
            child: Image.asset(Assets.choseUserSearchBg, fit: BoxFit.fill),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 22, right: 22),
            child: Row(
              children: [
                Image.asset(Assets.choseUserSearchIcon, width: 16, height: 16),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    cursorColor: Colors.white,
                    textInputAction: TextInputAction.search, //搜索按钮
                    onEditingComplete: () =>
                        _searchPlan(_searchController.text), //搜索按钮点击事件
                    onSubmitted: _searchPlan, //搜索逻辑
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Microsoft YaHei',
                    ),
                    decoration: InputDecoration(
                      //搜索输入框样式
                      isDense: true,
                      border: InputBorder.none,
                      hintText: 'plan_search_hint'.tr,
                      hintStyle: const TextStyle(
                        color: Color(0xFF8B8E98),
                        fontSize: 16,
                        fontFamily: 'Microsoft YaHei',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建已保存的方案列表。
  /////自定义方案页与后端联调，这里不用改 UI 结构。
  /////只要 customized/logic.dart 的 loadPlans 改成后端 GET，这里的 _logic.plans 就会自动变成后端数据。
  /////如果后端字段名变了，只改 CustomizedPlanData.fromDto，不改这个 ListView。
  Widget _buildPlanList(AppLayoutMetrics layout) {
    final double height = layout.is16x9 ? 900 : 800;
    if (!_isReady) return SizedBox(width: 710, height: height);

    return SizedBox(
      width: 710,
      height: height,
      child: ListView.separated(
        controller: _listController,
        itemCount: _logic.plans.length, //根据逻辑中方案列表长度构建列表
        separatorBuilder: (context, index) =>
            const SizedBox(height: 15), //列表项间距
        itemBuilder: (context, index) {
          final CustomizedPlanData item = _logic.plans[index];
          return Slidable(
            key: ValueKey(item.id ?? '${item.name}-$index'),
            endActionPane: ActionPane(
              motion: const DrawerMotion(),
              extentRatio: 0.18,
              children: [
                CustomSlidableAction(
                  onPressed: (_) => _deletePlan(index),
                  backgroundColor: const Color(0xFFE8473B),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        Assets.customizedDeleteIcon,
                        width: 16,
                        height: 16,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'delete'.tr,
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) => _startEditTimer(item),
              onTapUp: (_) => _cancelEditTimer(),
              onTapCancel: _cancelEditTimer,
              child: _PlanCard(
                item: item,
                isHighlighted: _logic.highlightedIndex == index,
                onRename: () {
                  _cancelEditTimer();
                  _showRenameDialog(index);
                },
                onSelect: () {
                  _cancelEditTimer();
                  /////自定义方案页与后端联调，这里最终建议不要传完整 customizedPlan。
                  /////现在：
                  /////  _logic.selectPlan(item);
                  /////之后保持这行也可以，但 selectPlan 内部要改成传：
                  /////  {'modeTitle': plan.name, 'planId': plan.id, 'planType': 'custom'}
                  _logic.selectPlan(item);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  /// 构建底部添加方案按钮。
  Widget _buildAddButton() {
    return SizedBox(
      width: 450,
      height: 52,
      child: ElevatedButton(
        onPressed: _openAddPage,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF1F74E8),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontFamily: 'Microsoft YaHei',
            fontWeight: FontWeight.w800,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Baseline(
              baseline: 18,
              baselineType: TextBaseline.alphabetic,
              child: Image.asset(
                Assets.customizedSchemeIcon,
                width: 20,
                height: 20,
              ),
            ),
            const SizedBox(width: 8),
            Text('add_plan'.tr),
          ],
        ),
      ),
    );
  }

  /// 进入新增方案页面，返回后刷新方案列表。
  /////自定义方案页与后端联调，这里不用改。
  /////openAddPage 返回后会 setState；只要 _logic.openAddPage 内部 await loadPlans()，就会刷新后端列表。
  Future<void> _openAddPage() async {
    await _logic.openAddPage();
    if (!mounted) return;
    setState(() {});
  }

  /// 搜索方案名称，命中后高亮并滚动到对应方案。
  void _searchPlan(String keyword) {
    if (!_isReady) return;
    FocusScope.of(context).unfocus();

    final int index = _logic.findPlanIndex(keyword);
    if (index < 0) return;

    setState(() => _logic.highlightPlan(index));
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToPlan(index));
  }

  /// 滚动到指定方案。
  void _scrollToPlan(int index) {
    if (!_listController.hasClients) return;

    const double itemHeight = 104;
    const double separatorHeight = 9;
    final double targetOffset = index * (itemHeight + separatorHeight);
    final double maxOffset = _listController.position.maxScrollExtent;

    _listController.animateTo(
      targetOffset.clamp(0, maxOffset),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOut,
    );
  }

  /// 删除指定方案。
  /////自定义方案页与后端联调，这里不用改 UI。
  /////真正改 _logic.deletePlan(index)：里面把 _db.delete 换成 DELETE /therapy/plan/custom/{planId}。
  Future<void> _deletePlan(int index) async {
    await _logic.deletePlan(index);
    if (!mounted) return;

    setState(() {});
  }

  /// 按住方案卡片 1 秒后进入编辑页面。
  /////自定义方案页与后端联调，这里暂时不用改。
  /////但 item.id 必须是后端 planId；如果以后只传 planId，则 _logic.openEditPage(item) 内部要改成 arguments: {'planId': item.id}。
  void _startEditTimer(CustomizedPlanData item) {
    _cancelEditTimer();
    _editTimer = Timer(const Duration(milliseconds: 1000), () async {
      await _logic.openEditPage(item);
      if (!mounted) return;
      setState(() {});
    });
  }

  /// 取消长按编辑计时器。
  void _cancelEditTimer() {
    _editTimer?.cancel();
    _editTimer = null;
  }

  /// 弹出重命名窗口并保存新的方案名称。
  /////自定义方案页与后端联调，这里不用改弹窗。
  /////真正改 _logic.renamePlan(index, name)：里面把本地 updatePlan 换成 PUT /therapy/plan/custom/{planId}/name。
  Future<void> _showRenameDialog(int index) async {
    final TextEditingController controller = TextEditingController(
      text: _logic.plans[index].name,
    );

    final String? name = await showDialog<String>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (context) => _PlanNameDialog(
        title: 'rename_plan'.tr,
        controller: controller,
        validator: (String name) =>
            _logic.validatePlanName(name, excludeId: _logic.plans[index].id),
      ),
    );
    // 弹窗关闭后 TextField 还需要一帧完成卸载，下一帧再释放控制器。
    WidgetsBinding.instance.addPostFrameCallback((_) => controller.dispose());

    if (name == null) return;

    try {
      await _logic.renamePlan(index, name);
    } on CustomizedPlanNameException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
      return;
    }
    if (!mounted) return;
    setState(() {});
  }

  /// 显示操作提示。
  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

// 已保存的方案卡片。
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.item,
    required this.isHighlighted,
    required this.onRename,
    required this.onSelect,
  });

  final CustomizedPlanData item;
  final bool isHighlighted;
  final VoidCallback onRename;
  final VoidCallback onSelect;
  //高亮显示
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 710,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: isHighlighted
            ? const [
                BoxShadow(
                  color: Color.fromARGB(102, 173, 182, 193),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(child: _buildCardBackground()),
          if (isHighlighted) Positioned.fill(child: _buildHighlightOverlay()),
          if (isHighlighted)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(width: 1.5),
                ),
              ),
            ),
          Positioned(left: 20, top: 24, child: _buildTitle()),
          Positioned(left: 20, bottom: 18, child: _buildFeatureIcons()),
          Positioned(
            right: 114,
            bottom: 20,
            child: _RenameButton(onTap: onRename),
          ),
          Positioned(
            right: 18,
            bottom: 20,
            child: _SelectButton(onTap: onSelect),
          ),
        ],
      ),
    );
  }

  /// 构建方案卡片背景。
  Widget _buildCardBackground() {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(Assets.choseUserItemBg),
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  /// 构建方案名称。
  Widget _buildHighlightOverlay() {
    return Container(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildTitle() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          item.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            height: 1,
            fontFamily: 'Microsoft YaHei',
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.chevron_right, color: Color(0xFFB7BAC3), size: 23),
      ],
    );
  }

  /// 构建方案包含的功能图标。
  Widget _buildFeatureIcons() {
    final List<PlanFeatureData> features = [
      for (final String id in item.featureIds)
        if (featureById(id) != null) featureById(id)!,
    ];

    return Row(
      children: [
        for (int index = 0; index < features.length; index++) ...[
          PlanFeatureDot(feature: features[index]),
          if (index != features.length - 1) const SizedBox(width: 5),
        ],
      ],
    );
  }
}

// 方案重命名按钮。
class _RenameButton extends StatelessWidget {
  const _RenameButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 32,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.drive_file_rename_outline, size: 15),
        label: Text('rename_plan'.tr),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          elevation: 0,
          backgroundColor: const Color(0xFF3D3F48),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF4A4D57)),
          ),
          textStyle: const TextStyle(
            fontSize: 13,
            fontFamily: 'Microsoft YaHei',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// 选择方案按钮。
class _SelectButton extends StatelessWidget {
  const _SelectButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 32,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.check_circle_outline, size: 17),
        label: Text('select'.tr),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          elevation: 0,
          backgroundColor: const Color(0xFF1F74E8),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontFamily: 'Microsoft YaHei',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

// 方案命名弹窗。
class _PlanNameDialog extends StatelessWidget {
  const _PlanNameDialog({
    required this.title,
    required this.controller,
    this.validator,
  });

  final String title;
  final TextEditingController controller;
  final String? Function(String name)? validator;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF202127),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      content: TextField(
        controller: controller,
        autofocus: true,
        cursorColor: Colors.white,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'plan_search_hint'.tr,
          hintStyle: const TextStyle(color: Color(0xFF737782)),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF4A4D57)),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF1F74E8)),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('cancel'.tr),
        ),
        TextButton(
          onPressed: () {
            final String name = controller.text.trim();
            if (name.isEmpty) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('plan_name_empty'.tr)));
              return;
            }
            final String? errorText = validator?.call(name);
            if (errorText != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(errorText)));
              return;
            }
            Navigator.of(context).pop(name);
          },
          child: Text('confirm'.tr),
        ),
      ],
    );
  }
}
