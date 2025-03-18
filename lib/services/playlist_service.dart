import 'package:flutter/material.dart';
import '../models/music.dart';
import '../models/playlist.dart';

class PlaylistService {
  static final List<Music> _playlist = [];

  static List<Music> getPlaylist() => _playlist;

  static void addToPlaylist(Music song) {
    if (!_playlist.contains(song)) {
      _playlist.add(song);
    }
  }

  static void removeFromPlaylist(Music song) {
    _playlist.remove(song);
  }

  static void clearPlaylist() {
    _playlist.clear();
  }
}
