import 'dart:io';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:path_provider/path_provider.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:musicplayer/models/music.dart';

class MusicStorageService {
  static const String _musicListKey = 'music_list';
  static const String _lastPlayedMusicKey = 'last_played_music';
  static const List<String> _allowedExtensions = [
    '.mp3',
    '.wav',
    '.flac',
    '.m4a',
  ];

  // Vérifier et demander la permission de stockage adaptée à la version Android
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      int sdkVersion = int.parse(await getSdkVersion());

      if (sdkVersion <= 32) {
        if (!(await Permission.storage.request().isGranted)) {
          debugPrint("❌ Permission de stockage refusée");
          return false;
        }
      }

      if (sdkVersion >= 30) {
        var status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          debugPrint("❌ Permission d'accès complet au stockage refusée");
          return false;
        }
      }

      if (await Permission.manageExternalStorage.isPermanentlyDenied ||
          await Permission.storage.isPermanentlyDenied) {
        debugPrint(
          "⚠️ L'utilisateur a bloqué les permissions. Ouvrir les paramètres...",
        );
        await openAppSettings();
        return false;
      }
    }
    return true;
  }

  // Obtenir la version SDK de l'appareil Android
  static Future<String> getSdkVersion() async {
    return await Process.run('getprop', ['ro.build.version.sdk']).then((
      result,
    ) {
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
    selectedDirectory = await getAbsolutePath(selectedDirectory ?? "");

    debugPrint("Selected Directory (raw): $selectedDirectory");

    if (selectedDirectory == null) {
      debugPrint("Aucun dossier sélectionné");
      return [];
    }

    // Récupérer les fichiers audio du dossier
    Directory directory = Directory(selectedDirectory);
    if (!directory.existsSync()) {
      debugPrint(
        "⚠️ Le dossier sélectionné n'existe pas ou est inaccessible !",
      );
      return [];
    }
    List<FileSystemEntity> files = directory.listSync(recursive: false);

    if (files.isEmpty) {
      debugPrint("���️ Aucun fichier audio trouvé dans le dossier sélectionné");
      return [];
    }

    List<Music> newMusicList = [];

    for (var file in files) {
      if (file is File && _allowedExtensions.any(file.path.endsWith)) {
        try {
          final metadata = await MetadataRetriever.fromFile(File(file.path));

          debugPrint("Metadata Retriever: $metadata");

          newMusicList.add(
            Music(
              path: file.path,
              title: metadata.trackName ?? file.uri.pathSegments.last,
              artist: metadata.albumArtistName ?? "Inconnu",
              album: metadata.albumName ?? "Inconnu",
              coverArt: metadata.albumArt,
              id: file.hashCode.toString(),
            ),
          );
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
    List<Music> lastMusicList = await loadMusicList();
    List<Music> allMusic = [...lastMusicList, ...newMusicList];
    allMusic = allMusic..sort((a, b) => a.artist.compareTo(b.artist));
    await saveMusicList(allMusic);

    debugPrint("✅ ${allMusic.length} musiques chargées !");
    return allMusic;
  }

  static Future<String?> getAbsolutePath(String uri) async {
    if (uri.startsWith("content://")) {
      try {
        Directory? directory = await getExternalStorageDirectory();
        if (directory != null) {
          String possiblePath = directory.path + uri.split("primary:")[1];
          return possiblePath;
        }
      } catch (e) {
        debugPrint("❌ Erreur de conversion de l'URI : $e");
      }
    }
    return uri; // Retourne le chemin original si ce n'est pas une URI
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
        return musicLists.firstWhere(
          (music) => music.path == lastMusicPlayedPath,
        );
      } catch (e) {
        debugPrint(e.toString());
        debugPrint("⚠️ Aucune musique trouvée avec ce chemin");
        return null;
      }
    }
    return null;
  }
}
