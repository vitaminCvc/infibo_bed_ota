// 理疗总结页面。
//
// 展示本次理疗的用户、模块运行时长、健康指标和反馈输入区域。
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/designCanvas/design.dart';
import 'package:infibo_app/components/index.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/pages/summary/logic.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  static const double _designWidth = 800;
  static const double _summaryBottomMargin = 80;
  static const double _keyboardButtonGap = 24;

  final SummaryLogic _logic = SummaryLogic();

  @override
  void initState() {
    super.initState();
    // 页面打开时读取启动页传来的用户和模块运行数据，并开启 2 分钟无操作计时。
    _logic.configure(Get.arguments);
    _logic.startIdleTimer();
  }

  @override
  void dispose() {
    _logic.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool is16x9 = AppLayoutScope.of(context).is16x9;
    // 获取键盘高度
    final double keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    // 键盘显示（正在打字）时暂停空闲自动返回，键盘收起后再重新计时。
    _logic.setKeyboardVisible(keyboardHeight > 0);
    final double keyboardShift = keyboardHeight > 0
        ? math.max(
            0,
            keyboardHeight - _summaryBottomMargin + _keyboardButtonGap,
          )
        : 0;

    // 监听页面上的点击、滑动和滚动；只要用户有操作，就重新计算 2 分钟。
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _logic.recordUserAction(),
      onPointerMove: (_) => _logic.recordUserAction(),
      onPointerSignal: (_) => _logic.recordUserAction(),
      child: AppHeaderPage(
        // 当键盘弹出来时，页面不自动调整大小，保持原样显示
        resizeToAvoidBottomInset: false,
        children: [
          Positioned.fill(
            top: 100,
            child: ClipRect(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                transform: Matrix4.translationValues(0, -keyboardShift, 0),
                child: LayoutBuilder(
                  builder: (context, constraints) => Center(
                    child: SizedBox(
                      width: _designWidth,
                      height: constraints.maxHeight,
                      child: _buildSummary(
                        _logic,
                        is16x9: is16x9,
                        canvasHeight: constraints.maxHeight,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (keyboardHeight > 0)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 120,
              child: IgnorePointer(
                child: Container(color: const Color(0xFF020308)),
              ),
            ),
        ],
      ),
    );
  }
}

Widget _buildSummary(
  SummaryLogic logic, {
  required bool is16x9,
  required double canvasHeight,
}) {
  const double buttonHeight = 56;
  const double feedbackButtonGap = 46;
  final double feedbackHeight = is16x9 ? 221 : 134;
  final double buttonTop = is16x9 ? canvasHeight - 80 - buttonHeight : 1040;
  final double feedbackTop = is16x9
      ? buttonTop - feedbackButtonGap - feedbackHeight
      : 860;

  return Stack(
    children: [
      // 用户信息
      Positioned(top: 20, left: 45, child: _buildUser(logic)),

      // 标题：疗程报告标题
      Positioned(top: 72, left: 45, child: _buildSummaryTitle1()),

      // 疗程报告卡片
      Positioned(top: 122, left: 45, child: _buildrunDuration(logic)),

      // 标题：健康效果评估
      Positioned(top: 320, left: 45, child: _buildSummaryTitle2()),

      // 健康效果评估卡片
      Positioned(top: 368, left: 45, child: _buildHealthEffectCards()),

      // 健康效果评估感受
      Positioned(
        top: feedbackTop,
        left: 45,
        child: _buildFeelingBox(logic, height: feedbackHeight),
      ),

      // 确认按钮
      Positioned(
        top: buttonTop,
        left: 0,
        right: 0,
        child: Center(child: _buildButton(logic)),
      ),
    ],
  );
}

// 用户信息
Widget _buildUser(SummaryLogic logic) {
  return Text(
    logic.userName,
    style: const TextStyle(fontSize: 20, color: Color(0xFFFFFFFF)),
  );
}

// 标题1
Widget _buildSummaryTitle1() {
  return SizedBox(
    width: 710,
    child: Row(
      children: [
        Container(
          width: 3,
          height: 24,
          decoration: BoxDecoration(color: Color(0xff1464DF)),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            'therapy_report'.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFFFFFF),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildrunDuration(SummaryLogic logic) {
  return Row(
    children: [
      _buildRedLight(logic),
      const SizedBox(width: 20),
      _buildPEMF(logic),
      const SizedBox(width: 20),
      _buildVAT(logic),
      const SizedBox(width: 20),
      _buildHydrogen(logic),
      const SizedBox(width: 20),
      // _buildExpand(logic),
    ],
  );
}

// 红光
Widget _buildRedLight(SummaryLogic logic) {
  return _buildModuleCard(
    icon: Assets.startRedLightIconOn,
    title: 'red_light'.tr,
    durationText: logic.moduleDurationText('red'),
  );
}

// PEMF
Widget _buildPEMF(SummaryLogic logic) {
  return _buildModuleCard(
    icon: Assets.startPemfIconOn,
    title: 'PEMF',
    durationText: logic.moduleDurationText('pemf'),
  );
}

// VAT
Widget _buildVAT(SummaryLogic logic) {
  return _buildModuleCard(
    icon: Assets.startVatIconOn,
    title: 'VAT',
    durationText: logic.moduleDurationText('vat'),
  );
}

// 分子氢
Widget _buildHydrogen(SummaryLogic logic) {
  return _buildModuleCard(
    icon: Assets.startHydrogenIconOn,
    title: 'module_hydrogen'.tr,
    durationText: logic.moduleDurationText('hydrogen'),
  );
}

// 拓展
// Widget _buildExpand(SummaryLogic logic) {
//   return _buildModuleCard(
//     icon: Assets.expandIcon,
//     title: 'module_expand'.tr,
//     durationText: logic.moduleDurationText('expand'),
//   );
// }

Widget _buildModuleCard({
  required String icon,
  required String title,
  required String durationText,
  FontWeight titleWeight = FontWeight.w400,
}) {
  return _buildGlassCard(
    width: 162,
    height: 170,
    padding: EdgeInsets.zero,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(icon),
        const SizedBox(height: 14),
        SizedBox(
          width: 104,
          height: 42,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              title,
              maxLines: 2,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: titleWeight,
                color: const Color(0xFFFFFFFF),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          durationText,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 14, color: Color(0xFF9A9DA8)),
        ),
      ],
    ),
  );
}

// 标题2
Widget _buildSummaryTitle2() {
  return SizedBox(
    width: 710,
    child: Row(
      children: [
        Container(
          width: 3,
          height: 24,
          decoration: BoxDecoration(color: Color(0xff1464DF)),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            'health_effect_assessment'.tr,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Color(0xFFFFFFFF),
            ),
          ),
        ),
      ],
    ),
  );
}
///////////////////////////////////////////////健康效果评估卡片///////////////////////////////

// 健康效果评估卡片区域
Widget _buildHealthEffectCards() {
  return Column(
    children: [
      Row(
        children: [
          _buildEnergyCard(),
          const SizedBox(width: 20),
          _buildCellCard(),
        ],
      ),
      const SizedBox(height: 20),
      Row(
        children: [
          _buildRelaxCard(),
          const SizedBox(width: 20),
          _buildImmuneCard(),
        ],
      ),
    ],
  );
}

// 能量指数
Widget _buildEnergyCard() {
  const int score = 0;
  const List<Color> themeColors = [
    Color(0xFF22D7FF),
    Color(0xFF1299FF),
    Color(0xFF1768FF),
  ];

  return _buildHealthEffectCard(
    backgroundImage: Assets.energy,

    title: 'energy_score'.tr,
    tagText: 'status_good'.tr,
    score: '--',
    unit: '/100',
    changeText: '${'compared_to_last'.tr}   --',

    scoreColor: const Color(0xFF1299FF),
    scoreGradientColors: themeColors,
    chartLeft: 200,
    chartTop: 82,
    chartWidth: 120,
    chartHeight: 120,
    chart: _buildCircleScoreChart(score: score, gradientColors: themeColors),
  );
}

// 细胞活化
Widget _buildCellCard() {
  const int score = 0;
  const List<Color> themeColors = [
    Color(0xFFFFC266),
    Color(0xFFFF7A2A),
    Color(0xFFFF4D2A),
  ];

  return _buildHealthEffectCard(
    backgroundImage: Assets.cell,
    title: 'cell_score'.tr,
    tagText: 'status_good'.tr,
    score: '--',
    unit: '/100',
    changeText: '${'compared_to_last'.tr}   --',
    scoreColor: const Color(0xFFFF7A2A),
    scoreGradientColors: themeColors,
    chartLeft: 178,
    chartTop: 85,
    chartWidth: 140,
    chartHeight: 119,
    chart: _buildBarChart(
      values: const [0, 0, 0, 0],
      gradientColors: themeColors,
    ),
  );
}

// 放松指数
Widget _buildRelaxCard() {
  const int score = 0;
  const List<Color> themeColors = [
    Color(0xFFC58CFF),
    Color(0xFF9B6BFF),
    Color(0xFF6B4DFF),
  ];

  return _buildHealthEffectCard(
    backgroundImage: Assets.relax,
    title: 'relaxation_score'.tr,
    tagText: 'status_good'.tr,
    score: '--',
    unit: '/100',
    changeText: '${'compared_to_last'.tr}   --',
    scoreColor: const Color(0xFF9B6BFF),
    scoreGradientColors: themeColors,
    //放松指数坐标轴的位置
    chartLeft: 26,
    chartTop: 160,
    chartWidth: 290,
    chartHeight: 48,

    // 单独调“较上次”左右位置
    changeTextLeft: 150,

    // 单独调“较上次”上下位置
    changeTextTop: 117,

    chart: _buildRelaxSliderChart(score: score, gradientColors: themeColors),
  );
}

// 免疫提升
Widget _buildImmuneCard() {
  const int score = 0;
  const List<Color> themeColors = [
    Color(0xFF7AFADC),
    Color(0xFF28D3A3),
    Color(0xFF09A883),
  ];

  return _buildHealthEffectCard(
    backgroundImage: Assets.immune,
    title: 'immune_score'.tr,
    tagText: 'status_good'.tr,
    score: '--',
    unit: '/100',
    changeText: '${'compared_to_last'.tr}   --',
    scoreColor: const Color(0xFF28D3A3),
    scoreGradientColors: themeColors,
    chartLeft: 168,
    chartTop: 76,
    chartWidth: 149,
    chartHeight: 120,

    // 这里不要再写 scoreTop: 88
    // 不写就会使用默认 scoreTop: 100，和放松指数、能量指数、细胞活化保持一致。
    chart: _buildGaugeChart(score: score, gradientColors: themeColors),
  );
}

// 通用健康效果评估卡片
Widget _buildHealthEffectCard({
  // 背景图
  required String backgroundImage,
  // 标题
  required String title,
  // 状态标签
  required String tagText,
  // 得分
  required String score,
  // 单位
  required String unit,
  // 变化文本
  required String changeText,
  // 分数主色
  required Color scoreColor,
  // 分数渐变色
  required List<Color> scoreGradientColors,
  // 图表
  required Widget chart,
  // 图表位置
  required double chartLeft,
  required double chartTop,
  required double chartWidth,
  required double chartHeight,
  double scoreTop = 94,
  double changeTextLeft = 24,
  double changeTextTop = 170,
  double changeTextWidth = 145,
}) {
  final List<String> changeParts = changeText.trim().split(RegExp(r'\s{2,}'));
  final String changePrefix = changeParts.isNotEmpty ? changeParts.first : '';
  final String changeSuffix = changeParts.length > 1 ? changeParts.last : '';

  return SizedBox(
    width: 346,
    height: 226,
    child: Stack(
      children: [
        // 背景图
        Positioned.fill(child: Image.asset(backgroundImage, fit: BoxFit.fill)),

        // 图表
        Positioned(
          left: chartLeft,
          top: chartTop,
          width: chartWidth,
          height: chartHeight,
          child: chart,
        ),

        // 标题
        Positioned(
          top: 31,
          left: 76,
          width: 120,
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Color(0xFFFFFFFF),
            ),
          ),
        ),

        // 状态标签
        Positioned(
          top: 33,
          left: 265,
          child: Container(
            height: 24,
            constraints: const BoxConstraints(maxWidth: 56),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scoreColor.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(20),
            ),
            child: _buildGradientText(
              text: tagText,
              gradientColors: scoreGradientColors,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

        // 分数
        Positioned(
          left: 24,
          top: scoreTop,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildGradientText(
                text: score.toString(),
                gradientColors: scoreGradientColors,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w400,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 6, bottom: 10),
                child: Text(
                  unit,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Color(0xFFC7CAD3),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 较上次
        Positioned(
          left: changeTextLeft,
          top: changeTextTop,
          width: changeTextWidth,
          child: RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              children: [
                TextSpan(
                  text: changePrefix,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFFB8BBC6),
                  ),
                ),
                TextSpan(
                  text: changeSuffix.isEmpty ? '' : '  $changeSuffix',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF2BCD9F),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

///////新增几个图表Wideget///////////////

// 渐变文字
Widget _buildGradientText({
  required String text,
  required List<Color> gradientColors,
  required TextStyle style,
  TextAlign? textAlign,
  TextOverflow? overflow,
}) {
  return ShaderMask(
    blendMode: BlendMode.srcIn,
    shaderCallback: (Rect bounds) {
      return LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradientColors,
      ).createShader(bounds);
    },
    child: Text(
      text,
      textAlign: textAlign,
      maxLines: 1,
      overflow: overflow,
      style: style.copyWith(color: Colors.white),
    ),
  );
}

// 能量指数圆环图
Widget _buildCircleScoreChart({
  required int score,
  required List<Color> gradientColors,
}) {
  return CustomPaint(
    painter: _CircleScorePainter(
      progress: score.clamp(0, 100) / 100,
      gradientColors: gradientColors,
    ),
    child: Center(
      child: Transform.translate(
        // x 控制左右，y 控制上下
        // y 为负数：往上
        // y 为正数：往下
        offset: const Offset(0, 0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$score%',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, color: Color(0xFFFFFFFF)),
            ),
            const SizedBox(height: 2),
            Text(
              'overall_score'.tr,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 10, color: Color(0xFFFFFFFF)),
            ),
          ],
        ),
      ),
    ),
  );
}

// 细胞活化柱状图
Widget _buildBarChart({
  required List<int> values,
  required List<Color> gradientColors,
}) {
  return CustomPaint(
    painter: _BarChartPainter(values: values, gradientColors: gradientColors),
  );
}

// 放松指数滑杆图
Widget _buildRelaxSliderChart({
  required int score,
  required List<Color> gradientColors,
}) {
  return CustomPaint(
    painter: _RelaxSliderPainter(
      progress: score.clamp(0, 100) / 100,
      score: score,
      gradientColors: gradientColors,
    ),
  );
}

// 免疫提升仪表盘
Widget _buildGaugeChart({
  required int score,
  required List<Color> gradientColors,
}) {
  return CustomPaint(
    painter: _GaugePainter(
      progress: score.clamp(0, 100) / 100,
      score: score,
      gradientColors: gradientColors,
    ),
  );
}

////////新增Painter//////

Color _getGradientColor(List<Color> colors, double t) {
  if (colors.isEmpty) {
    return const Color(0xFF1299FF);
  }

  if (colors.length == 1) {
    return colors.first;
  }

  final double safeT = t.clamp(0.0, 1.0);
  final int colorSectionCount = colors.length - 1;
  final double sectionLength = 1 / colorSectionCount;

  int index = (safeT / sectionLength).floor();

  if (index >= colorSectionCount) {
    index = colorSectionCount - 1;
  }

  final double sectionStart = sectionLength * index;
  final double localT = (safeT - sectionStart) / sectionLength;

  return Color.lerp(colors[index], colors[index + 1], localT)!;
}

///// 圆环图 Painter
class _CircleScorePainter extends CustomPainter {
  const _CircleScorePainter({
    required this.progress,
    required this.gradientColors,
  });

  final double progress;
  final List<Color> gradientColors;

  @override
  void paint(Canvas canvas, Size size) {
    const double strokeWidth = 8;

    final double safeProgress = progress.clamp(0, 1);

    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    // 背景圆环
    final Paint backgroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.12);

    // 背景圆环：从 12 点开始画一整圈
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false, backgroundPaint);

    if (safeProgress <= 0) return;

    // 起点：12 点方向
    final double startAngle = -math.pi / 2;

    // 进度长度：顺时针
    final double totalSweepAngle = math.pi * 2 * safeProgress;

    // 分段数量，越大越平滑
    final int segmentCount = math.max(1, (240 * safeProgress).ceil());

    // 满圆时，让颜色最后回到起始色，避免 100% 时接缝明显
    final bool isFullCircle = safeProgress >= 0.999;

    final List<Color> colors = isFullCircle
        ? [...gradientColors, gradientColors.first]
        : gradientColors;

    for (int i = 0; i < segmentCount; i++) {
      final double startT = i / segmentCount;
      final double endT = (i + 1) / segmentCount;
      final double colorT = (startT + endT) / 2;

      final double segmentStartAngle = startAngle + totalSweepAngle * startT;

      // 稍微多画一点，避免每小段之间出现细缝
      final double segmentSweepAngle = totalSweepAngle / segmentCount + 0.002;

      final Paint segmentPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt
        ..color = _getGradientColor(colors, colorT);

      canvas.drawArc(
        rect,
        segmentStartAngle,
        segmentSweepAngle,
        false,
        segmentPaint,
      );
    }

    // 非满圆时，手动画首尾圆角
    if (!isFullCircle) {
      final Offset startPoint = _pointOnCircle(
        center: center,
        radius: radius,
        angle: startAngle,
      );

      final Offset endPoint = _pointOnCircle(
        center: center,
        radius: radius,
        angle: startAngle + totalSweepAngle,
      );

      canvas.drawCircle(
        startPoint,
        strokeWidth / 2,
        Paint()..color = _getGradientColor(colors, 0),
      );

      canvas.drawCircle(
        endPoint,
        strokeWidth / 2,
        Paint()..color = _getGradientColor(colors, 1),
      );
    }
  }

  Offset _pointOnCircle({
    required Offset center,
    required double radius,
    required double angle,
  }) {
    return Offset(
      center.dx + math.cos(angle) * radius,
      center.dy + math.sin(angle) * radius,
    );
  }

  @override
  bool shouldRepaint(covariant _CircleScorePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.gradientColors != gradientColors;
  }
}

// 柱状图 Painter
class _BarChartPainter extends CustomPainter {
  _BarChartPainter({required this.values, required this.gradientColors});

  final List<int> values;
  final List<Color> gradientColors;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.07)
      ..strokeWidth = 1;

    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    const List<String> yLabels = ['100', '75', '50', '25', '0'];
    final List<String> xLabels = [
      'session_once_1'.tr,
      'session_once_2'.tr,
      'session_once_3'.tr,
      'current_session'.tr,
    ];

    final double chartLeft = 28;
    final double chartTop = 8;
    final double chartBottom = size.height - 22;
    final double chartHeight = chartBottom - chartTop;

    for (int i = 0; i < yLabels.length; i++) {
      final double y = chartTop + chartHeight / 4 * i;

      canvas.drawLine(Offset(chartLeft, y), Offset(size.width, y), gridPaint);

      textPainter.text = TextSpan(
        text: yLabels[i],
        style: const TextStyle(fontSize: 9, color: Color(0xFF9A9DA8)),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(0, y - 6));
    }

    final double barWidth = 9;
    final double gap = 20;
    final double firstBarX = chartLeft + 18;

    for (int i = 0; i < values.length; i++) {
      final double value = values[i].clamp(0, 100).toDouble();
      final double barHeight = chartHeight * value / 100;
      final double x = firstBarX + i * gap;
      final double y = chartBottom - barHeight;

      final RRect barRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(5),
      );

      final Paint barPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: gradientColors,
        ).createShader(Rect.fromLTWH(x, chartTop, barWidth, chartHeight));

      canvas.drawRRect(barRect, barPaint);

      textPainter.text = TextSpan(
        text: xLabels[i],
        style: const TextStyle(fontSize: 10, color: Color(0xFF9A9DA8)),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - 5, chartBottom + 6));
    }
  }

  @override
  bool shouldRepaint(covariant _BarChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.gradientColors != gradientColors;
  }
}

