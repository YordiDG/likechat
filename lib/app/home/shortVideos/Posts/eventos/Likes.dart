import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../Globales/estadoDark-White/DarkModeProvider.dart';


class Likes extends StatefulWidget {
  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<Likes> {
  bool isLiked = false;
  int likeCount = 10999;

  void toggleLike() {
    setState(() {
      if (isLiked) {
        likeCount--;
      } else {
        likeCount++;
      }
      isLiked = !isLiked;
    });
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;

    final textColor = isDarkMode ? Colors.white : Colors.black;
    final iconColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: toggleLike,
            child: Icon(
              isLiked ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
              size: 23,
              color: isLiked ? Colors.red : Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatLikeCount(likeCount),
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // Método para formatear el contador de likes
  String formatLikeCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)} Mill.'; // Formato en millones
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)} mil'; // Formato en miles
    } else {
      return count.toString(); // Formato normal
    }
  }
}