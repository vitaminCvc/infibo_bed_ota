// VAT 音乐选择页面数据模型与逻辑。
import 'package:infibo_app/constants/assets.dart';

class Song {
  const Song({
    required this.id,
    required this.name,
    required this.author,
    this.assetPath,
  });

  final String id;
  final String name;
  final dynamic author;
  final String? assetPath;
}

class SongSeries {
  const SongSeries({required this.songs});

  final List<Song> songs;
}

const List<SongSeries> songSeriesList = [
  SongSeries(
    songs: [
      Song(
        id: 'Thy Grace',
        name: '01   Thy Grace',
        author: '          Snatam Kaur',
        assetPath: Assets.music1,
      ),
      Song(
        id: 'Aria 2',
        name: '02   Aria 2',
        author: '          Max Richter',
        assetPath: Assets.music2,
      ),
      Song(
        id: 'Sol_L',
        name: '03   Sol_L',
        author: '          Solar Fields',
        assetPath: Assets.music3,
      ),
      Song(
        id: 'Weightless',
        name:
            '04   Weightless-528Hz DNA Repair, Heal Damage In The Body and Spirit',
        author: '          Marconi Union',
        assetPath: Assets.music4,
      ),
      Song(
        id: 'Poa Alpina_L',
        name: '05   Poa Alpina_L',
        author: '          BIOSPHERE',
        assetPath: Assets.music5,
      ),
      Song(
        id: 'An Ending(Ascent)',
        name: '06   An Ending(Ascent)',
        author: '          Brian Eno',
        assetPath: Assets.music6,
      ),
      Song(
        id: 'Temple of Silence_L',
        name: '07   Temple of Silence_L',
        author: '          Deuter & Annette Cantor',
        assetPath: Assets.music7,
      ),
      Song(
        id: 'Dream Spiral_L',
        name: '08   Dream Spiral_L',
        author: '          Hilary Stagg',
        assetPath: Assets.music8,
      ),
      Song(
        id: 'Flight From The City (Edit)',
        name: '09   Flight From The City (Edit)',
        author: '          Jóhann Jóhannsson',
        assetPath: Assets.music9,
      ),
      Song(
        id: 'Immortal Love',
        name: '10   Immortal Love',
        author: '          Aeoliah',
        assetPath: Assets.music10,
      ),
    ],
  ),
];

List<Song> get allSongs => [
  for (final SongSeries series in songSeriesList) ...series.songs,
];

Song? findSongById(String id) {
  for (final Song song in allSongs) {
    if (song.id == id) return song;
  }
  return null;
}

const String defaultSongId = 'Thy Grace';

class VatMusicSelection {
  const VatMusicSelection({
    required this.songId,
    required this.songName,
    required this.frequency,
    required this.intensity,
  });

  final String songId;
  final String songName;
  final String frequency;
  final String intensity;
}
