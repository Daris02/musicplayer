import 'package:flutter/material.dart';

class ArtistsScreen extends StatelessWidget {
  const ArtistsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Artists')),
      body: Center(
        child: ListView.builder(
          itemCount: 10, // Remplacer par le nombre d'artistes
          itemBuilder: (context, index) {
            return ListTile(
              title: Text('Artist ${index + 1}'),
              onTap: () {
                // TODO: Implémenter l'action à effectuer lorsqu'un artiste est sélectionné
              },
            );
          },
        ),
      ),
    );
  }
}
