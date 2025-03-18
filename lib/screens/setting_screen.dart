import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text('App Settings', style: TextStyle(fontSize: 24)),
            // Ajouter ici les options de paramétrage comme le thème, la langue, etc.
          ],
        ),
      ),
    );
  }
}
