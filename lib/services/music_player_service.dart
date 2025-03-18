import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'music_storage_service.dart';
import 'package:musicplayer/models/music.dart';

class MusicPlayerService {
  List<Music> _musicList = [];
  List<Music> _filteredMusicList = [];
  Music? _currentMusic;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  MusicPlayerService() {
    _initializeAudioSession();
  }

  Future<void> _initializeAudioSession() async {
    _audioPlayer.positionStream.listen((pos) {
      _position = pos;
    });

    _audioPlayer.durationStream.listen((dur) {
      _duration = dur ?? Duration.zero;
    });

    _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        playNext();
      }
    });

    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null && index >= 0 && index < _musicList.length) {
        _currentMusic = _musicList[index];
      }
    });
  }

  // Charger la liste des musiques
  Future<void> loadMusicList() async {
    List<Music> savedMusicList = await MusicStorageService.loadMusicList();
    _musicList = savedMusicList;
    _filteredMusicList = List.from(_musicList);
  }

  // Sauvegarder la dernière musique jouée
  Future<void> saveLastPlayedMusic(Music? music) async {
    if (music != null) {
      await MusicStorageService.saveLastPlayedMusic(music);
    }
  }

  // Lire ou mettre en pause la musique
  void togglePlayPause(Music music) async {
    if (_currentMusic == music) {
      if (_isPlaying) {
        await _audioPlayer.pause();
        _isPlaying = false;
      } else {
        await _audioPlayer.play();
        _isPlaying = true;
      }
    } else {
      await _audioPlayer.stop();
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          Uri.file(music.path),
          tag: MediaItem(id: music.path, title: music.title, artist: music.artist),
        ),
      );
      await _audioPlayer.play();
      _isPlaying = true;
      await saveLastPlayedMusic(music);
    }
  }

  // Passer à la musique suivante
  void playNext() {
    if (_musicList.isEmpty) return;
    int currentIndex = _musicList.indexOf(_currentMusic!);
    int nextIndex = (currentIndex + 1) % _musicList.length;
    _playMusic(_musicList[nextIndex]);
  }

  // Passer à la musique précédente
  void playPrevious() {
    if (_musicList.isEmpty) return;
    int currentIndex = _musicList.indexOf(_currentMusic!);
    int prevIndex = (currentIndex - 1) % _musicList.length;
    if (prevIndex < 0) prevIndex = _musicList.length - 1;
    _playMusic(_musicList[prevIndex]);
  }

  // Jouer une musique
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
  }

  // Filtrer la liste de musique par recherche
  void filterMusicList(String query) {
    _filteredMusicList = _musicList.where((music) {
      return music.title.toLowerCase().contains(query.toLowerCase()) ||
          music.artist.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
  
  Future<void> release() async {
    await _audioPlayer.stop();
    _audioPlayer.dispose();
  }

  List<Music> get musicList => _filteredMusicList;
  bool get isPlaying => _isPlaying;
  Music? get currentMusic => _currentMusic;
}
