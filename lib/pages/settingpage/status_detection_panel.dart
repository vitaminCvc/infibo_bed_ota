import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/api/modbus/hydrogen_runtime_recorder.dart';
import 'package:infibo_app/api/modbus/modbus_rtu_service.dart';
import 'package:infibo_app/api/modbus/status_detection_registers.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/stores/app_header_clock_store.dart';
import 'package:infibo_app/utils/date_time_utils.dart';
import 'settings_panel_style.dart';
import 'hydrogen_runtime_reset_dialog.dart';

/// 进入页面或手动刷新时读取快照，不启动轮询或触发治疗、水质处理。
class StatusDetectionPanel extends StatefulWidget {
  const StatusDetectionPanel({
    super.key,
    this.readRegister,
    this.runtimeService,
  });
  final Future<int> Function(int address)? readRegister;
  final ModbusRtuService? runtimeService;
  @override
  State<StatusDetectionPanel> createState() => _StatusDetectionPanelState();
}

class _StatusDetectionPanelState extends State<StatusDetectionPanel> {
  static const _normal = Color(0xFF50C082);
  static const _warning = Color(0xFFFF9D45);
  static const _error = Color.fromARGB(255, 212, 67, 67);
  static const _labelColor = Color(0xFFB7B7BD);
  static const _parameterColor = Color(0xFFBFBFBF);
  final _values = <int, int?>{};
  bool _reading = false;
  bool _clearing = false;
  bool _confirmingReset = false;
  int _runtimeTapCount = 0;
  Timer? _runtimeTapWindow;
  late final _runtimeRecorder = HydrogenRuntimeRecorder(
    service:
        widget.runtimeService ??
        const ModbusRtuService(
          timeout: Duration(milliseconds: 500),
          commandDelay: Duration.zero,
          maxRetries: 0,
        ),
  );
  DateTime? _checkedAt;

  @override
  void initState() {
    super.initState();
    unawaited(_refresh());
  }

  Future<void> _refresh() async {
    if (_reading || _clearing) return;
    setState(() {
      _reading = true;
      _checkedAt = null;
      _values.clear();
    });
    final read =
        widget.readRegister ??
        widget.runtimeService?.readHoldingRegister ??
        const ModbusRtuService().readHoldingRegister;
    // 串行读取避免同一串口请求重叠。单字段失败后仍继续读取其他字段。
    for (final address in StatusDetectionRegisters.addresses) {
      if (!mounted) return;
      int? value;
      try {
        final raw = await read(address);
        if (raw < 0 ||
            raw > 0xFFFF ||
            (address == StatusDetectionRegisters.vatVolume && raw > 100)) {
          throw StateError('Invalid status register value');
        }
        value = raw;
      } catch (_) {
        value = null;
      }
      if (!mounted) return;
      setState(() => _values[address] = value);
    }
    if (!mounted) return;
    setState(() {
      _reading = false;
      _checkedAt = Get.isRegistered<AppHeaderClockController>()
          ? Get.find<AppHeaderClockController>().currentTime
          : DateTime.now();
    });
  }

  @override
  void dispose() {
    _runtimeTapWindow?.cancel();
    super.dispose();
  }

  void _onRuntimeTap() {
    if (_reading || _clearing || _confirmingReset) return;
    if (_runtimeTapCount == 0) {
      _runtimeTapWindow = Timer(const Duration(seconds: 3), () {
        _runtimeTapCount = 0;
      });
    }
    _runtimeTapCount++;
    if (_runtimeTapCount < 5) return;
    _runtimeTapWindow?.cancel();
    _runtimeTapCount = 0;
    unawaited(_confirmRuntimeReset());
  }

