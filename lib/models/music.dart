import 'dart:typed_data';

class Music {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String path;
  final String? artwork;
  final Uint8List? coverArt;

  Music({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.path,
    required this.coverArt,
    this.artwork,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'album': album,
        'path': path,
        'artwork': artwork,
      };

  factory Music.fromJson(Map<String, dynamic> json) => Music(
        id: json['id'],
        title: json['title'],
        artist: json['artist'],
        album: json['album'],
        path: json['path'],
        artwork: json['artwork'],
        coverArt: json['coverArt'],
      );

  @override
  String toString() {
    return 'Music{id: $id, title: $title, artist: $artist, album: $album, path: $path, artwork: $artwork, coverArt: $coverArt}';
  }
}
