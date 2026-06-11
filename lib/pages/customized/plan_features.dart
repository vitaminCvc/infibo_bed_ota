// 自定义方案功能点目录。
//
// 把方案里保存的功能 id 转成页面展示需要的标题、图标和颜色。
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/constants/assets.dart';

const List<PlanFeatureData> planFeatureCatalog = [
  PlanFeatureData(
    id: 'redlight',
    title: 'red_light',
    asset: Assets.startRedLightIconOn,
    color: Color(0xFFF08A23),
  ),
  PlanFeatureData(
    id: 'pemf',
    title: 'PEMF',
    asset: Assets.startPemfIconOn,
    color: Color(0xFF1F78E8),
  ),
  PlanFeatureData(
    id: 'vat',
    title: 'VAT',
    asset: Assets.startVatIconOn,
    color: Color(0xFF35A9B8),
  ),
  PlanFeatureData(
    id: 'hydrogen',
    title: 'module_hydrogen',
    asset: Assets.startHydrogenIconOn,
    color: Color(0xFF35A9B8),
  ),
  PlanFeatureData(
    id: 'expand',
    title: 'module_expand',
    asset: Assets.expandIcon,
    color: Color(0xFF12A36B),
  ),
];

PlanFeatureData? featureById(String id) {
  for (final PlanFeatureData feature in planFeatureCatalog) {
    if (feature.id == id) return feature;
  }
  return null;
}

List<String> knownFeatureIds(Iterable<String> ids) {
  return [
    for (final String id in ids)
      if (featureById(id) != null) id,
  ];
}

class PlanFeatureData {
  const PlanFeatureData({
    required this.id,
    required this.title,
    required this.asset,
    required this.color,
  });

  final String id;
  final String title;
  String get translatedTitle => title.tr;
  final String asset;
  final Color color;
}

class PlanFeatureDot extends StatelessWidget {
  const PlanFeatureDot({super.key, required this.feature, this.size = 24});

  final PlanFeatureData feature;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(feature.asset, fit: BoxFit.contain),
    );
  }
}