  Future<void> _confirmRuntimeReset() async {
    setState(() => _confirmingReset = true);
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const HydrogenRuntimeResetDialog(),
    );
    if (!mounted) return;
    setState(() => _confirmingReset = false);
    if (confirmed != true) return;
    setState(() => _clearing = true);
    try {
      await _runtimeRecorder.resetCumulativeRuntime();
      if (!mounted) return;
      setState(() => _values[StatusDetectionRegisters.hydrogenRuntime] = 0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('status_hydrogen_reset_success'.tr)),
      );
    } catch (error) {
      debugPrint('hydrogen cumulative runtime reset failed: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('status_hydrogen_reset_failed'.tr)),
      );
    } finally {
      if (mounted) setState(() => _clearing = false);
    }
  }

  String _missing(int address) => !_values.containsKey(address) && _reading
      ? 'status_reading'.tr
      : 'status_unavailable'.tr;

  String _number(int address, {String unit = '', bool tenths = false}) {
    final value = _values[address];
    if (value == null) return _missing(address);
    final number = tenths ? (value / 10).toStringAsFixed(1) : '$value';
    return unit == '%' ? '$number%' : '$number${unit.isEmpty ? '' : ' $unit'}';
  }

  String _enumValue(int address, List<String> keys, {int offset = 0}) {
    final value = _values[address];
    if (value == null) return _missing(address);
    final index = value - offset;
    return index >= 0 && index < keys.length
        ? keys[index].tr
        : 'status_unknown'.trParams({'value': '$value'});
  }

  String _hydrogenRuntime() {
    final minutes = _values[StatusDetectionRegisters.hydrogenRuntime];
    if (minutes == null) {
      return _missing(StatusDetectionRegisters.hydrogenRuntime);
    }
    return '${minutes ~/ 60} h ${minutes % 60} min';
  }

  Widget _stateBadge(int address, String key, {bool compact = false}) {
    final color = switch (_values[address]) {
      1 || 4 => _normal,
      2 => _warning,
      3 => _error,
      _ => Colors.white60,
    };
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 120),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (compact && color == _normal)
            Image.asset(Assets.statusHydrogenDotFigma, width: 6, height: 6)
          else
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
          SizedBox(width: compact ? 6 : 5),
          Flexible(
            child: Text(
              _enumValue(address, const [
                'status_state_idle',
                'status_state_running',
                'status_state_paused',
                'status_state_fault',
                'status_state_complete',
                'status_state_disabled',
              ]),
              key: ValueKey(key),
              maxLines: compact ? 1 : null,
              overflow: compact ? TextOverflow.ellipsis : null,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontFamily: settingsFontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.5,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Keep register values intact while styling their units separately.
  Widget _valueText(
    String value,
    String key, {
    double size = 24,
    Color? color,
    TextAlign align = TextAlign.start,
    bool compact = false,
  }) {
    final parts = RegExp(r'^(\d+(?:\.\d+)?)( ?(?:℃|A|V|%))$').firstMatch(value);
    final runtime = RegExp(r'^(\d+) h (\d+) min$').firstMatch(value);
    final style = TextStyle(
      color: color ?? Colors.white,
      fontFamily: settingsFontFamily,
      fontSize: size,
      fontWeight: FontWeight.w400,
      height: 1.5,
      letterSpacing: 0,
    );
    if (parts == null && runtime == null) {
      return Text(
        value,
        key: ValueKey(key),
        textAlign: align,
        maxLines: compact ? 1 : null,
        overflow: compact ? TextOverflow.ellipsis : null,
        style: style,
      );
    }
    final unitStyle = TextStyle(
      color: _parameterColor,
      fontFamily: settingsFontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w400,
      height: 26 / 16,
      letterSpacing: 0,
      // 微软雅黑 16px 空格宽 5px；Figma 数值与单位的间距为 6px。
      wordSpacing: compact ? 1 : 0,
    );
    return Text.rich(
      TextSpan(
        children: [
          if (runtime != null) ...[
            TextSpan(text: runtime.group(1)),
            TextSpan(text: ' h ', style: unitStyle),
            TextSpan(text: runtime.group(2)),
            TextSpan(text: ' min', style: unitStyle),
          ] else ...[
            TextSpan(text: parts!.group(1)),
            TextSpan(text: parts.group(2), style: unitStyle),
          ],
        ],
      ),
      key: ValueKey(key),
      textAlign: align,
      maxLines: compact ? 1 : null,
      overflow: compact ? TextOverflow.ellipsis : TextOverflow.clip,
      style: style,
    );
  }

  Widget _metric(
    String label,
    String key,
    String value, {
    Color? color,
    bool compact = false,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: _parameterColor,
          fontFamily: settingsFontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
          letterSpacing: 0,
        ),
      ),
      SizedBox(height: compact ? 12 : 16),
      _valueText(value, key, color: color, compact: compact),
    ],
  );

  Widget _pair(Widget left, Widget right) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 280) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [left, const SizedBox(height: 18), right],
        );
      }
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: left),
            VerticalDivider(
              width: 56,
              color: Colors.white.withValues(alpha: 0.07),
            ),
            Expanded(child: right),
          ],
        ),
      );
    },
  );

  Widget _row(String label, String key, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: _parameterColor,
              fontFamily: settingsFontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.5,
              letterSpacing: 0,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: _valueText(value, key, align: TextAlign.end)),
      ],
    ),
  );

  Widget _divider() =>
      Divider(height: 1, color: Colors.white.withValues(alpha: 0.07));

  Widget _card({
    Key? key,
    required String title,
    required String icon,
    required int stateAddress,
    required String stateKey,
    required Widget child,
    double contentGap = 32,
    double horizontalPadding = settingsCardHorizontalPadding,
    double? height,
    bool compactHeader = false,
  }) => Container(
    key: key,
    height: height,
    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Image.asset(icon, width: 43, height: 43),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                maxLines: compactHeader ? 1 : null,
                overflow: compactHeader ? TextOverflow.ellipsis : null,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: settingsFontFamily,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  height: 26 / 20,
                  letterSpacing: 0,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _stateBadge(stateAddress, stateKey, compact: compactHeader),
          ],
        ),
        SizedBox(height: contentGap),
        child,
      ],
    ),
  );

  Widget _waterQuality() {
    final tds = _values[StatusDetectionRegisters.waterTds];
    final abnormal = tds != null && tds >= 10;
    return SizedBox(
      height: _hydrogenRowHeight(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Tooltip(
            message: abnormal
                ? '${'status_tds_rule'.tr}\n${'water_quality_failed_message'.tr}'
                : 'status_tds_rule'.tr,
            child: Text(
              'status_tds_label'.tr,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: _parameterColor,
                fontFamily: settingsFontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.5,
                letterSpacing: 0,
              ),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Flexible(
                flex: tds == null ? 1 : 0,
                child: _valueText(
                  _number(StatusDetectionRegisters.waterTds),
                  'status_tds_value',
                  compact: true,
                ),
              ),
              if (tds != null) ...[
                const SizedBox(width: 8),
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(15, 5, 14, 5),
                    decoration: BoxDecoration(
                      color: abnormal
                          ? _warning.withValues(alpha: 0.12)
                          : const Color(0xFF3B453F),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      (abnormal
                              ? 'status_quality_abnormal'
                              : 'status_level_normal')
                          .tr,
                      key: const ValueKey('status_water_quality'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: abnormal ? _warning : _normal,
                        fontFamily: settingsFontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        height: 20 / 14,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  double _hydrogenRowHeight(BuildContext context) {
    final scaler = MediaQuery.textScalerOf(context);
    return math.max(72.0, scaler.scale(16) * 1.5 + 12 + scaler.scale(24) * 1.5);
  }

  // Figma 8098:7617：参数行 72px，竖线 64px；内宽 363px 时列起点为 0/205。
  Widget _hydrogenPair(Widget left, Widget right) => LayoutBuilder(
    builder: (context, constraints) {
      if (constraints.maxWidth < 280) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [left, const SizedBox(height: 18), right],
        );
      }
      final rowHeight = _hydrogenRowHeight(context);
      return SizedBox(
        height: rowHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 181, child: left),
            SizedBox(
              width: 24,
              height: rowHeight,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  Assets.statusHydrogenVerticalFigma,
                  width: 1,
                  height: 64,
                ),
              ),
            ),
            Expanded(flex: 158, child: right),
          ],
        ),
      );
    },
  );

  Widget _hydrogenCard(int? level) => LayoutBuilder(
    builder: (context, constraints) {
      final scaler = MediaQuery.textScalerOf(context);
      final extraRowHeight = _hydrogenRowHeight(context) - 72;
      final extraHeaderHeight = math.max(
        0.0,
        math.max(scaler.scale(20) * 1.3, scaler.scale(16) * 1.5) - 43,
      );
      return _card(
        key: const ValueKey('status_hydrogen_card'),
        title: 'status_hydrogen_title'.tr,
        icon: Assets.statusHydrogenFigma,
        stateAddress: StatusDetectionRegisters.hydrogenState,
        stateKey: 'status_hydrogen_state',
        horizontalPadding: 24,
        height: constraints.maxWidth >= 328
            ? 307 + 2 * extraRowHeight + extraHeaderHeight
            : null,
        compactHeader: true,
        contentGap: 24,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _hydrogenPair(
              _waterQuality(),
              _metric(
                'status_water_level'.tr,
                'status_water_level',
                _enumValue(StatusDetectionRegisters.waterLevel, const [
                  'status_level_low',
                  'status_level_normal',
                  'status_level_high',
                ], offset: 1),
                color: switch (level) {
                  1 => Color.fromARGB(255, 212, 67, 67), // 缺水：红色
                  2 => const Color(0xFF50C082), // 正常：绿色
                  3 => const Color(0xFF4548FF), // 高水位：蓝色
                  _ => null, // 读取失败或未知：保持默认颜色
                },
                compact: true,
              ),
            ),
            const SizedBox(height: 23),
            Image.asset(
              Assets.statusHydrogenHorizontalFigma,
              height: 1,
              fit: BoxFit.fill,
            ),
            const SizedBox(height: 24),
            _hydrogenPair(
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _onRuntimeTap,
                child: _metric(
                  'status_hydrogen_runtime_label'.tr,
                  'status_hydrogen_runtime',
                  _hydrogenRuntime(),
                  compact: true,
                ),
              ),
              _metric(
                'status_water_temperature'.tr,
                'status_hydrogen_temperature',
                _number(
                  StatusDetectionRegisters.waterTemperature,
                  tenths: true,
                  unit: '℃',
                ),
                compact: true,
              ),
            ),
          ],
        ),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    final level = _values[StatusDetectionRegisters.waterLevel];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('status_detection'.tr, style: settingsPanelTitleStyle),
                  const SizedBox(height: 8),
                  Text(
                    _checkedAt == null
                        ? (_reading
                              ? 'status_reading'.tr
                              : 'status_unavailable'.tr)
                        : 'status_checked_at'.trParams({
                            'time': formatClockTime(_checkedAt!),
                          }),
                    key: const ValueKey('status_detection_checked_at'),
                    style: const TextStyle(
                      color: _labelColor,
                      fontSize: 14,
                      height: 20 / 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              key: const ValueKey('status_detection_refresh'),
              onPressed: _reading || _clearing
                  ? null
                  : () => unawaited(_refresh()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1266FF),
                disabledBackgroundColor: const Color(
                  0xFF1266FF,
                ).withValues(alpha: 0.4),
                foregroundColor: Colors.white,
                disabledForegroundColor: Colors.white70,
                minimumSize: const Size(96, 40),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: const StadiumBorder(),
                shadowColor: const Color(0xFF1266FF).withValues(alpha: 0.45),
                elevation: 6,
                textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontFamily: settingsFontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 20 / 14,
                ),
              ),
              icon: const Icon(Icons.refresh, size: 18),
              label: Text(
                (_reading ? 'status_refreshing' : 'status_refresh').tr,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _card(
                  title: 'status_red_title'.tr,
                  icon: Assets.startRedLightIconOn,
                  stateAddress: StatusDetectionRegisters.redState,
                  stateKey: 'status_red_state',
                  child: _pair(
                    _metric(
                      'status_temperature_660'.tr,
                      'status_red_660',
                      _number(
                        StatusDetectionRegisters.redTemperature660,
                        tenths: true,
                        unit: '℃',
                      ),
                    ),
                    _metric(
                      'status_temperature_850'.tr,
                      'status_red_850',
                      _number(
                        StatusDetectionRegisters.redTemperature850,
                        tenths: true,
                        unit: '℃',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _card(
                  title: 'PEMF',
                  icon: Assets.startPemfIconOn,
                  stateAddress: StatusDetectionRegisters.pemfState,
                  stateKey: 'status_pemf_state',
                  contentGap: 20,
                  child: Column(
                    children: [
                      _row(
                        'status_current'.tr,
                        'status_pemf_current',
                        _number(
                          StatusDetectionRegisters.pemfCurrent,
                          tenths: true,
                          unit: 'A',
                        ),
                      ),
                      _divider(),
                      _row(
                        'status_voltage'.tr,
                        'status_pemf_voltage',
                        _number(
                          StatusDetectionRegisters.pemfVoltage,
                          tenths: true,
                          unit: 'V',
                        ),
                      ),
                      _divider(),
                      _row(
                        'status_coil_temperature'.tr,
                        'status_pemf_coil',
                        _number(
                          StatusDetectionRegisters.pemfCoilTemperature,
                          tenths: true,
                          unit: '℃',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _card(
                  title: 'VAT',
                  icon: Assets.startVatIconOn,
                  stateAddress: StatusDetectionRegisters.vatState,
                  stateKey: 'status_vat_state',
                  child: _pair(
                    _metric(
                      'status_volume'.tr,
                      'status_vat_volume',
                      _number(StatusDetectionRegisters.vatVolume, unit: '%'),
                    ),
                    _metric(
                      'status_amplifier_temperature'.tr,
                      'status_vat_temperature',
                      _number(
                        StatusDetectionRegisters.vatAmplifierTemperature,
                        tenths: true,
                        unit: '℃',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _hydrogenCard(level),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
