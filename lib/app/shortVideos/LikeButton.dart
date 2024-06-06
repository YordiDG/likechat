
import 'package:flutter/material.dart';


class LikeButton extends StatefulWidget {
  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: _isLiked
          ? Icon(Icons.favorite, color: Colors.red, size: 30.0)
          : Icon(Icons.favorite_border, color: Colors.white, size: 30.0),
      onPressed: _isLiked ? null : _likeVideo,
    );
  }

  void _likeVideo() {
    setState(() {
      _isLiked = true;
    });
  }
}