import '../models/music.dart';
import '../models/playlist.dart';
import 'package:musicplayer/services/storage_service.dart';

class PlaylistService {
  static Future<void> addMusicToPlaylist(Playlist playlist, Music music) async {
    playlist.addSong(music);
    List<Playlist> playlists = await StorageService.loadPlaylists();
    playlists.add(playlist);
    await StorageService.savePlaylists(playlists);
  }

  static Future<void> removeMusicFromPlaylist(Playlist playlist, Music music) async {
    playlist.removeSong(music);
    List<Playlist> playlists = await StorageService.loadPlaylists();
    playlists.add(playlist);
    await StorageService.savePlaylists(playlists);
  }

  static Future<void> createPlaylist(String name) async {
    Playlist newPlaylist = Playlist(name: name);
    List<Playlist> playlists = await StorageService.loadPlaylists();
    playlists.add(newPlaylist);
    await StorageService.savePlaylists(playlists);
  }

  static Future<void> deletePlaylist(Playlist playlist) async {
    List<Playlist> playlists = await StorageService.loadPlaylists();
    playlists.remove(playlist);
    await StorageService.savePlaylists(playlists);
  }
}
