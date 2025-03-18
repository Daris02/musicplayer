import 'package:flutter/material.dart';

import 'package:musicplayer/utils/size_config.dart';
import 'package:musicplayer/screens/artits_screen.dart';
import 'package:musicplayer/screens/player_screen.dart';
import 'package:musicplayer/screens/setting_screen.dart';
import 'package:musicplayer/widgets/bottom_nav_bar.dart';
import 'package:musicplayer/screens/playlist_screen.dart';
import 'package:musicplayer/services/music_player_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MusicPlayerService musicPlayerService = MusicPlayerService();
  int _selectedIndex = 0;
  late final PageController pageController;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _initializeMusic();
    pageController = PageController(initialPage: _selectedIndex);
    _screens = [
      PlayerScreen(musicPlayerService: musicPlayerService),
      ArtistsScreen(),
      PlaylistScreen(),
      SettingScreen(),
    ];
  }

  Future<void> _initializeMusic() async {
    await musicPlayerService.loadMusicList();
    setState(() {});
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppSizes().initSizes(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Music Player',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.search),
        //     onPressed: () {
        //       // TODO: Implémenter la fonction de recherche
        //     },
        //   ),
        // ],
      ),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned(
              top: 10,
              left: 0,
              right: 0,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  AppSizes.blockSizeHorizontal * 4.5,
                  0,
                  AppSizes.blockSizeHorizontal * 4.5,
                  50,
                ),
                child: Material(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.transparent,
                  elevation: 10,
                  child: Container(
                    width: AppSizes.screenWidth,
                    height: AppSizes.blockSizeHorizontal * 18,
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(Icons.skip_previous),
                                onPressed: () {
                                  setState(() {
                                    musicPlayerService.playPrevious();
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  musicPlayerService.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                ),
                                onPressed:
                                    () => musicPlayerService.togglePlayPause(
                                      musicPlayerService.currentMusic!,
                                    ),
                              ),
                              IconButton(
                                icon: Icon(Icons.skip_next),
                                onPressed: () {
                                  setState(() {
                                    musicPlayerService.playNext();
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Positioned.fill(
              child: PageView(
                controller: pageController,
                children: _screens,
                onPageChanged: (value) {
                  setState(() {
                    _selectedIndex = value;
                  });
                },
              ),
            ),

            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: _buildBottomNavBar(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSizes.blockSizeHorizontal * 4.5,
        0,
        AppSizes.blockSizeHorizontal * 4.5,
        20,
      ),
      child: Material(
        borderRadius: BorderRadius.circular(30),
        color: Colors.transparent,
        elevation: 10,
        child: Container(
          width: AppSizes.screenWidth,
          height: AppSizes.blockSizeHorizontal * 18,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(30),
          ),
          child: Stack(
            children: [
              Positioned(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    BottomNavBar(
                      icon: Icons.library_music,
                      index: 0,
                      currentIndex: _selectedIndex,
                      onPressed: (val) {
                        setState(() {
                          _selectedIndex = val;
                        });
                        pageController.animateToPage(
                          val,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                    BottomNavBar(
                      icon: Icons.person,
                      index: 1,
                      currentIndex: _selectedIndex,
                      onPressed: (val) {
                        setState(() {
                          _selectedIndex = val;
                        });
                        pageController.animateToPage(
                          val,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                    BottomNavBar(
                      icon: Icons.playlist_play,
                      index: 2,
                      currentIndex: _selectedIndex,
                      onPressed: (val) {
                        setState(() {
                          _selectedIndex = val;
                        });
                        pageController.animateToPage(
                          val,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                    BottomNavBar(
                      icon: Icons.menu,
                      index: 3,
                      currentIndex: _selectedIndex,
                      onPressed: (val) {
                        setState(() {
                          _selectedIndex = val;
                        });
                        pageController.animateToPage(
                          val,
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
