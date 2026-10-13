import 'package:flutter/material.dart';

// 独立字体族仅供设置面板使用，避免改变其他页面的字体回退。
const settingsFontFamily = 'InfiboSettingsYaHei';

/// Figma 设置页标题：微软雅黑 Regular，24px 字号、36px 行高。
const settingsPanelTitleStyle = TextStyle(
  color: Colors.white,
  fontFamily: settingsFontFamily,
  fontSize: 24,
  fontWeight: FontWeight.w400,
  height: 1.5,
  letterSpacing: 0,
);

const settingsCardHorizontalPadding = 26.0;
