import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';

class MusicListScreen extends StatelessWidget {
  const MusicListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Liste des musiques")),
      body: audioProvider.musicFiles.isEmpty
          ? const Center(child: Text("Aucune musique chargée"))
          : ListView.builder(
              itemCount: audioProvider.musicFiles.length,
              itemBuilder: (context, index) {
                final music = audioProvider.musicFiles[index];
                return ListTile(
                  leading: const Icon(Icons.music_note),
                  title: Text(music.split('/').last),
                  onTap: () {
                    audioProvider.playMusic(music);
                    Navigator.pop(context); // Retourner à l'écran d'accueil
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.folder),
        onPressed: () => audioProvider.pickMusicFolder(),
      ),
    );
  }
}
