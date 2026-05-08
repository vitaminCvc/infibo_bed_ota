// 太赫兹设置页。
//
// 这一页负责编辑太赫兹模块的频率、功率、模式和波形。
// 页面打开时从 TerahertzSettingController 恢复上次确认过的值；
// 点击确认后保存当前值并返回自定义方案页。
import 'package:flutter/material.dart';
import 'package:infibo_app/components/index.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/pages/customized/customizedPage/setting_page_helpers.dart';
import 'package:infibo_app/pages/customized/customizedPage/taihezi/logic.dart';

class TerahertzExpandPage extends StatefulWidget {
  const TerahertzExpandPage({super.key});

  @override
  State<TerahertzExpandPage> createState() => _TerahertzExpandPageState();
}

class _TerahertzExpandPageState extends State<TerahertzExpandPage> {
  static const double _designWidth = 800;
  static const double _designHeight = 1088;

  double _frequency = 0;
  double _power = 0;
  String? _mode;
  String? _wave;
  late final TerahertzSettingController _controller;

  bool get _canConfirm => _mode != null && _wave != null;

  @override
  void initState() {
    super.initState();
    _controller = TerahertzSettingController.instance;
    final TerahertzSettingSnapshot snapshot = _controller.snapshot();
    _frequency = snapshot.frequency;
    _power = snapshot.power;
    _mode = snapshot.mode;
    _wave = snapshot.wave;
  }

