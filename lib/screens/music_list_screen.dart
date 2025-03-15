import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:musicplayer/services/music_storage_service.dart';

class MusicListScreen extends StatefulWidget {
  @override
  _MusicListScreenState createState() => _MusicListScreenState();
}

class _MusicListScreenState extends State<MusicListScreen> {
  List<String> _musicList = [];

  @override
  void initState() {
    super.initState();
    _loadMusicList();
  }

  // Charge la liste des musiques enregistrées au démarrage
  void _loadMusicList() async {
    List<String> savedMusicList = await MusicStorageService.loadMusicList();
    setState(() {
      _musicList = savedMusicList;
    });
  }

  // Sélectionner un dossier et charger les fichiers audio
  Future<void> pickMusicFolder() async {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory != null) {
      _loadMusicFromDirectory(selectedDirectory);
    }
  }

  // Charge les fichiers audio depuis un dossier sélectionné
  void _loadMusicFromDirectory(String directoryPath) async {
    Directory dir = Directory(directoryPath);
    List<FileSystemEntity> files = dir.listSync();

    List<String> musicFiles =
        files
            .where(
              (file) =>
                  file.path.endsWith('.mp3') ||
                  file.path.endsWith('.wav') ||
                  file.path.endsWith('.m4a'),
            )
            .map((file) => file.path)
            .toList();

    // Sauvegarde la liste pour persistance
    await MusicStorageService.saveMusicList(musicFiles);

    setState(() {
      _musicList = musicFiles;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Liste des musiques")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: pickMusicFolder,
            child: Text("Sélectionner un dossier"),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _musicList.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_musicList[index].split('/').last),
                  onTap: () {
                    Navigator.pop(
                      context,
                      _musicList[index],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
