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
        id: 'dream1',
        name: '01   Dream 1 (Before the wind blows it all away)',
        author: '          Max Richter',
        assetPath: Assets.music1,
      ),
      Song(
        id: 'healing_hands',
        name: '02   Healing Hands',
        author: '          Liquid Mind',
        assetPath: Assets.music2,
      ),
      Song(
        id: 'spiegel',
        name: '03   Spiegel im Spiegel',
        author: '          Arvo Pärt',
        assetPath: Assets.music3,
      ),
      Song(
        id: 'cello_suite',
        name: '04   Bach: Cello Suite No. 1 in G Major (Prélude)',
        author: '          Johann Sebastian Bach',
        assetPath: Assets.music4,
      ),
      Song(
        id: 'dream_spiral',
        name: '05   Dream Spiral',
        author: '          Hilary Stagg',
        assetPath: Assets.music5,
      ),
      Song(
        id: 'handpan',
        name: '06   528Hz Handpan Meditation',
        author: '          Warren Shanti',
        assetPath: Assets.music6,
      ),
      Song(
        id: 'singing_bowls',
        name: '07   Tibetan Singing Bowls Breathe',
        author: '          Tibetan Singing Bowls',
        assetPath: Assets.music7,
      ),
      Song(
        id: 'cell_regeneration',
        name: '08   Cell Regeneration Sound Therapy (528Hz)',
        author: '          Yevhenii Khonin',
        assetPath: Assets.music8,
      ),
      Song(
        id: 'stay',
        name: '09   Stay (Interstellar Soundtrack)',
        author: '          Hans Zimmer',
        assetPath: Assets.music9,
      ),
      Song(
        id: 'blade_runner',
        name: '10   Blade Runner Blues',
        author: '          Vangelis',
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

const String defaultSongId = 'dream1';

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
