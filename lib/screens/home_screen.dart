import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:musicplayer/providers/audio_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final audioProvider = Provider.of<AudioProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Music Player")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.music_note, size: 100, color: Colors.blue),
            const SizedBox(height: 20),
            Text(
              audioProvider.currentSong ?? "Aucune musique sélectionnée",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(audioProvider.isPlaying ? Icons.pause : Icons.play_arrow, size: 40),
                  onPressed: () => audioProvider.togglePlayback(),
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.library_music, size: 40),
                  onPressed: () {
                    Navigator.pushNamed(context, '/music_list');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
