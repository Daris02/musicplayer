import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MusicStorageService {
  static const String _musicListKey = 'music_list';
  static const String _lastPlayedMusicKey = 'last_played_music';

  // Sauvegarder la liste des musiques
  static Future<void> saveMusicList(List<String> musicFiles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_musicListKey, jsonEncode(musicFiles));
  }

  // Charger la liste des musiques
  static Future<List<String>> loadMusicList() async {
    final prefs = await SharedPreferences.getInstance();
    String? musicListJson = prefs.getString(_musicListKey);

    if (musicListJson != null) {
      List<dynamic> decodedList = jsonDecode(musicListJson);
      return decodedList.cast<String>();
    }

    return [];
  }

  // Sauvegarder la dernière musique jouée
  static Future<void> saveLastPlayedMusic(String musicPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastPlayedMusicKey, musicPath);
  }

  // Charger la dernière musique jouée
  static Future<String?> getLastPlayedMusic() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_lastPlayedMusicKey);
  }
}
