// VAT 音乐选择页面。
//
// 提供音乐预览、选择和音量调节，并把确认结果返回给上级页面。
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/index.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/pages/customized/customizedPage/setting_page_helpers.dart';
import 'package:infibo_app/pages/music/logic.dart';
import 'package:infibo_app/pages/music/player.dart';
import 'package:lottie/lottie.dart';

class MusicSelectPage extends StatefulWidget {
  const MusicSelectPage({super.key});

  @override
  State<MusicSelectPage> createState() => _MusicSelectPageState();
}

class _MusicSelectPageState extends State<MusicSelectPage> {
  static const double _designWidth = 800;
  static const double _designHeight = 1160;
  static const double _minPageScale = 0.72;

  late int _currentIndex;
  late final TextEditingController _frequencyController;
  late final TextEditingController _intensityController;
  late final bool _musicOnlyMode;
  late final VatMusicPlaybackSnapshot _entryPlaybackSnapshot;
  bool _confirmed = false;
  double _sliderValue = 50;
  // 是否显示音量小气泡
  bool _showVolumeBubble = false;

  // 显示音量小气泡
  void _showBubble() {
    if (_showVolumeBubble) return;
    setState(() {
      _showVolumeBubble = true;
    });
  }

  // 隐藏音量小气泡
  void _hideBubble() {
    if (!_showVolumeBubble) return;
    setState(() {
      _showVolumeBubble = false;
    });
  }

  @override
  void initState() {
    super.initState();
    final Object? args = Get.arguments;
    _entryPlaybackSnapshot = VatMusicPlayer.instance.captureSnapshot();
    unawaited(VatMusicPlayer.instance.pause());
    _musicOnlyMode = true;
    final String initialSongId =
        (args is Map ? args['currentSelectedSongId'] as String? : null) ??
        defaultSongId;
    final int idx = allSongs.indexWhere((s) => s.id == initialSongId);
    _currentIndex = idx >= 0 ? idx : 0;

    _frequencyController = TextEditingController(
      text: _argumentText(args, 'currentVatFrequency'),
    );
    _intensityController = TextEditingController(
      text: _argumentText(args, 'currentVatStrength'),
    );
    _sliderValue =
        int.tryParse(_argumentText(args, 'currentVatStrength'))?.toDouble() ??
        VatMusicPlayer.instance.volume.toDouble();
    _intensityController.text = _sliderValue.round().toString();
  }

  String _argumentText(Object? args, String key) {
    if (args is! Map) return '';
    final Object? value = args[key];
    if (value == null) return '';
    return value.toString();
  }

  @override
  void dispose() {
    if (!_confirmed) {
      unawaited(
        VatMusicPlayer.instance.restore(
          _entryPlaybackSnapshot,
          shouldPlay: _entryPlaybackSnapshot.wasPlaying,
        ),
      );
    }
    _frequencyController.dispose();
    _intensityController.dispose();
    super.dispose();
  }

  Song get _currentSong => allSongs[_currentIndex];

