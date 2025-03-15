import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class AudioProvider extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();
  String? currentSong;
  bool isPlaying = false;
  List<String> musicFiles = [];

  // Sélectionner un dossier contenant des musiques
  Future<void> pickMusicFolder() async {
    PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) {
      String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
      if (selectedDirectory != null) {
        _loadMusicFromDirectory(selectedDirectory);
      }
    } else {
      debugPrint("Permission refusée pour accéder aux fichiers");
    }
  }

  // Charger tous les fichiers audio du dossier sélectionné
  void _loadMusicFromDirectory(String path) {
    Directory directory = Directory(path);
    List<FileSystemEntity> files = directory.listSync(recursive: true);
    
    musicFiles = files
        .where((file) => file.path.endsWith('.mp3') || file.path.endsWith('.wav') || file.path.endsWith('.flac') || file.path.endsWith('.m4a'))
        .map((file) => file.path)
        .toList();

    notifyListeners();
  }

  // Jouer une musique
  Future<void> playMusic(String path) async {
    await _player.setFilePath(path);
    await _player.play();
    currentSong = path.split('/').last;
    isPlaying = true;
    notifyListeners();
  }

  // Pause / Play
  Future<void> togglePlayback() async {
    if (_player.playing) {
      await _player.pause();
      isPlaying = false;
    } else {
      await _player.play();
      isPlaying = true;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
