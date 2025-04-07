import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:musicplayer/utils/music_provider.dart';
import 'package:musicplayer/services/storage_service.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  List _selectedFolder = [];

  Future<void> _loadMusicFromDevice() async {
    await StorageService.pickMusicFilesFromFolder();
    List folderPaths = await StorageService.getMusicFolderPaths();

    if (folderPaths.isNotEmpty) {
      final musicProvider = Provider.of<MusicProvider>(context, listen: false);
      await musicProvider.loadMusicList();

      setState(() {
        _selectedFolder = folderPaths;
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
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
