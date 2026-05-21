// VAT 音乐选择页面数据模型与逻辑。
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
      ),
      Song(
        id: 'healing_hands',
        name: '02 Healing Hands',
        author: 'Liquid Mind',
      ),
    ],
  ),
  SongSeries(
    songs: [
      Song(id: 'spiegel', name: ' Spiegel im Spiegel', author: 'Arvo Pärt'),
      Song(
        id: 'cello_suite',
        name: ' Bach: Cello Suite No. 1 in G Major (Prélude)',
        author: 'Johann Sebastian Bach',
      ),
      Song(id: 'dream_spiral', name: 'Dream Spiral', author: 'Hilary Stagg'),
    ],
  ),
  SongSeries(
    songs: [
      Song(
        id: 'handpan',
        name: '528Hz Handpan Meditation',
        author: 'Warren Shanti',
      ),
      Song(
        id: 'singing_bowls',
        name: 'Tibetan Singing Bowls Breathe',
        author: 'Tibetan Singing Bowls',
      ),
      Song(
        id: 'cell_regeneration',
        name: 'Cell Regeneration Sound Therapy (528Hz)',
        author: 'Yevhenii Khonin',
      ),
    ],
  ),
  SongSeries(
    songs: [
      Song(
        id: 'stay',
        name: 'Stay (Interstellar Soundtrack)',
        author: 'Hans Zimmer',
      ),
      Song(id: 'blade_runner', name: 'Blade Runner Blues', author: 'Vangelis'),
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
