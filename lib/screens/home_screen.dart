import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:musicplayer/models/music.dart';
import 'package:musicplayer/services/music_storage_service.dart';
import 'package:musicplayer/widgets/music_tile.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Music> _musicList = [];
  Music? _currentMusic;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final PanelController _panelController = PanelController();
  double _panelPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _loadMusicList().then((_) {
      _restoreLastPlayedMusic();
    });

    _audioPlayer.onPositionChanged.listen((pos) {
      setState(() {
        _position = pos;
      });
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      _playNext();
    });

    _audioPlayer.onDurationChanged.listen((dur) {
      setState(() {
        _duration = dur;
      });
    });
  }

  // Add music folder
  void _pickMusicFiles() async {
    List<Music> result = await MusicStorageService.pickMusicFilesFromFolder();
    setState(() {
      _musicList.addAll(result);
    });
  }

  // Charger la liste des musiques
  Future<void> _loadMusicList() async {
    List<Music> savedMusicList = await MusicStorageService.loadMusicList();
    setState(() {
      _musicList = savedMusicList;
    });
  }

  // Restaurer la dernière musique jouée
  void _restoreLastPlayedMusic() async {
    Music? lastMusic = await MusicStorageService.getLastPlayedMusic();
    if (lastMusic != null) {
      setState(() {
        _currentMusic = lastMusic;
      });
    }
  }

  // Jouer ou mettre en pause la musique
  void _playMusic(Music music) async {
    if (_currentMusic == music) {
      if (_isPlaying) {
        await _audioPlayer.pause();
        setState(() {
          _isPlaying = false;
        });
      } else {
        // Vérifie si l'audio est prêt, sinon le charge et joue depuis le début
        PlayerState state = _audioPlayer.state;
        if (state == PlayerState.completed || state == PlayerState.stopped) {
          await _audioPlayer.play(DeviceFileSource(music.path));
        } else {
          await _audioPlayer.resume();
        }
        setState(() {
          _isPlaying = true;
        });
      }
    } else {
      await _audioPlayer.stop();
      await _audioPlayer.play(DeviceFileSource(music.path));
      await MusicStorageService.saveLastPlayedMusic(music);
      setState(() {
        _currentMusic = music;
        _isPlaying = true;
      });
    }
  }

  // Passer à la musique suivante
  void _playNext() {
    if (_musicList.isEmpty) return;
    int currentIndex = _musicList.indexOf(_currentMusic!);
    int nextIndex = (currentIndex + 1) % _musicList.length;
    _playMusic(_musicList[nextIndex]);
  }

  // Passer à la musique précédente
  void _playPrevious() {
    if (_musicList.isEmpty) return;
    int currentIndex = _musicList.indexOf(_currentMusic!);
    int prevIndex = (currentIndex - 1) % _musicList.length;
    if (prevIndex < 0) prevIndex = _musicList.length - 1;
    _playMusic(_musicList[prevIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Music Player'),
        centerTitle: true,
        actions: [
          IconButton(icon: Icon(Icons.folder_open), onPressed: _pickMusicFiles),
        ],
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: _musicList.length,
            itemBuilder: (context, index) {
              return MusicTile(
                music: _musicList[index],
                onTap: () => _playMusic(_musicList[index]),
              );
            },
          ),

          // Floating Music Player avec Sliding Panel amélioré
          SlidingUpPanel(
            controller: _panelController,
            minHeight: 80,
            maxHeight: MediaQuery.of(context).size.height,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            panelBuilder: (sc) => _buildExpandedPlayer(),
            collapsed: _buildMiniPlayer(),
            onPanelSlide: (position) {
              setState(() {
                _panelPosition = position;
              });
            },
          ),
        ],
      ),
    );
  }

  // Mini Player avec animation fluide du titre
  Widget _buildMiniPlayer() {
    return GestureDetector(
      onTap: () => _panelController.open(), // Ouvrir le lecteur en grand
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.blueAccent,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        height:
            80 + (120 * _panelPosition), // Ajustement de la hauteur dynamique
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AnimatedDefaultTextStyle(
              duration: Duration(milliseconds: 300),
              style: TextStyle(
                color: Colors.white,
                fontSize:
                    16 + (24 * _panelPosition), // Agrandissement progressif
                fontWeight: FontWeight.bold,
              ),
              child: Text(
                _currentMusic?.title ?? "Aucune musique",
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
              ),
              onPressed: () => _playMusic(_currentMusic!),
            ),
          ],
        ),
      ),
    );
  }

  // Lecteur de musique en plein écran avec animation
  Widget _buildExpandedPlayer() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            height: 200,
            width: 200,
            child: _currentMusic?.coverArt != null ?
              Image.memory(_currentMusic?.coverArt ?? Uint8List(0), fit: BoxFit.cover)
              : Icon(Icons.music_note, size: 75)
          ),
          // Animation du titre qui s'agrandit depuis le mini-player
          AnimatedDefaultTextStyle(
            duration: Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 24 + (16 * _panelPosition), // Taille du texte dynamique
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            child: Text(
              _currentMusic?.title ?? "Aucune musique",
              textAlign: TextAlign.center,
            ),
          ),
          // Animation du titre qui s'agrandit depuis le mini-player
          AnimatedDefaultTextStyle(
            duration: Duration(milliseconds: 300),
            style: TextStyle(
              fontSize: 15 + (16 * _panelPosition), // Taille du texte dynamique
              fontWeight: FontWeight.normal,
              color: const Color.fromARGB(135, 0, 0, 0),
            ),
            child: Text(
              _currentMusic?.artist ?? '',
              textAlign: TextAlign.center,
            ),
          ),

          SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                _formatDuration(_position),
                style: TextStyle(fontSize: 14),
              ),
              // Animation du Slider (apparition fluide)
              AnimatedOpacity(
                duration: Duration(milliseconds: 100),
                opacity: _panelPosition,
                child: Slider(
                  value: _position.inSeconds.toDouble(),
                  max: _duration.inSeconds.toDouble(),
                  onChanged: (value) {
                    _audioPlayer.seek(Duration(seconds: value.toInt()));
                    setState(() {
                      _position = Duration(seconds: value.toInt());
                    });
                  },
                ),
              ),
              Text(
                _formatDuration(_duration),
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
          // Boutons de contrôle avec animation
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.skip_previous, color: Colors.black),
                onPressed: _playPrevious,
              ),
              IconButton(
                icon: Icon(
                  _isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.black,
                ),
                onPressed: () => _playMusic(_currentMusic!),
              ),
              IconButton(
                icon: Icon(Icons.skip_next, color: Colors.black),
                onPressed: _playNext,
              ),
            ],
          ).animate().fadeIn(delay: 300.ms).moveY(begin: 20, end: 0),
        ],
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
