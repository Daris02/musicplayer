import 'package:flutter/material.dart';

import 'package:musicplayer/screens/playlist_detail_screen.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Playlists')),
      body: Center(
        child: ListView.builder(
          itemCount: 5, // Remplacer par le nombre de playlists
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('Playlist ${index + 1}'),
              onTap: () {
                // TODO: Naviguer vers PlaylistDetailScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PlaylistDetailScreen(),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
