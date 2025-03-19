import 'package:flutter/material.dart';
import 'package:musicplayer/models/music.dart';

class MusicTile extends StatelessWidget {
  final Music music;
  final Music currentMusic;
  final VoidCallback onTap;
  final bool isPlaying;

  const MusicTile({
    super.key,
    required this.music,
    required this.onTap,
    required this.isPlaying,
    required this.currentMusic,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white.withAlpha(100),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child:
              music.coverArt != null
                  ? Image.memory(
                    music.coverArt!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                  : const Icon(Icons.music_note, size: 50),
        ),
        title: Text(
          music.title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
        subtitle: Text(
          music.artist != '' ? music.artist : 'Artiste inconnu',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        onTap: onTap,
        trailing: Icon(
          isPlaying && currentMusic == music ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
