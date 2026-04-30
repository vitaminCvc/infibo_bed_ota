import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/index.dart';
import 'package:infibo_app/pages/customized/customizedPage/logic.dart';
import 'package:infibo_app/pages/customized/logic.dart';
import 'package:infibo_app/pages/customized/plan_features.dart';

// 自定义方案选择页面
class CustomizedEditPage extends StatefulWidget {
  const CustomizedEditPage({super.key});

  @override
  State<CustomizedEditPage> createState() => _CustomizedEditPageState();
}

class _CustomizedEditPageState extends State<CustomizedEditPage> {
  static const double _designWidth = 800;
  static const double _designHeight = 1160;
  static const double _minPageScale = 0.72;

  final CustomizedEditLogic _logic = CustomizedEditLogic();
  final TextEditingController _nameController = TextEditingController();

  late final CustomizedPlanData? _editingPlan;
  late final Set<String> _selectedFeatureIds;

  @override
  void initState() {
    super.initState();
    _editingPlan = _logic.editingPlan;
    _nameController.text = _editingPlan?.name ?? '';
    _selectedFeatureIds = {...knownFeatureIds(_editingPlan?.featureIds ?? [])};
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double scale =
        ((MediaQuery.sizeOf(context).width - 32) / _designWidth)
            .clamp(_minPageScale, 1.0)
            .toDouble();

    return AppHeaderPage(
      children: [
        Positioned.fill(
          top: 75,
          child: Center(
            child: Column(
              children: [
                SizedBox(
                  width: _designWidth * scale,
                  height: _designHeight * scale,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: _designWidth,
                      height: _designHeight,
                      child: _buildCanvas(),
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

  Widget _buildCanvas() {
    return Stack(
      children: [
        Positioned(left: 52, top: 44, child: _buildTitle()),
        Positioned(left: 52, top: 145, child: _buildSelectedPreview()),
        Positioned(left: 45, top: 230, child: _buildFeatureGrid()),
        Positioned(left: 175, bottom: 34, child: _buildSaveButton()),
      ],
    );
  }

  Widget _buildTitle() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '自定义方案',
          style: TextStyle(
            color: Colors.white,
            fontSize: 26,
            height: 1,
            fontFamily: 'Microsoft YaHei',
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 13),
        Text(
          'Select Functions',
          style: TextStyle(
            color: Color(0xFFB6B8C0),
            fontSize: 15,
            height: 1,
            fontFamily: 'Microsoft YaHei',
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedPreview() {
    final List<PlanFeatureData> selectedFeatures = [
      for (final String id in _selectedFeatureIds)
        if (featureById(id) != null) featureById(id)!,
    ];

    return SizedBox(
      width: 710,
      height: 58,
      child: Row(
        children: [
          for (final PlanFeatureData feature in selectedFeatures) ...[
            PlanFeatureDot(feature: feature, size: 28),
            const SizedBox(width: 8),
          ],
          if (selectedFeatures.isEmpty)
            const Text(
              '请选择功能',
              style: TextStyle(
                color: Color(0xFF737782),
                fontSize: 16,
                fontFamily: 'Microsoft YaHei',
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return SizedBox(
      width: 710,
      child: Wrap(
        spacing: 18,
        runSpacing: 18,
        children: [
          for (final PlanFeatureData feature in planFeatureCatalog)
            _FeatureChoiceCard(
              feature: feature,
              isSelected: _selectedFeatureIds.contains(feature.id),
              onTap: () => _toggleFeature(feature.id),
            ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: 450,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: _showSaveDialog,
        icon: const Icon(Icons.save_outlined, size: 25),
        label: const Text('保存方案'),
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: const Color(0xFF1F74E8),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(
            fontSize: 21,
            fontFamily: 'Microsoft YaHei',
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _toggleFeature(String id) {
    setState(() {
      if (_selectedFeatureIds.contains(id)) {
        _selectedFeatureIds.remove(id);
      } else {
        _selectedFeatureIds.add(id);
<<<<<<< HEAD
      }//text
=======
      }
>>>>>>> 登录主页选择用户自定义列表
    });
  }

  Future<void> _showSaveDialog() async {
    final String? name = await showDialog<String>(
      context: context,
      builder: (context) => _PlanNameDialog(controller: _nameController),
    );

    if (name == null) return;

    try {
      await _logic.savePlan(
        name: name,
        featureIds: _selectedFeatureIds.toList(),
      );
    } on CustomizedPlanNameException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
      return;
    }
    Get.back(result: true);
  }

  /// 显示操作提示。
  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}

class _FeatureChoiceCard extends StatelessWidget {
  const _FeatureChoiceCard({
    required this.feature,
    required this.isSelected,
    required this.onTap,
  });

  final PlanFeatureData feature;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 220,
        height: 96,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            width: isSelected ? 1.8 : 1,
            color: isSelected
                ? const Color(0xFF1F74E8)
                : const Color(0xFF373A45),
          ),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF22242B), Color(0xFF1A1B21)],
          ),
        ),
        child: Row(
          children: [
            PlanFeatureDot(feature: feature, size: 34),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                feature.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: 'Microsoft YaHei',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isSelected
                  ? const Color(0xFF1F74E8)
                  : const Color(0xFF737782),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanNameDialog extends StatelessWidget {
  const _PlanNameDialog({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF202127),
      title: const Text('方案命名', style: TextStyle(color: Colors.white)),
      content: TextField(
        controller: controller,
        autofocus: true,
        cursorColor: Colors.white,
        style: const TextStyle(color: Colors.white),
        decoration: const InputDecoration(
          hintText: '输入方案名称',
          hintStyle: TextStyle(color: Color(0xFF737782)),
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
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: () {
            final String name = controller.text.trim();
            if (name.isEmpty) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('方案名称不能为空')));
              return;
            }
            Navigator.of(context).pop(name);
          },
          child: const Text('保存'),
        ),
      ],
    );
  }
}
