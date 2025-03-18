import 'package:flutter/material.dart';
import 'package:musicplayer/services/music_player_service.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final MusicPlayerService musicPlayerService = MusicPlayerService();
  bool _isPlaying = false;
  
  // Fonction pour basculer entre jouer et mettre en pause
  void _togglePlayPause() {
    if (_isPlaying) {
      musicPlayerService.togglePlayPause(musicPlayerService.currentMusic!);
    } else {
      // Vous pouvez fournir l'objet Music avec la musique à jouer
      musicPlayerService.togglePlayPause(musicPlayerService.currentMusic!);
    }
    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  void dispose() {
    musicPlayerService.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Tracks')),
      body: Column(
        children: [
          // Afficher la liste des musiques
          Expanded(
            child: ListView.builder(
              itemCount: musicPlayerService.musicList.length,
              itemBuilder: (context, index) {
                debugPrint(" ---- ---- ---- ----- ----- ---- --- -- Music PLayer Service Load\n ${musicPlayerService.musicList.length}");
                final music = musicPlayerService.musicList[index];
                return ListTile(
                  title: Text(music.title),
                  subtitle: Text(music.artist),
                  onTap: () => _togglePlayPause(),
                  trailing: Icon(
                    musicPlayerService.isPlaying &&
                            musicPlayerService.currentMusic == music
                        ? Icons.pause
                        : Icons.play_arrow,
                  ),
                );
              },
            ),
          ),
          // Contrôles de lecture
          if (musicPlayerService.currentMusic != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.skip_previous),
                    onPressed: () {
                      setState(() {
                        musicPlayerService.playPrevious();
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      musicPlayerService.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                    ),
                    onPressed: () => _togglePlayPause(),
                  ),
                  IconButton(
                    icon: Icon(Icons.skip_next),
                    onPressed: () {
                      setState(() {
                        musicPlayerService.playNext();
                      });
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
