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
  List<Music> _filteredMusicList = []; // Liste filtrée pour l'affichage
  Music? _currentMusic;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final PanelController _panelController = PanelController();
  double _panelPosition = 0.0;
  bool _isSearching = false; // État pour afficher ou masquer la SearchBar
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeMusicData(); // Nouvelle méthode pour gérer l'initialisation

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

    // Écouter les changements dans le champ de recherche
    _searchController.addListener(_filterMusicList);
  }

  // Nouvelle méthode pour initialiser les données de musique
  Future<void> _initializeMusicData() async {
    try {
      await _loadMusicList(); // Charge la liste des musiques
      await _restoreLastPlayedMusic(); // Restaure la dernière musique jouée
      setState(() {
        _filteredMusicList = List.from(_musicList); // Synchronise immédiatement
      });
    } catch (e) {
      print("Erreur lors de l'initialisation des données : $e");
      setState(() {
        _filteredMusicList = []; // Affiche une liste vide en cas d'erreur
      });
    }
  }

  // Filtrer la liste des musiques en fonction du texte saisi
  void _filterMusicList() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredMusicList = List.from(_musicList);
      } else {
        _filteredMusicList = _musicList.where((music) {
          return music.title.toLowerCase().contains(query) ||
              music.artist.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  // Activer/désactiver le mode recherche
  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        _filteredMusicList = List.from(_musicList); // Réinitialiser la liste
      }
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
  Future<void> _restoreLastPlayedMusic() async {
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

  // Add music folder
  void _pickMusicFiles() async {
    List<Music> result = await MusicStorageService.pickMusicFilesFromFolder();
    setState(() {
      _musicList.addAll(result);
      _filteredMusicList = List.from(_musicList); // Synchronise après ajout
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: "Rechercher une chanson ou un artiste...",
            hintStyle: const TextStyle(color: Colors.black54),
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear, color: Colors.black54),
              onPressed: () {
                _searchController.clear();
              },
            ),
          ),
          style: const TextStyle(color: Colors.black, fontSize: 16),
        )
            : const Text(
          'Music Player',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent.withOpacity(0.8),
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
          ),
          if (!_isSearching)
            IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 28),
              onPressed: _pickMusicFiles,
            ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.grey[100],
            child: _filteredMusicList.isEmpty && _musicList.isEmpty
                ? const Center(child: CircularProgressIndicator()) // Indicateur de chargement
                : ListView.builder(
              itemCount: _filteredMusicList.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: MusicTile(
                    music: _filteredMusicList[index],
                    onTap: () => _playMusic(_filteredMusicList[index]),
                  ),
                );
              },
            ),
          ),
          SlidingUpPanel(
            controller: _panelController,
            minHeight: 60,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            panelBuilder: (sc) => _buildExpandedPlayer(),
            collapsed: _buildMiniPlayer(),
            onPanelSlide: (position) => setState(() => _panelPosition = position),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPlayer() {
    return GestureDetector(
      onTap: () => _panelController.open(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Color.fromRGBO(238, 238, 238, 0.9), // Remplacement ici
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              offset: Offset(0, 2),
              blurRadius: 8,
              spreadRadius: 0,
            ),
          ],
        ),
        height: 60 + (80 * _panelPosition),
        child: Row(
          children: [
            const Icon(
              Icons.music_note,
              size: 24,
              color: Colors.black54,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 14 + (10 * _panelPosition),
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                    child: Text(
                      _currentMusic?.title ?? "Aucune musique",
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    _currentMusic?.artist ?? "Artiste inconnu",
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      fontFamily: 'Poppins',
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.black87,
                size: 28,
              ),
              onPressed: _currentMusic != null ? () => _playMusic(_currentMusic!) : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandedPlayer() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: _currentMusic?.coverArt != null
                ? Image.memory(_currentMusic!.coverArt!, height: 200, width: 200, fit: BoxFit.cover)
                : const Icon(Icons.music_note, size: 75),
          ),
          const SizedBox(height: 20),
          Text(
            _currentMusic?.title ?? "Aucune musique",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            _currentMusic?.artist ?? '',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(_formatDuration(_position), style: const TextStyle(fontSize: 12)),
              Expanded(
                child: SliderTheme(
                  data: SliderThemeData(
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _position.inSeconds.toDouble(),
                    max: _duration.inSeconds.toDouble(),
                    activeColor: Colors.blueAccent,
                    inactiveColor: Colors.grey[300],
                    onChanged: (value) {
                      _audioPlayer.seek(Duration(seconds: value.toInt()));
                      setState(() => _position = Duration(seconds: value.toInt()));
                    },
                  ),
                ),
              ),
              Text(_formatDuration(_duration), style: const TextStyle(fontSize: 12)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.skip_previous, size: 36),
                onPressed: _playPrevious,
              ),
              IconButton(
                icon: Icon(_isPlaying ? Icons.pause_circle : Icons.play_circle, size: 48),
                onPressed: _currentMusic != null ? () => _playMusic(_currentMusic!) : null,
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, size: 36),
                onPressed: _playNext,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String minutes = twoDigits(duration.inMinutes);
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$minutes:$seconds";
  }

  @override
  void dispose() {
    _searchController.dispose();
    _audioPlayer.dispose(); // Ajout pour éviter les fuites de mémoire
    super.dispose();
  }
}