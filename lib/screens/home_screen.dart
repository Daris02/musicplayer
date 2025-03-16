import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:musicplayer/models/music.dart';
import 'package:musicplayer/services/music_storage_service.dart';
import 'package:musicplayer/widgets/music_tile.dart';
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
    // if (savedMusicList.isEmpty) {
    //   _pickMusicFiles();
    // }
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
      await _audioPlayer.resume(); // Reprend depuis la position actuelle
      setState(() {
        _isPlaying = true;
      });
    }
    } else {
      await _audioPlayer.play(
        DeviceFileSource(music.path),
        position: Duration.zero,
      );
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

  // Mini player
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
            _currentMusic?.title ?? "Aucune musique",
            style: TextStyle(color: Colors.white, fontSize: 16),
            overflow: TextOverflow.ellipsis,
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
    );
  }

  // Grand lecteur musical
  Widget _buildExpandedPlayer() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _currentMusic?.title ?? "Aucune musique",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.skip_previous),
              onPressed: _playPrevious,
            ),
            IconButton(
              icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
              onPressed: () => _playMusic(_currentMusic!),
            ),
            IconButton(icon: Icon(Icons.skip_next), onPressed: _playNext),
          ],
        ),
      ],
    );
  }
}
