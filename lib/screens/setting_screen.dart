import 'package:flutter/material.dart';
import 'package:musicplayer/services/music_player_service.dart';
import 'package:musicplayer/services/music_service.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final MusicPlayerService musicPlayerService = MusicPlayerService();
  final MusicService musicService = MusicService();

  List _selectedFolder = [];

  Future<void> _loadMusicFromDevice() async {
    await MusicService.pickMusicFilesFromFolder();
    List folderPath = await musicService.getMusicFolderPaths();
    if (folderPath.isNotEmpty) {
      await musicService.loadMusicFromFolder();
      await musicPlayerService.loadMusicList();
      await musicPlayerService.updatePlaylist();

      debugPrint(
        "Musiques après updatePlaylist : ${musicPlayerService.musicList}",
      );

      setState(() {
        _selectedFolder = folderPath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadMusicFromDevice,
              child: const Text("Importer de la musique"),
            ),
            const SizedBox(height: 20),
            Text(
              "Dossier sélectionné : $_selectedFolder",
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
