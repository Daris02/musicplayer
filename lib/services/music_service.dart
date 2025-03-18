import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';

import 'storage_service.dart';
import 'package:musicplayer/models/music.dart';

class MusicService {
  static const List<String> _allowedExtensions = [
    '.mp3', '.wav', '.flac', '.m4a',
  ];

  static Future<bool> requestStoragePermission() async {
    if (await Permission.storage.request().isGranted) {
      return true;
    }
    return false;
  }

  static Future<List<Music>> pickMusicFilesFromFolder() async {
    bool permissionGranted = await requestStoragePermission();
    if (!permissionGranted) {
      return [];
    }

    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) {
      debugPrint("Aucun dossier sélectionné");
      return [];
    }

    Directory directory = Directory(selectedDirectory);
    if (!directory.existsSync()) {
      debugPrint("⚠️ Le dossier sélectionné n'existe pas ou est inaccessible !");
      return [];
    }

    List folderPaths = await StorageService.getMusicFolderPaths();
    debugPrint("📂 Dossiers enregistrés : $folderPaths");
    if (folderPaths.contains(selectedDirectory)) {
      debugPrint("Le dossier est déjà enregistré");
      return await StorageService.loadMusicList();
    }

    List<FileSystemEntity> files = directory.listSync();
    if (files.isEmpty) {
      debugPrint("⚠️ Aucun fichier audio trouvé dans le dossier sélectionné");
      return [];
    }

    List<Music> newMusicList = [];
    for (var file in files) {
      if (file is File && _allowedExtensions.any(file.path.endsWith)) {
        try {
          final metadata = await MetadataRetriever.fromFile(File(file.path));
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

    folderPaths.add(selectedDirectory);
    List<Music> lastMusicList = await StorageService.loadMusicList();
    List<Music> allMusic = [...lastMusicList, ...newMusicList];
    allMusic = allMusic..sort((a, b) => a.artist.compareTo(b.artist));
    await StorageService.saveMusicList(allMusic, folderPaths);

    return allMusic;
  }
}
