import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'music_storage_service.dart';
import 'package:musicplayer/models/music.dart';

class MusicPlayerService {
  static List<Music> musicList = [];
  static List<Music> filteredMusicList = [];
  static Music? currentMusic;
  static bool isPlaying = false;
  static Duration position = Duration.zero;
  static Duration duration = Duration.zero;
  static final AudioPlayer audioPlayer = AudioPlayer();

  bool isSearching = false;
  final TextEditingController searchController = TextEditingController();

  static Future<void> initializeAudioSession() async {
    try {
      await loadMusicList();
      await updatePlaylist();
      audioPlayer.positionStream.listen((pos) {
        position = pos;
      });

      audioPlayer.durationStream.listen((dur) {
        duration = dur ?? Duration.zero;
      });

      audioPlayer.processingStateStream.listen((state) {
        if (state == ProcessingState.completed) {
          playNext();
        }
      });

      audioPlayer.currentIndexStream.listen((index) {
        if (index != null && index >= 0 && index < musicList.length) {
          currentMusic = musicList[index];
        }
      });
    } catch (e) {
      debugPrint("Erreur lors de l'initialisation des données : $e");
    }
  }

  // Charger la liste des musiques
  static Future<List<Music>> loadMusicList() async {
    List<Music> savedMusicList = await MusicStorageService.loadMusicList();
    musicList = savedMusicList;
    if (musicList.isNotEmpty) {
      currentMusic = musicList[0];
    }
    musicList = List.from(musicList);
    // filteredMusicList = List.from(musicList);
    return musicList;
  }

  // Sauvegarder la dernière musique jouée
  static void saveLastPlayedMusic(Music? music) async {
    if (music != null) {
      await MusicStorageService.saveLastPlayedMusic(music);
    }
  }

  static Future<void> updatePlaylist() async {
    List<Music> savedMusicList = await MusicStorageService.loadMusicList();
    musicList = savedMusicList;
    if (musicList.isNotEmpty) {
      currentMusic = musicList.first;
    }
  }

  // Lire ou mettre en pause la musique
  static Future<void> togglePlayPause(Music music) async {
    if (currentMusic == music) {
      if (isPlaying) {
        await audioPlayer.pause();
      } else {
        await audioPlayer.play();
      }
    } else {
      await audioPlayer.stop();
      playMusic(music);
    }
  }

  // Passer à la musique suivante
  static void playNext() {
    if (musicList.isEmpty) return;
    int currentIndex = musicList.indexOf(currentMusic!);
    int nextIndex = (currentIndex + 1) % musicList.length;
    playMusic(musicList[nextIndex]);
  }

  // Passer à la musique précédente
  static void playPrevious() {
    if (musicList.isEmpty) return;
    int currentIndex = musicList.indexOf(currentMusic!);
    int prevIndex = (currentIndex - 1) % musicList.length;
    if (prevIndex < 0) prevIndex = musicList.length - 1;
    playMusic(musicList[prevIndex]);
  }

  // Jouer une musique
  static Future<void> playMusic(Music music) async {
    await audioPlayer.setAudioSource(
      AudioSource.uri(
        Uri.file(music.path),
        tag: MediaItem(
          id: music.path,
          title: music.title,
          artist: music.artist,
        ),
      ),
    );
    await audioPlayer.play();
    isPlaying = true;
    currentMusic = music;
    saveLastPlayedMusic(music);
  }

  // Filtrer la liste de musique par recherche
  static void filterMusicList(String query) {
    filteredMusicList =
        musicList.where((music) {
          return music.title.toLowerCase().contains(query.toLowerCase()) ||
              music.artist.toLowerCase().contains(query.toLowerCase());
        }).toList();
  }

  static Future<void> release() async {
    await audioPlayer.stop();
    audioPlayer.dispose();
  }
}
