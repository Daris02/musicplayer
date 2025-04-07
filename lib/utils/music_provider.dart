import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'package:musicplayer/models/music.dart';
import 'package:musicplayer/services/storage_service.dart';

class MusicProvider with ChangeNotifier {
  List<Music> _musicList = [];
  late Music _currentMusic;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  final AudioPlayer _audioPlayer = AudioPlayer();

  List<Music> get musicList => _musicList;
  Music get currentMusic => _currentMusic;
  Duration get position => _position;
  Duration get duration => _duration;

  MusicProvider() {
    _initializeAudioSession();
  }

  Future<void> _initializeAudioSession() async {
    _currentMusic = await StorageService.getLastPlayedMusic();

    _audioPlayer.positionStream.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _audioPlayer.durationStream.listen((dur) {
      _duration = dur ?? Duration.zero;
      notifyListeners();
    });

    _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        playNext();
      }
    });
  }

  Future<void> loadMusicList() async {
    _musicList = await StorageService.loadMusicList();
    if (_musicList.isNotEmpty) {
      _currentMusic = _musicList.first;
    }
    notifyListeners();
  }

  Future<void> togglePlayPause(Music music) async {
    if (_currentMusic == music) {
      if (isPlaying()) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
    } else {
      await _audioPlayer.stop();
      await _playMusic(music);
    }
  }

  bool isPlaying() {
    return _audioPlayer.playing;
  }

  Future<void> _playMusic(Music music) async {
    await StorageService.saveLastPlayedMusic(music);
    _currentMusic = music;
    await _audioPlayer.setAudioSource(
      AudioSource.uri(
        Uri.file(_currentMusic.path),
        tag: MediaItem(id: _currentMusic.path, title: _currentMusic.title, artist: _currentMusic.artist),
      ),
    );
    await _audioPlayer.play();
    notifyListeners();
  }

  void playNext() {
    if (_musicList.isEmpty) return;
    int currentIndex = _musicList.indexOf(_currentMusic);
    int nextIndex = (currentIndex + 1) % _musicList.length;
    _playMusic(_musicList[nextIndex]);
  }

  void playPrevious() {
    if (_musicList.isEmpty) return;
    int currentIndex = _musicList.indexOf(_currentMusic);
    int prevIndex = (currentIndex - 1) % _musicList.length;
    if (prevIndex < 0) prevIndex = _musicList.length - 1;
    _playMusic(_musicList[prevIndex]);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
