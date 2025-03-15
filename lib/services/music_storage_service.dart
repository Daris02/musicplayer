import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class MusicStorageService {
  static const String _musicListKey = 'music_list';

  // Save all audio files (list)
  static Future<void> saveMusicList(List<String> musicFiles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_musicListKey, jsonEncode(musicFiles));
  }

  // Load all audio files (list)
  static Future<List<String>> loadMusicList() async {
    final prefs = await SharedPreferences.getInstance();
    String? musicListJson = prefs.getString(_musicListKey);

    if (musicListJson != null) {
      List<dynamic> decodedList = jsonDecode(musicListJson);
      return decodedList.cast<String>();
    }

    return [];
  }
}
