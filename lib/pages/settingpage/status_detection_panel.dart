import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/api/modbus/hydrogen_modbus.dart';
import 'package:infibo_app/api/modbus/modbus_rtu_service.dart';

/// 仅在面板挂载时获取一次快照，不启动定时读取或改变全局水质告警。
class StatusDetectionPanel extends StatefulWidget {
  const StatusDetectionPanel({super.key, this.readRegister});
  final Future<int> Function(int address)? readRegister;

  @override
  State<StatusDetectionPanel> createState() => _StatusDetectionPanelState();
}

class _StatusDetectionPanelState extends State<StatusDetectionPanel> {
  int? _tds;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    unawaited(_readWaterQuality());
  }

  Future<void> _readWaterQuality() async {
    try {
      final read =
          widget.readRegister ?? const ModbusRtuService().readHoldingRegister;
      final value = await read(HydrogenModbus.waterQualityTestingAddress);
      if (value < 0 || value > 0xFFFF) {
        throw StateError('Invalid TDS register value');
      }
      if (!mounted) return;
      setState(() {
        _tds = value;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final abnormal = _tds != null && _tds! >= 10;
    final color = _failed
        ? const Color(0xFFFFB4AB)
        : abnormal
        ? const Color(0xFFFF8D2A)
        : const Color(0xFF00C853);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'status_detection'.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 34),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF343844),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.water_drop_outlined,
                      color: Color(0xFF2E84FF),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'status_tds_label'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Semantics(
                  liveRegion: true,
                  child: _loading
                      ? Row(
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF2E84FF),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'status_tds_reading'.tr,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        )
                      : _failed
                      ? Text(
                          'status_tds_unavailable'.tr,
                          style: TextStyle(
                            color: color,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$_tds',
                              key: const ValueKey('status_tds_value'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              (abnormal
                                      ? 'status_water_abnormal'
                                      : 'status_water_normal')
                                  .tr,
                              style: TextStyle(
                                color: color,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (abnormal) ...[
                              const SizedBox(height: 10),
                              Text(
                                'water_quality_failed_message'.tr,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ],
                        ),
                ),
                const SizedBox(height: 24),
                const Divider(color: Color(0xFF555B68), height: 1),
                const SizedBox(height: 16),
                Text(
                  'status_tds_rule'.tr,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'status_detection_hint'.tr,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
