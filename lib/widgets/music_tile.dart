import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:musicplayer/models/music.dart';
import 'package:musicplayer/utils/music_provider.dart';

class MusicTile extends StatelessWidget {
  final Music music;

  const MusicTile({
    super.key,
    required this.music,
  });

  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context);
    
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
        onTap: () => {
          musicProvider.togglePlayPause(music),
          debugPrint("⚠️ -- ⚠️ -- ⚠️ --- ⚠️ Play Current Music: ${music.toString()}"),
          debugPrint("⚠️ -- ⚠️ -- ⚠️ --- ⚠️ isPlaying: ${musicProvider.isPlaying()}"),
          debugPrint("⚠️ -- ⚠️ -- ⚠️ --- ⚠️ Music from provider: ${musicProvider.currentMusic}"),
        },
        trailing: Icon(
          musicProvider.isPlaying() && musicProvider.currentMusic == music ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }
}
