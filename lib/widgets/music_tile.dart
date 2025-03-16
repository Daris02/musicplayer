import 'package:flutter/material.dart';
import 'package:musicplayer/models/music.dart';

class MusicTile extends StatelessWidget {
  final Music music;
  final VoidCallback onTap;

  const MusicTile({super.key, required this.music, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.music_note, size: 50),
      title: Text(music.title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(music.artist != '' ? music.artist : 'unknown artist'),
      onTap: onTap,
    );
  }
}
