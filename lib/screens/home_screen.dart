import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:musicplayer/models/music.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:musicplayer/services/music_storage_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> _musicList = [];
  List<Music> _musics = [];
  String? _currentMusic;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final PanelController _panelController = PanelController();

  @override
  void initState() {
    super.initState();
    _loadMusicList();
    _restoreLastPlayedMusic();

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

  // Charger la liste des musiques
  void _loadMusicList() async {
    List<String> savedMusicList = await MusicStorageService.loadMusicList();
    setState(() {
      _musicList = savedMusicList;
    });
  }

  // Restaurer la dernière musique jouée
  void _restoreLastPlayedMusic() async {
    String? lastMusic = await MusicStorageService.getLastPlayedMusic();
    if (lastMusic != null) {
      setState(() {
        _currentMusic = lastMusic;
      });
    }
  }

  // Jouer ou mettre en pause la musique
  void _playMusic(String musicPath) async {
    if (_currentMusic == musicPath && _isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      await _audioPlayer.play(DeviceFileSource(musicPath), position: _position);
      await MusicStorageService.saveLastPlayedMusic(musicPath);
      setState(() {
        _currentMusic = musicPath;
        _isPlaying = true;
      });
    }
  }

  // Passer à la musique suivante
  void _playNext() {
    if (_musicList.isEmpty) return;
    int currentIndex = _musicList.indexOf(_currentMusic ?? '');
    int nextIndex = (currentIndex + 1) % _musicList.length;
    _playMusic(_musicList[nextIndex]);
  }

  // Passer à la musique précédente
  void _playPrevious() {
    if (_musicList.isEmpty) return;
    int currentIndex = _musicList.indexOf(_currentMusic ?? '');
    int prevIndex = (currentIndex - 1) % _musicList.length;
    if (prevIndex < 0) prevIndex = _musicList.length - 1;
    _playMusic(_musicList[prevIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: AnimationLimiter(
                  child: ListView.builder(
                    itemCount: _musicList.length,
                    itemBuilder: (context, index) {
                      return AnimationConfiguration.staggeredList(
                        position: index,
                        duration: const Duration(milliseconds: 500),
                        child: SlideAnimation(
                          verticalOffset: 50.0,
                          child: FadeInAnimation(
                            child: ListTile(
                              title: Text(_musicList[index].split('/').last),
                              onTap: () {
                                _playMusic(_musicList[index]);
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),

          // Floating Music Player avec Sliding Panel
          SlidingUpPanel(
            controller: _panelController,
            minHeight: 80,
            maxHeight: MediaQuery.of(context).size.height * 1,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            panel: _buildExpandedPlayer(),
            collapsed: _buildMiniPlayer(),
          ),
        ],
      ),
    );
  }

  // Mini player (barre inférieure)
  Widget _buildMiniPlayer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _currentMusic?.split('/').last ?? "Aucune musique",
            style: TextStyle(color: Colors.white, fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
          IconButton(
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white),
            onPressed: () => _playMusic(_currentMusic!),
          ),
        ],
      ),
    );
  }

  // Grand lecteur musical
  Widget _buildExpandedPlayer() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _currentMusic?.split('/').last ?? "Aucune musique",
          style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),

        // Barre de progression
        Slider(
          value: _position.inSeconds.toDouble(),
          max: _duration.inSeconds.toDouble(),
          onChanged: (value) {
            _audioPlayer.seek(Duration(seconds: value.toInt()));
            setState(() {
              _position = Duration(seconds: value.toInt());
            });
          },
        ),

        // Affichage du temps
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "${_position.inMinutes}:${(_position.inSeconds % 60).toString().padLeft(2, '0')}",
              style: TextStyle(color: Colors.black),
            ),
            Text(
              "${_duration.inMinutes}:${(_duration.inSeconds % 60).toString().padLeft(2, '0')}",
              style: TextStyle(color: Colors.black),
            ),
          ],
        ),

        SizedBox(height: 20),

        // Boutons de contrôle
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.skip_previous, color: Colors.black, size: 40),
              onPressed: _playPrevious,
            ),
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.black, size: 50),
              onPressed: () => _playMusic(_currentMusic!),
            ),
            IconButton(
              icon: Icon(Icons.skip_next, color: Colors.black, size: 40),
              onPressed: _playNext,
            ),
          ],
        ),
      ],
    );
  }
}
