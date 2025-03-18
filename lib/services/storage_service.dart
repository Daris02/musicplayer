import 'dart:convert';
import 'package:musicplayer/models/music.dart';
import 'package:musicplayer/models/playlist.dart';

import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _musicListKey = 'music_list';
  static const String _musicFolderKey = 'music_folder';
  static const String _lastPlayedMusicKey = 'last_played_music';
  static const String _playlistKey = 'playlists';

  static Future<void> saveMusicList(List<Music> musicList, List folderPaths) async {
    final prefs = await SharedPreferences.getInstance();
    final musicJsonList = musicList.map((music) => music.toJson()).toList();
    await prefs.setString(_musicListKey, jsonEncode(musicJsonList));
    await prefs.setString(_musicFolderKey, jsonEncode(folderPaths));
  }

  static Future<List<Music>> loadMusicList() async {
    final prefs = await SharedPreferences.getInstance();
    String? musicListJson = prefs.getString(_musicListKey);
    if (musicListJson != null) {
      List<dynamic> decodedList = jsonDecode(musicListJson);
      return decodedList.map((json) => Music.fromJson(json)).toList();
    }
    return [];
  }

  static Future<List> getMusicFolderPaths() async {
    final prefs = await SharedPreferences.getInstance();
    String? paths = prefs.getString(_musicFolderKey);
    if (paths != null) {
      return jsonDecode(paths);
    }
    return [];
  }

  static Future<void> saveLastPlayedMusic(Music music) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastPlayedMusicKey, music.path);
  }

  static Future<Music?> getLastPlayedMusic() async {
    final prefs = await SharedPreferences.getInstance();
    String? lastMusicPlayedPath = prefs.getString(_lastPlayedMusicKey);
    List<Music>? musicLists = await loadMusicList();

    if (lastMusicPlayedPath != null) {
      try {
        return musicLists.firstWhere(
          (music) => music.path == lastMusicPlayedPath,
        );
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<void> savePlaylists(List<Playlist> playlists) async {
    final prefs = await SharedPreferences.getInstance();
    final playlistJsonList = playlists.map((playlist) => playlist.toJson()).toList();
    await prefs.setString(_playlistKey, jsonEncode(playlistJsonList));
  }

  static Future<List<Playlist>> loadPlaylists() async {
    final prefs = await SharedPreferences.getInstance();
    String? playlistsJson = prefs.getString(_playlistKey);
    if (playlistsJson != null) {
      List<dynamic> decodedList = jsonDecode(playlistsJson);
      return decodedList.map((json) => Playlist.fromJson(json)).toList();
    }
    return [];
  }
}
