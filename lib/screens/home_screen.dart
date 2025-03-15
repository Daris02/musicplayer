import 'dart:async';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'music_list_screen.dart';
import 'package:musicplayer/services/music_storage_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _currentMusic;
  AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _musicDuration = Duration.zero;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadLastPlayedMusic();
    _setupAudioListeners();
  }

  // Charge la dernière musique jouée depuis la liste sauvegardée
  void _loadLastPlayedMusic() async {
    List<String> musicFiles = await MusicStorageService.loadMusicList();
    if (musicFiles.isNotEmpty) {
      setState(() {
        _currentMusic = musicFiles.first;
      });
    }
  }

  // Configure les listeners pour mettre à jour la barre de progression
  void _setupAudioListeners() {
    _audioPlayer.onPositionChanged.listen((Duration position) {
      setState(() {
        _currentPosition = position;
      });
    });

    _audioPlayer.onDurationChanged.listen((Duration duration) {
      setState(() {
        _musicDuration = duration;
      });
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() {
        _isPlaying = false;
        _currentPosition = Duration.zero;
      });
    });
  }

  // Joue ou met en pause la musique
  void _togglePlayPause() async {
    if (_currentMusic == null) return;

    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(DeviceFileSource(_currentMusic!));
    }

    setState(() {
      _isPlaying = !_isPlaying;
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Music Player")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _currentMusic?.split('/').last ?? "Aucune musique sélectionnée",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),

            // Barre de progression
            Slider(
              min: 0,
              max: _musicDuration.inSeconds.toDouble(),
              value: _currentPosition.inSeconds.toDouble(),
              onChanged: (value) async {
                await _audioPlayer.seek(Duration(seconds: value.toInt()));
              },
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${_formatDuration(_currentPosition)} / ${_formatDuration(_musicDuration)}",
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Bouton Play/Pause
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, size: 50),
              onPressed: _togglePlayPause,
            ),

            SizedBox(height: 20),

            // Bouton pour aller à la liste des musiques
            ElevatedButton(
              onPressed: () async {
                final selectedMusic = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MusicListScreen()),
                );

                if (selectedMusic != null) {
                  setState(() {
                    _currentMusic = selectedMusic;
                    _isPlaying = false;
                  });
                  _audioPlayer.stop(); // Arrête la musique précédente
                }
              },
              child: Text("Voir la liste des musiques"),
            ),
          ],
        ),
      ),
    );
  }

  // Formatte la durée en minutes:secondes
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes);
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }
}