  @override
  Widget build(BuildContext context) {
    final double scale =
        ((MediaQuery.sizeOf(context).width - 32) / _designWidth)
            .clamp(_minPageScale, 1.0)
            .toDouble();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _cancelSelection();
      },
      child: AppHeaderPage(
        children: [
          Positioned.fill(
            top: 100,
            child: SizedBox(
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
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas() {
    return Stack(
      children: [
        //唱片json
        Positioned(left: 250, top: 100, child: _buildVinylVisual()),
        //返回按钮
        Positioned(
          left: 55,
          top: 28,
          child: ExpandBackButton(onTap: _cancelSelection),
        ),
        //黑色背景
        _buildBlackBack(),
        //歌曲列表
        Positioned(
          left: 60,
          top: 520,
          right: 60,
          bottom: 190,
          child: _buildSongList(),
        ),
        Positioned(
          left: 60,
          right: 60,
          bottom: 66,
          child: _buildBottomControls(),
        ),
        Positioned(left: 150, top: 410, child: _slider()),
      ],
    );
  }

  Widget _slider() {
    return SizedBox(
      width: 478,
      height: 70,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double progress = (_sliderValue.clamp(0, 100)) / 100.0;
          final double waveWidth = constraints.maxWidth;
          final double activeWidth = waveWidth * progress;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            //点击时显示音量
            onTapDown: (details) {
              _showBubble();
              _updateVolumeByDx(details.localPosition.dx, waveWidth);
            },
            //松开时隐藏音量
            onTapUp: (_) {
              _hideBubble();
            },
            //取消点击时隐藏音量
            onTapCancel: () {
              _hideBubble();
            },
            //拖动时更新音量
            onHorizontalDragUpdate: (details) {
              _showBubble();
              _updateVolumeByDx(details.localPosition.dx, waveWidth);
            },
            //拖动结束时，隐藏音量
            onHorizontalDragEnd: (_) {
              _hideBubble();
            },
            //拖动取消时，隐藏音量
            onHorizontalDragCancel: () {
              _hideBubble();
            },

            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomLeft,
              children: [
                // 1. 底层灰色波形，完整显示
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Image.asset(
                    Assets.volumeWave,
                    width: waveWidth,
                    fit: BoxFit.fill,
                  ),
                ),

                // 2. 上层同一张图，染成橙红色，然后只显示左边进度部分
                Positioned(
                  left: 0,
                  bottom: 0,
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      widthFactor: progress,
                      child: ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              Color(0xFFFFD15C), // 左边：黄橙
                              Color(0xFFFF7A1A), // 中间：橙色
                              Color(0xFFFF3B30), // 右边：红橙
                            ],
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.srcIn,
                        child: Image.asset(
                          Assets.volumeWave,
                          width: waveWidth,
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_showVolumeBubble)
                  // 3. 当前百分比小气泡
                  Positioned(
                    left: (activeWidth - 18).clamp(0, waveWidth - 36),
                    bottom: 34,
                    child: Container(
                      width: 36,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF5A2A),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${_sliderValue.round()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _updateVolumeByDx(double dx, double width) {
    final double value = (dx / width * 100).clamp(0, 100);

    setState(() {
      _sliderValue = value;
      _intensityController.text = value.round().toString();
    });

    unawaited(VatMusicPlayer.instance.setVolume(value.round()));
  }

  Widget _buildBlackBack() {
    return Positioned(
      top: 400,
      child: Container(width: _designWidth, height: 200, color: Colors.black),
    );
  }

  Widget _buildVinylVisual() {
    return Positioned(
      left: 228,
      top: 100,
      child: Lottie.asset(Assets.vinylVisual),
    );
  }

  Widget _buildSongList() {
    return Container(
      decoration: BoxDecoration(color: Colors.black),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 0, bottom: 14),
        itemCount: songSeriesList.length,
        itemBuilder: (context, i) => _buildSeriesGroup(songSeriesList[i]),
      ),
    );
  }

  Widget _buildSeriesGroup(SongSeries series) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 6)),
        for (int i = 0; i < series.songs.length; i++)
          _buildSongRow(series.songs[i]),
        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildSongRow(Song song) {
    final int songIndex = allSongs.indexOf(song);
    final bool isSelected = songIndex == _currentIndex;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => _previewSong(songIndex),
      child: Container(
        height: 87,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF323641).withValues(alpha: 0.35)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected ? Colors.blue : const Color(0xFFB9BCC6),
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    song.author.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected ? Colors.blue : const Color(0xFFB9BCC6),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1464DF),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    if (_musicOnlyMode) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [_buildConfirmButton()],
      );
    }

    return Row(
      children: [
        Expanded(child: _buildInputField('frequency'.tr, _frequencyController)),
        const SizedBox(width: 20),
        Expanded(child: _buildInputField('intensity'.tr, _intensityController)),
        const SizedBox(width: 20),
        SizedBox(
          width: 200,
          height: 72,
          child: ElevatedButton(
            onPressed: _confirmSelection,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1464DF),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: Text('confirm_selection'.tr),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: 420,
      height: 56,
      child: ElevatedButton(
        onPressed: _confirmSelection,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1464DF),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        child: Text('confirm_selection'.tr),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller) {
    final bool enabled = !_musicOnlyMode;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFFB9BCC6), fontSize: 14),
        ),
        const SizedBox(height: 6),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: TextField(
            controller: controller,
            enabled: enabled,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            cursorColor: Colors.white70,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            decoration: const InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
            ),
            onChanged: (value) {
              final int? number = int.tryParse(value);
              if (number != null && number > 100) {
                controller
                  ..text = '100'
                  ..selection = TextSelection.collapsed(
                    offset: controller.text.length,
                  );
              }
            },
          ),
        ),
      ],
    );
  }

  void _confirmSelection() {
    final Song song = _currentSong;
    _confirmed = true;
    unawaited(VatMusicPlayer.instance.pause());
    Get.back(
      result: VatMusicSelection(
        songId: song.id,
        songName: song.name,
        frequency: _frequencyController.text.trim(),
        intensity: _sliderValue.round().toString(),
      ),
    );
  }

  void _cancelSelection() {
    Get.back();
  }

  Future<void> _previewSong(int songIndex) async {
    setState(() => _currentIndex = songIndex);
    final bool ok = await VatMusicPlayer.instance.previewSong(
      allSongs[songIndex].id,
      _sliderValue.round(),
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('当前音乐暂无音频资源')));
    }
  }
}
