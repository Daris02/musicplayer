import 'package:flutter/material.dart';
import 'package:musicplayer/models/playlist.dart';
import 'package:musicplayer/models/music.dart';
import 'package:musicplayer/services/music_storage_service.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final Playlist playlist;

  const PlaylistDetailScreen({Key? key, required this.playlist}) : super(key: key);

  @override
  _PlaylistDetailScreenState createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  void _removeSong(Music song) {
    setState(() {
      widget.playlist.removeSong(song);
      MusicStorageService.savePlaylists([widget.playlist]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.playlist.name)),
      body: ListView.builder(
        itemCount: widget.playlist.songs.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(widget.playlist.songs[index].title),
            subtitle: Text(widget.playlist.songs[index].artist),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _removeSong(widget.playlist.songs[index]),
            ),
          );
        },
      ),
    );
  }
}
