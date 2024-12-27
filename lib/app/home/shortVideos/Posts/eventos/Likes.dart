import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../APIS-Consumir/DaoPost/PostDatabase.dart';
import '../../../../Globales/estadoDark-White/DarkModeProvider.dart';
import '../PostClass.dart';


class Likes extends StatefulWidget {
  final Post post;
  final Function(Post) onLikeUpdated;

  const Likes({
    Key? key,
    required this.post,
    required this.onLikeUpdated,
  }) : super(key: key);

  @override
  _LikeButtonState createState() => _LikeButtonState();
}

class _LikeButtonState extends State<Likes> {
  late PostDatabase _postDatabase;

  @override
  void initState() {
    super.initState();
    _postDatabase = PostDatabase.instance;
  }

  Future<void> toggleLike() async {
    final updatedPost = Post(
      id: widget.post.id,
      description: widget.post.description,
      imagePaths: widget.post.imagePaths,
      createdAt: widget.post.createdAt,
      userName: widget.post.userName,
      userAvatar: widget.post.userAvatar,
      isLiked: !widget.post.isLiked,
      likeCount: widget.post.isLiked ? widget.post.likeCount - 1 : widget.post.likeCount + 1,
    );

    try {
      if (updatedPost.id != null) {
        await _postDatabase.updatePost(updatedPost);
        widget.onLikeUpdated(updatedPost);
      }
    } catch (e) {
      print('Error al actualizar like: $e');
      // Mostrar un snackbar con el error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar el like'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String formatLikeCount(int count) {
    if (count >= 1000000) {
      return '${(count ~/ 1000000)} Mill.';
    } else if (count >= 1000) {
      return '${(count ~/ 1000)} mil';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: toggleLike,
            child: Icon(
              widget.post.isLiked
                  ? FontAwesomeIcons.solidHeart
                  : FontAwesomeIcons.heart,
              size: 24,
              color: widget.post.isLiked ? Colors.red : Colors.grey,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            formatLikeCount(widget.post.likeCount),
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}