  @override
  Widget build(BuildContext context) {
    final double scale = (MediaQuery.sizeOf(context).width / _designWidth)
        .clamp(0.72, 1.0)
        .toDouble();

    return AppHeaderPage(
      resizeToAvoidBottomInset: false,
      children: [
        Positioned.fill(
          top: 70,
          child: Center(
            child: SizedBox(
              width: _designWidth * scale,
              height: _designHeight * scale,
              child: OverflowBox(
                alignment: Alignment.topCenter,
                minWidth: _designWidth,
                maxWidth: _designWidth,
                minHeight: _designHeight,
                maxHeight: _designHeight,
                child: Transform.scale(
                  scale: scale,
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: _designWidth,
                    height: _designHeight,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 44,
                          top: 5,
                          child: ExpandBackButton(
                            onTap: () => popExpandPage(context),
                          ),
                        ),
                        const Positioned(
                          left: 0,
                          right: 0,
                          top: 16,
                          child: Text(
                            '太赫兹设置',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 284,
                          top: 215,
                          child: Image.asset(
                            Assets.terahertzBody,
                            width: 233,
                            height: 238,
                          ),
                        ),
                        Positioned(
                          left: 95,
                          top: 620,
                          child: _buildSliderRows(),
                        ),
                        Positioned(left: 95, top: 850, child: _buildRadios()),
                        Positioned(
                          left: 95,
                          top: 1005,
                          child: AssetConfirmButton(
                            enabled: _canConfirm,
                            enabledAsset: Assets.terahertzConfirmEnabled,
                            disabledAsset: Assets.terahertzConfirmDisabled,
                            width: 609,
                            onTap: () => _confirm(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        ExpandBackHitLayer(
          designWidth: _designWidth,
          designHeight: _designHeight,
          scale: scale,
          onTap: () => popExpandPage(context),
        ),
      ],
    );
  }

  Widget _buildSliderRows() {
    return Column(
      children: [
        _DraggableProgressRow(
          label: '频率',
          value: _frequency,
          max: 100,
          activeBar: Assets.terahertzFrequencyBar,
          activeThumb: Assets.terahertzFrequencyThumb,
          valueBuilder: (value) => _formatPlainValue(value),
          onChanged: (value) => setState(() => _frequency = value),
        ),
        const SizedBox(height: 55),
        _DraggableProgressRow(
          label: '功率',
          value: _power,
          max: 100,
          activeBar: Assets.terahertzPowerBar,
          activeThumb: Assets.terahertzPowerThumb,
          valueBuilder: (value) => '${_formatPlainValue(value)}%',
          onChanged: (value) => setState(() => _power = value),
        ),
      ],
    );
  }

  Widget _buildRadios() {
    return SizedBox(
      width: 609,
      child: Row(
        children: [
          const Text('模式', style: _labelStyle),
          const SizedBox(width: 26),
          _OptionDot(
            label: '连续',
            selected: _mode == 'continuous',
            onTap: () => _selectMode('continuous'),
          ),
          const SizedBox(width: 22),
          _OptionDot(
            label: '脉冲',
            selected: _mode == 'pulse',
            onTap: () => _selectMode('pulse'),
          ),
          const SizedBox(width: 78),
          const Text('波形', style: _labelStyle),
          const SizedBox(width: 26),
          _OptionDot(
            label: '正弦波',
            selected: _wave == 'sine',
            onTap: () => _selectWave('sine'),
          ),
          const SizedBox(width: 22),
          _OptionDot(
            label: '方波',
            selected: _wave == 'square',
            onTap: () => _selectWave('square'),
          ),
          const SizedBox(width: 22),
          _OptionDot(
            label: '三角波',
            selected: _wave == 'triangle',
            onTap: () => _selectWave('triangle'),
          ),
        ],
      ),
    );
  }

  String _formatPlainValue(double value) {
    final int rounded = value.round().clamp(0, 100);
    if (rounded == 100) return '100';
    return rounded.toString().padLeft(2, '0');
  }

  void _selectMode(String value) => setState(() => _mode = value);

  void _selectWave(String value) => setState(() => _wave = value);

  void _confirm(BuildContext pageContext) {
    // 只有确认时才保存到 controller；直接返回不会覆盖上次确认过的设置。
    _controller.save(
      frequency: _frequency,
      power: _power,
      mode: _mode,
      wave: _wave,
    );
    popExpandPage(pageContext, true);
  }
}

class _DraggableProgressRow extends StatelessWidget {
  const _DraggableProgressRow({
    required this.label,
    required this.value,
    required this.max,
    required this.activeBar,
    required this.activeThumb,
    required this.valueBuilder,
    required this.onChanged,
  });

  static const double _width = 609;
  static const double _trackWidth = 608;
  static const double _trackHeight = 10;
  static const double _thumbSize = 22;
  static const double _trackTop = 38;

  final String label;
  final double value;
  final double max;
  final String activeBar;
  final String activeThumb;
  final String Function(double value) valueBuilder;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final double progress = (value / max).clamp(0.0, 1.0).toDouble();
    final bool active = progress > 0;
    final double thumbLeft = (progress * _trackWidth - _thumbSize / 2).clamp(
      0.0,
      _trackWidth - _thumbSize,
    );

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (details) => _changeByLocalDx(details.localPosition.dx),
      onHorizontalDragStart: (details) =>
          _changeByLocalDx(details.localPosition.dx),
      onHorizontalDragUpdate: (details) =>
          _changeByLocalDx(details.localPosition.dx),
      child: SizedBox(
        width: _width,
        height: 56,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(left: 0, top: 0, child: Text(label, style: _labelStyle)),
            Positioned(
              right: 0,
              top: -2,
              child: Text(valueBuilder(value), style: _valueStyle),
            ),
            Positioned(
              left: 0,
              top: _trackTop,
              child: Image.asset(
                Assets.terahertzProgressDefaultBar,
                width: _trackWidth,
                height: _trackHeight,
                fit: BoxFit.fill,
              ),
            ),
            if (active)
              Positioned(
                left: 0,
                top: _trackTop,
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Image.asset(
                      activeBar,
                      width: _trackWidth,
                      height: _trackHeight,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            Positioned(
              left: thumbLeft,
              top: _trackTop - 6,
              child: Image.asset(
                active ? activeThumb : Assets.terahertzProgressDefaultThumb,
                width: _thumbSize,
                height: _thumbSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _changeByLocalDx(double dx) {
    final double progress = (dx / _trackWidth).clamp(0.0, 1.0).toDouble();
    onChanged(progress * max);
  }
}

class _OptionDot extends StatelessWidget {
  const _OptionDot({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Row(
        children: [
          Image.asset(
            selected
                ? Assets.terahertzRadioSelected
                : Assets.terahertzRadioDefault,
            width: 16,
            height: 16,
          ),
          const SizedBox(width: 7),
          Text(label, style: _optionStyle),
        ],
      ),
    );
  }
}

const TextStyle _labelStyle = TextStyle(
  color: Colors.white,
  fontSize: 18,
  fontWeight: FontWeight.w400,
);

const TextStyle _valueStyle = TextStyle(
  color: Colors.white,
  fontSize: 22,
  fontWeight: FontWeight.w400,
);

const TextStyle _optionStyle = TextStyle(
  color: Color(0xFFC4C7D0),
  fontSize: 16,
  fontWeight: FontWeight.w400,
);