// 放松指数滑杆 Painter
class _RelaxSliderPainter extends CustomPainter {
  _RelaxSliderPainter({
    required this.progress,
    required this.score,
    required this.gradientColors,
  });

  final double progress;
  final int score;
  final List<Color> gradientColors;

  Color get _mainColor {
    if (gradientColors.length >= 2) {
      return gradientColors[1];
    }
    return gradientColors.first;
  }

  Color get _endColor {
    return gradientColors.last;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final double safeProgress = progress.clamp(0, 1);
    final double lineY = size.height - 18;
    final double startX = 0;
    final double endX = size.width;
    final double thumbX = startX + (endX - startX) * safeProgress;

    final Paint bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(startX, lineY), Offset(endX, lineY), bgPaint);

    if (safeProgress > 0) {
      final Paint progressPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: gradientColors,
        ).createShader(Rect.fromLTWH(startX, lineY - 8, thumbX - startX, 16))
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(startX, lineY),
        Offset(thumbX, lineY),
        progressPaint,
      );
    }

    final Paint thumbPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFFFFF),
          _mainColor,
          _endColor.withValues(alpha: 0.72),
        ],
      ).createShader(Rect.fromCircle(center: Offset(thumbX, lineY), radius: 8));

    final Paint thumbInnerPaint = Paint()..color = Colors.white;
    //坐标发光区域
    canvas.drawCircle(Offset(thumbX, lineY), 8, thumbPaint);
    //圆的大小
    canvas.drawCircle(Offset(thumbX, lineY), 3.5, thumbInnerPaint);

    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    void drawText(String text, Offset offset) {
      textPainter.text = TextSpan(
        text: text,
        style: const TextStyle(fontSize: 12, color: Color(0xFFC7CAD3)),
      );
      textPainter.layout();
      textPainter.paint(canvas, offset);
    }

    drawText('level_low'.tr, Offset(startX, 0));
    drawText('level_medium'.tr, Offset(size.width / 2 - 14, 0));
    drawText('level_high'.tr, Offset(endX - 24, 0));

    final RRect bubble = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(thumbX, lineY - 30),
        width: 34,
        height: 22,
      ),
      const Radius.circular(5),
    );

    final Paint bubblePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: gradientColors,
      ).createShader(bubble.outerRect);

    canvas.drawRRect(bubble, bubblePaint);

    textPainter.text = TextSpan(
      text: score.toString(),
      style: const TextStyle(fontSize: 12, color: Colors.white),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(thumbX - textPainter.width / 2, lineY - 38),
    );
  }

  @override
  bool shouldRepaint(covariant _RelaxSliderPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.score != score ||
        oldDelegate.gradientColors != gradientColors;
  }
}

