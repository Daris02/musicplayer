import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:musicplayer/models/music.dart';

class MusicStorageService {
  static List<Music> allMusic = [];
  static const String _musicListKey = 'music_list';
  static const String _lastPlayedMusicKey = 'last_played_music';
  static const List<String> _allowedExtensions = ['.mp3', '.wav', '.flac', '.m4a'];

  // Vérifier et demander la permission de stockage adaptée à la version Android
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      int sdkVersion = int.parse(await getSdkVersion());

      if (sdkVersion <= 32) {
        // Android 12 et inférieur : Permission.storage
        if (!(await Permission.storage.request().isGranted)) {
          debugPrint("❌ Permission de stockage refusée (Android 12 ou inférieur)");
          return false;
        }
      } else {
        // Android 13+ : Utiliser READ_MEDIA_AUDIO pour les fichiers audio
        if (!(await Permission.audio.request().isGranted)) {
          debugPrint("❌ Permission d'accès aux fichiers audio refusée (Android 13+)");
          return false;
        }
      }

      // Vérifier si l'utilisateur a bloqué définitivement la permission
      if (await Permission.audio.isPermanentlyDenied || await Permission.storage.isPermanentlyDenied) {
        debugPrint("⚠️ L'utilisateur a définitivement refusé la permission. Ouvrir les paramètres...");
        await openAppSettings();
        return false;
      }
    }
    return true;
  }

  // Obtenir la version SDK de l'appareil Android
  static Future<String> getSdkVersion() async {
    return await Process.run('getprop', ['ro.build.version.sdk']).then((result) {
      return result.stdout.toString().trim();
    });
  }

  // Sélectionner un dossier contenant des musiques
  static Future<List<Music>> pickMusicFilesFromFolder() async {
    bool permissionGranted = await requestStoragePermission();
    if (!permissionGranted) {
      return [];
    }

    // Ouvre le sélecteur de dossier
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) {
      debugPrint("Aucun dossier sélectionné");
      return [];
    }

    // Récupérer les fichiers audio du dossier
    Directory directory = Directory(selectedDirectory);
    List<FileSystemEntity> files = directory.listSync(recursive: true);

    List<Music> newMusicList = [];

    for (var file in files) {
      if (file is File && _allowedExtensions.any(file.path.endsWith)) {
        try {
          final metadata = await MetadataRetriever.fromFile(File(file.path));

          newMusicList.add(Music(
            path: file.path,
            title: metadata.trackName ?? file.uri.pathSegments.last,
            artist: metadata.albumArtistName ?? "Inconnu",
            album: metadata.albumName ?? "Inconnu",
            coverArt: metadata.albumArt,
            id: file.hashCode.toString(),
          ));
        } catch (e) {
          debugPrint("Erreur lors de l’extraction des métadonnées : $e");
        }
      }
    }

    if (newMusicList.isEmpty) {
      debugPrint("⚠️ Aucun fichier audio trouvé dans le dossier sélectionné");
      return [];
    }

    // Mise à jour et sauvegarde de la liste des musiques
    allMusic = newMusicList;
    await saveMusicList(allMusic);

    debugPrint("✅ ${allMusic.length} musiques chargées !");
    return allMusic;
  }

  // Sauvegarder la liste des musiques dans SharedPreferences
  static Future<void> saveMusicList(List<Music> musicList) async {
    final prefs = await SharedPreferences.getInstance();
    final musicJsonList = musicList.map((music) => music.toJson()).toList();
    await prefs.setString(_musicListKey, jsonEncode(musicJsonList));
  }

  // Charger la liste des musiques
  static Future<List<Music>> loadMusicList() async {
    final prefs = await SharedPreferences.getInstance();
    String? musicListJson = prefs.getString(_musicListKey);
    if (musicListJson != null) {
      List<dynamic> decodedList = jsonDecode(musicListJson);
      return decodedList.map((json) => Music.fromJson(json)).toList();
    }
    return [];
  }

  // Sauvegarder la dernière musique jouée
  static Future<void> saveLastPlayedMusic(Music music) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastPlayedMusicKey, music.path);
  }

  // Charger la dernière musique jouée
  static Future<Music?> getLastPlayedMusic() async {
    final prefs = await SharedPreferences.getInstance();
    String? lastMusicPlayedPath = prefs.getString(_lastPlayedMusicKey);
    List<Music>? musicLists = await loadMusicList();

    if (lastMusicPlayedPath != null) {
      try {
        return musicLists.firstWhere((music) => music.path == lastMusicPlayedPath);
      } catch (e) {
        debugPrint(e.toString());
        debugPrint("⚠️ Aucune musique trouvée avec ce chemin");
        return null;
      }
    }
    return null;
  }
}
