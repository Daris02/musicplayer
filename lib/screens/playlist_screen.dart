import 'package:flutter/material.dart';
import 'package:musicplayer/models/playlist.dart';
import 'package:musicplayer/services/music_storage_service.dart';
import 'package:musicplayer/screens/playlist_detail_screen.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({Key? key}) : super(key: key);

  @override
  _PlaylistScreenState createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  List<Playlist> _playlists = [];

  @override
  void initState() {
    super.initState();
    _loadPlaylists();
  }

  // Charger les playlists
  Future<void> _loadPlaylists() async {
    List<Playlist> playlists = await MusicStorageService.loadPlaylists();
    setState(() {
      _playlists = playlists;
    });
  }

  // Ajouter une nouvelle playlist
  void _addPlaylist() async {
    TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Nouvelle Playlist"),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(hintText: "Nom de la playlist"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                setState(() {
                  _playlists.add(Playlist(name: nameController.text));
                });
                MusicStorageService.savePlaylists(_playlists);
                Navigator.pop(context);
              }
            },
            child: const Text("Créer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Playlists"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _addPlaylist,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _playlists.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_playlists[index].name),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PlaylistDetailScreen(playlist: _playlists[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