// 仪表盘 Painter
class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.progress,
    required this.score,
    required this.gradientColors,
  });

  final double progress;
  final int score;
  final List<Color> gradientColors;

  @override
  void paint(Canvas canvas, Size size) {
    final double safeProgress = progress.clamp(0, 1);
    final Offset center = Offset(size.width / 2, size.height - 18);
    final double radius = size.width / 2 - 12;
    final Rect arcRect = Rect.fromCircle(center: center, radius: radius);

    final Paint bgPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(arcRect, math.pi, math.pi, false, bgPaint);

    if (safeProgress > 0) {
      final int segmentCount = math.max(1, (120 * safeProgress).ceil());
      final double totalSweepAngle = math.pi * safeProgress;

      for (int i = 0; i < segmentCount; i++) {
        final double startT = i / segmentCount;
        final double endT = (i + 1) / segmentCount;
        final double colorT = (startT + endT) / 2;

        final double segmentStartAngle = math.pi + totalSweepAngle * startT;
        final double segmentSweepAngle = totalSweepAngle / segmentCount + 0.002;

        final Paint segmentPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.butt
          ..color = _getGradientColor(gradientColors, colorT);

        canvas.drawArc(
          arcRect,
          segmentStartAngle,
          segmentSweepAngle,
          false,
          segmentPaint,
        );
      }

      final Offset startPoint = Offset(
        center.dx + math.cos(math.pi) * radius,
        center.dy + math.sin(math.pi) * radius,
      );

      final double endAngle = math.pi + totalSweepAngle;
      final Offset endPoint = Offset(
        center.dx + math.cos(endAngle) * radius,
        center.dy + math.sin(endAngle) * radius,
      );

      canvas.drawCircle(
        startPoint,
        4,
        Paint()..color = _getGradientColor(gradientColors, 0),
      );

      canvas.drawCircle(
        endPoint,
        4,
        Paint()..color = _getGradientColor(gradientColors, 1),
      );
    }

    final double angle = math.pi + math.pi * safeProgress;
    final Offset pointerEnd = Offset(
      center.dx + math.cos(angle) * (radius - 8),
      center.dy + math.sin(angle) * (radius - 8),
    );

    final Color pointerColor = _getGradientColor(gradientColors, safeProgress);

    final Paint pointerPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [pointerColor.withValues(alpha: 0.45), pointerColor],
      ).createShader(Rect.fromPoints(center, pointerEnd))
      ..strokeWidth = 2;

    canvas.drawLine(center, pointerEnd, pointerPaint);

    canvas.drawCircle(
      center,
      5,
      Paint()
        ..shader = RadialGradient(
          colors: [const Color(0xFFFFFFFF), pointerColor],
        ).createShader(Rect.fromCircle(center: center, radius: 5)),
    );

    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    void drawGaugeLabel(String text, double value, Offset offset) {
      final double labelAngle = math.pi + math.pi * value;
      final double labelRadius = radius + 10;

      final Offset labelPoint = Offset(
        center.dx + math.cos(labelAngle) * labelRadius,
        center.dy + math.sin(labelAngle) * labelRadius,
      );

      textPainter.text = TextSpan(
        text: text,
        style: const TextStyle(fontSize: 9, color: Color(0xFF9A9DA8)),
      );
      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(
          labelPoint.dx - textPainter.width / 2 + offset.dx,
          labelPoint.dy - textPainter.height / 2 + offset.dy,
        ),
      );
    }

    drawGaugeLabel('0', 0, const Offset(0, 9));

    // 这里单独调 25 的位置
    drawGaugeLabel('25', 0.25, const Offset(-4, 1));

    drawGaugeLabel('50', 0.5, const Offset(0, -3));
    drawGaugeLabel('75', 0.75, const Offset(4, 1));

    // 这里单独调 100 的位置
    drawGaugeLabel('100', 1, const Offset(0, 9));
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.score != score ||
        oldDelegate.gradientColors != gradientColors;
  }
}

