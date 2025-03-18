import 'package:flutter/material.dart';
import 'package:musicplayer/utils/size_config.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({
    super.key,
    required this.icon,
    required this.index,
    required this.currentIndex,
    required this.onPressed,
  });

  final IconData icon;
  final int index;
  final int currentIndex;
  final Function(int) onPressed;

  @override
  Widget build(BuildContext context) {
    AppSizes().initSizes(context);
    return InkWell(
      onTap: () {
        onPressed(index);
      },
      child: Container(
        height: AppSizes.blockSizeHorizontal * 13,
        width: AppSizes.blockSizeHorizontal * 17,
        margin: EdgeInsets.only(top: 10, left: 10),
        decoration: BoxDecoration(color: Colors.transparent),
        child: AnimatedOpacity(
          opacity: (currentIndex == index) ? 1 : 0.5,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeIn,
          child: Icon(
            icon,
            color: Colors.blueAccent,
            size: AppSizes.blockSizeHorizontal * 8,
          ),
        ),
      ),
    );
  }
}
