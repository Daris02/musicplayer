import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'package:musicplayer/models/music.dart';
import 'package:musicplayer/services/music_storage_service.dart';

class MusicProvider with ChangeNotifier {
  List<Music> _musicList = [];
  Music? _currentMusic;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  final AudioPlayer _audioPlayer = AudioPlayer();

  List<Music> get musicList => _musicList;
  Music? get currentMusic => _currentMusic;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;

  MusicProvider() {
    _initializeAudioSession();
  }

  Future<void> _initializeAudioSession() async {
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
    _musicList = await MusicStorageService.loadMusicList();
    if (_musicList.isNotEmpty) {
      _currentMusic = _musicList.first;
    }
    notifyListeners();
  }

  Future<void> togglePlayPause(Music music) async {
    if (_currentMusic == music) {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
    } else {
      await _audioPlayer.stop();
      await _playMusic(music);
    }
    _isPlaying = !_isPlaying;
    notifyListeners();
  }

  Future<void> _playMusic(Music music) async {
    await _audioPlayer.setAudioSource(
      AudioSource.uri(
        Uri.file(music.path),
        tag: MediaItem(id: music.path, title: music.title, artist: music.artist),
      ),
    );
    await _audioPlayer.play();
    _isPlaying = true;
    _currentMusic = music;
    await MusicStorageService.saveLastPlayedMusic(music);
    notifyListeners();
  }

  void playNext() {
    if (_musicList.isEmpty) return;
    int currentIndex = _musicList.indexOf(_currentMusic!);
    int nextIndex = (currentIndex + 1) % _musicList.length;
    _playMusic(_musicList[nextIndex]);
  }

  void playPrevious() {
    if (_musicList.isEmpty) return;
    int currentIndex = _musicList.indexOf(_currentMusic!);
    int prevIndex = (currentIndex - 1) % _musicList.length;
    if (prevIndex < 0) prevIndex = _musicList.length - 1;
    _playMusic(_musicList[prevIndex]);
  }

  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
