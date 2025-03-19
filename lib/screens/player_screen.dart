import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:musicplayer/widgets/music_tile.dart';
import 'package:musicplayer/utils/music_provider.dart';

class PlayerScreen extends StatefulWidget {
  const PlayerScreen({super.key});

  @override
  _PlayerScreenState createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('All Tracks')),
      body: Column(
        children: [
          // Afficher la liste des musiques
          Expanded(
            child: ListView.builder(
              itemCount: musicProvider.musicList.length,
              itemBuilder: (context, index) {
                final music = musicProvider.musicList[index];
                return MusicTile(
                  music: music,
                  isPlaying:
                      musicProvider.currentMusic == music &&
                      musicProvider.isPlaying,
                  onTap: () => musicProvider.togglePlayPause(music),
                  currentMusic: musicProvider.currentMusic!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
