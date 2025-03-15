import 'package:flutter/material.dart';

class FloatingPlayer extends StatelessWidget {
  final String? currentMusic;
  final bool isPlaying;
  final Duration currentPosition;
  final Duration musicDuration;
  final VoidCallback onTogglePlayPause;

  FloatingPlayer({
    required this.currentMusic,
    required this.isPlaying,
    required this.currentPosition,
    required this.musicDuration,
    required this.onTogglePlayPause,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      alignment: Alignment.bottomCenter,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(20),
        color: Colors.black.withOpacity(0.8),
        child: Container(
          height: 70,
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  currentMusic?.split('/').last ?? "Aucune musique",
                  style: TextStyle(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause_circle_filled : Icons.play_circle_fill,
                  color: Colors.white,
                  size: 40,
                ),
                onPressed: onTogglePlayPause,
              ),
              SizedBox(width: 10),
              Text(
                "${_formatDuration(currentPosition)} / ${_formatDuration(musicDuration)}",
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    return "${twoDigits(duration.inMinutes)}:${twoDigits(duration.inSeconds.remainder(60))}";
  }
}
