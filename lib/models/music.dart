class Music {
  final String id;
  final String title;
  final String artist;
  final String album;
  final String path;
  final String? artwork;

  Music({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.path,
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
      );
}