// 确认按钮
Widget _buildButton(SummaryLogic logic) {
  return ElevatedButton(
    onPressed: logic.confirmBackToMain,
    style: ElevatedButton.styleFrom(
      fixedSize: const Size(340, 56),
      backgroundColor: const Color(0xFF1F6FE5),
      foregroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.transparent,
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(29)),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          'confirm'.tr,
          maxLines: 1,
          style: const TextStyle(fontSize: 20, color: Color(0xFFFFFFFF)),
        ),
      ),
    ),
  );
}

///////////////////////////////底部感受评估///////////////////////////////

Widget _buildFeelingBox(SummaryLogic logic, {double height = 134}) {
  return _buildGlassCard(
    width: 711,
    height: height,
    radius: 20,
    // 内边距
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    // 边框颜色
    borderColor: const Color(0xFF30333D),
    // 输入框颜色渐变
    gradientColors: [
      const Color(0xFF1A1D26).withValues(alpha: 0.82),
      const Color(0xFF101218).withValues(alpha: 0.72),
    ],
    // 输入的文字样式
    child: TextField(
      controller: logic.feelingController,
      onChanged: (_) => logic.recordUserAction(),
      maxLines: null,
      cursorColor: Colors.white,
      style: const TextStyle(fontSize: 18, color: Color(0xFFFFFFFF)),
      decoration: InputDecoration(
        isCollapsed: true,
        border: InputBorder.none,
        hintText: 'therapy_feedback_hint'.tr,
        hintMaxLines: 2,
        hintStyle: const TextStyle(fontSize: 16, color: Color(0xFF4c4c4c)),
      ),
    ),
  );
}

// 通用毛玻璃方法
// 通用毛玻璃卡片
Widget _buildGlassCard({
  required Widget child,
  double width = 322,
  double height = 210,
  double radius = 18,
  EdgeInsets padding = const EdgeInsets.all(22),
  Color borderColor = const Color(0xFF3A3D48),
  List<Color>? gradientColors,
}) {
  return ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
      child: Container(
        width: width,
        height: height,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
            color: borderColor.withValues(alpha: 0.75),
            width: 1,
          ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                gradientColors ??
                [
                  const Color(0xFF1B1E28).withValues(alpha: 0.86),
                  const Color(0xFF11131A).withValues(alpha: 0.72),
                ],
          ),
        ),
        child: child,
      ),
    ),
  );
}
