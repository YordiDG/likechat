import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LikeButton extends StatefulWidget {
  final String iconPath;
  final bool isFilled;
  final Function(bool, int) onLiked; // Callback para enviar el estado y el número de likes al padre
  final Decoration? decoration; // Decoración opcional para el contenedor del botón

  LikeButton({
    required this.iconPath,
    required this.isFilled,
    required this.onLiked,
    this.decoration, required int iconSize,
  });

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton> {
  bool _isLiked = false;
  int _likes = 0;

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _likes++;
      } else {
        _likes--;
      }
    });
    widget.onLiked(_isLiked, _likes); // Envia el estado actualizado al padre
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: widget.decoration, // Aplica la decoración al contenedor del botón
      child: Column(
        children: [
          IconButton(
            icon: SvgPicture.asset(
              widget.iconPath,
              color: _isLiked ? Colors.red : (widget.isFilled ? Colors.white : null),
              width: 45.0,
              height: 45.0,
            ),
            onPressed: _toggleLike,
            iconSize: 34.0,
          ),
          SizedBox(height: 2.0),
          Text(
            '$_likes',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: Offset(0, 2),
                  blurRadius: 3,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
