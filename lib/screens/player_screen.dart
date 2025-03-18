import 'package:flutter/material.dart';
import 'package:musicplayer/services/music_player_service.dart';
import 'package:musicplayer/widgets/music_tile.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key, required MusicPlayerService musicPlayerService});

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  final MusicPlayerService musicPlayerService = MusicPlayerService();
  bool _isPlaying = false;
  

  @override
  void initState() {
    super.initState();
    setState(() {}); // Pour forcer le rafraîchissement après le chargement des musiques

    // Vérifie si les musiques sont bien chargées
    Future.delayed(Duration.zero, () {
      debugPrint("Liste de musiques : ${musicPlayerService.musicList}");
    });
  }

  // Fonction pour basculer entre jouer et mettre en pause
  void _togglePlayPause(music) {
    if (_isPlaying) {
      musicPlayerService.togglePlayPause(music);
    } else {
      // Vous pouvez fournir l'objet Music avec la musique à jouer
      musicPlayerService.togglePlayPause(music);
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
                final music = musicPlayerService.musicList[index];
                return MusicTile(music: music, onTap: () => _togglePlayPause(music),);
              },
            ),
          ),
        ],
      ),
    );
  }
}
