import 'package:flutter/material.dart';

class Comment {
  final String username;
  final String commentText;
  final DateTime time;
  final List<Comment> replies;

  Comment({
    required this.username,
    required this.commentText,
    required this.time,
    this.replies = const [],
  });
}
