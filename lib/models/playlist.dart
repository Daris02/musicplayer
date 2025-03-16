import 'package:musicplayer/models/music.dart';

class Playlist {
  final String name;
  final List<Music> songs;

  Playlist({required this.name, required this.songs});

  Map<String, dynamic> toJson() => {
        'name': name,
        'songs': songs.map((song) => song.toJson()).toList(),
      };

  factory Playlist.fromJson(Map<String, dynamic> json) => Playlist(
        name: json['name'],
        songs: (json['songs'] as List).map((e) => Music.fromJson(e)).toList(),
      );
}
