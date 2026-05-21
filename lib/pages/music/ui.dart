import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:infibo_app/components/index.dart';
import 'package:infibo_app/constants/assets.dart';
import 'package:infibo_app/pages/customized/customizedPage/setting_page_helpers.dart';
import 'package:infibo_app/pages/music/logic.dart';
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

  @override
  void initState() {
    super.initState();
    final Object? args = Get.arguments;
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
  }

  String _argumentText(Object? args, String key) {
    if (args is! Map) return '';
    final Object? value = args[key];
    if (value == null) return '';
    return value.toString();
  }

  @override
  void dispose() {
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

    return AppHeaderPage(
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
    );
  }

  Widget _buildCanvas() {
    return Stack(
      children: [
        Positioned(left: 250, top: 100, child: _buildVinylVisual()),
        Positioned(
          left: 55,
          top: 28,
          child: ExpandBackButton(onTap: () => Get.back()),
        ),
        Positioned(
          left: 60,
          top: 400,
          right: 60,
          bottom: 200,
          child: _buildSongList(),
        ),
        Positioned(
          left: 60,
          right: 60,
          bottom: 100,
          child: _buildBottomControls(),
        ),
      ],
    );
  }

  Widget _buildVinylVisual() {
    return Positioned(
      left: 250,
      top: 100,
      child: Lottie.asset(Assets.vinylVisual),
    );
  }

  Widget _buildSongList() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 50),
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
      onTap: () => setState(() => _currentIndex = songIndex),
      child: Container(
        height: 80,
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF8C45D5).withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(
                  color: const Color(0xFF8C45D5).withValues(alpha: 0.35),
                )
              : null,
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
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFFB9BCC6),
                      fontSize: 17,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    song.author.toString(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.95)
                          : const Color(0xFFB9BCC6).withValues(alpha: 0.75),
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
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
                  color: const Color(0xFF8C45D5).withValues(alpha: 0.3),
                ),
                child: const Icon(
                  Icons.check,
                  color: Color(0xFFB388E8),
                  size: 14,
                ),
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
          width: 130,
          height: 72,
          child: ElevatedButton(
            onPressed: _confirmSelection,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8C45D5),
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
      width: 360,
      height: 56,
      child: ElevatedButton(
        onPressed: _confirmSelection,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8C45D5),
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
    Get.back(
      result: VatMusicSelection(
        songId: song.id,
        songName: song.name,
        frequency: _frequencyController.text.trim(),
        intensity: _intensityController.text.trim(),
      ),
    );
  }
}
