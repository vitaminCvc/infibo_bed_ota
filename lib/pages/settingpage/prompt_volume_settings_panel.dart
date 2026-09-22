// 新增组件，可以集中处理滑动条、百分比显示和保存，方便以后调整样式
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:infibo_app/pages/start/audio_prompt_player.dart';

/// 独立的提示音音量面板：拖动时调节，松手后保存。
class PromptVolumeSettingsPanel extends StatefulWidget {
  const PromptVolumeSettingsPanel({super.key, this.player});

  /// 正式页面使用全局提示音播放器；测试可注入独立播放器。
  final AudioPromptPlayer? player;

  @override
  State<PromptVolumeSettingsPanel> createState() =>
      _PromptVolumeSettingsPanelState();
}

class _PromptVolumeSettingsPanelState extends State<PromptVolumeSettingsPanel> {
  late final AudioPromptPlayer _player;
  late int _volume;
  String? _errorKey;

  @override
  void initState() {
    super.initState();
    _player = widget.player ?? AudioPromptPlayer.instance;
    _volume = _player.volume;
  }

  void _onChanged(double value) {
    setState(() {
      _volume = value.round();
      _errorKey = null;
    });
    unawaited(_applyVolume(_volume));
  }

  Future<void> _applyVolume(int value) async {
    try {
      await _player.setVolume(value);
    } catch (e) {
      debugPrint('audio prompt volume update failed: $e');
      if (mounted && _volume == value) {
        setState(() => _errorKey = 'prompt_volume_update_failed');
      }
    }
  }

  Future<void> _saveVolume() async {
    try {
      await _player.saveVolume();
    } catch (e) {
      debugPrint('audio prompt volume save failed: $e');
      if (mounted) {
        setState(() => _errorKey = 'prompt_volume_save_failed');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            'prompt_volume'.tr,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 34),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF343844),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Icon(
                      _volume == 0 ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white,
                      size: 28,
                    ),
                    Text(
                      '$_volume%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Slider(
                  value: _volume.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 100,
                  activeColor: const Color(0xFF2E84FF),
                  inactiveColor: const Color(0xFF626877),
                  semanticFormatterCallback: (value) =>
                      '${'prompt_volume'.tr} ${value.round()}%',
                  onChanged: _onChanged,
                  onChangeEnd: (_) => unawaited(_saveVolume()),
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text('0%', style: TextStyle(color: Colors.white70)),
                    Text('100%', style: TextStyle(color: Colors.white70)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'prompt_volume_hint'.tr,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          if (_errorKey != null) ...<Widget>[
            const SizedBox(height: 16),
            Semantics(
              liveRegion: true,
              child: Text(
                _errorKey!.tr,
                style: const TextStyle(color: Color(0xFFFFB4AB), fontSize: 16),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
