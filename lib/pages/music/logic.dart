// VAT 音乐选择页面数据模型与逻辑。
class Song {
  const Song({
    required this.id,
    required this.name,
    required this.seriesName,
    this.assetPath,
  });

  final String id;
  final String name;
  final String seriesName;
  final String? assetPath;
}

class SongSeries {
  const SongSeries({required this.name, required this.songs});

  final String name;
  final List<Song> songs;
}

const List<SongSeries> songSeriesList = [
  SongSeries(
    name: '深度漂浮系列',
    songs: [
      Song(
        id: 'dream1',
        name: 'Max Richter - Dream 1 (Before the wind blows it all away)',
        seriesName: '深度漂浮系列',
      ),
      Song(
        id: 'healing_hands',
        name: 'Liquid Mind - Healing Hands',
        seriesName: '深度漂浮系列',
      ),
    ],
  ),
  SongSeries(
    name: '神经重塑系列',
    songs: [
      Song(
        id: 'spiegel',
        name: 'Arvo Pärt - Spiegel im Spiegel',
        seriesName: '神经重塑系列',
      ),
      Song(
        id: 'cello_suite',
        name: 'Yo-Yo Ma - Bach: Cello Suite No. 1 in G Major (Prélude)',
        seriesName: '神经重塑系列',
      ),
      Song(
        id: 'dream_spiral',
        name: 'Hilary Stagg - Dream Spiral',
        seriesName: '神经重塑系列',
      ),
    ],
  ),
  SongSeries(
    name: '身心重置系列',
    songs: [
      Song(
        id: 'handpan',
        name: 'Warren Shanti - 528Hz Handpan Meditation',
        seriesName: '身心重置系列',
      ),
      Song(
        id: 'singing_bowls',
        name: '33bowls - Tibetan Singing Bowls Breathe',
        seriesName: '身心重置系列',
      ),
      Song(
        id: 'cell_regeneration',
        name: 'Yevhenii Khonin - Cell Regeneration Sound Therapy (528Hz)',
        seriesName: '身心重置系列',
      ),
    ],
  ),
  SongSeries(
    name: '时空隧道系列',
    songs: [
      Song(
        id: 'stay',
        name: 'Hans Zimmer - Stay (Interstellar Soundtrack)',
        seriesName: '时空隧道系列',
      ),
      Song(
        id: 'blade_runner',
        name: 'Vangelis - Blade Runner Blues',
        seriesName: '时空隧道系列',
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
    required this.seriesName,
    required this.frequency,
    required this.intensity,
  });

  final String songId;
  final String songName;
  final String seriesName;
  final String frequency;
  final String intensity;
}
