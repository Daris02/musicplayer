import 'package:flutter/material.dart';

class PlaylistDetailScreen extends StatelessWidget {
  const PlaylistDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Playlist Detail')),
      body: Center(
        child: ListView.builder(
          itemCount: 10, // Remplacer par le nombre de musiques dans la playlist
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('Song ${index + 1}'),
              subtitle: Text('Artist ${index + 1}'),
              onTap: () {
                // TODO: Implémenter l'action à effectuer lorsqu'une chanson est sélectionnée
              },
            );
          },
        ),
      ),
    );
  }
}
