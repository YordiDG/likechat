import 'package:flutter/material.dart';

import 'Comment.dart';

class CommentsSection extends StatefulWidget {
  @override
  _CommentsSectionState createState() => _CommentsSectionState();
}

class _CommentsSectionState extends State<CommentsSection> {
  List<Comment> _comments = [
    Comment(
      username: 'User1',
      commentText: '¡Qué gran vídeo!',
      time: DateTime.now().subtract(Duration(minutes: 10)),
      replies: [
        Comment(
          username: 'User2',
          commentText: 'Sí, me encantó!',
          time: DateTime.now().subtract(Duration(minutes: 5)),
        ),
        Comment(
          username: 'User3',
          commentText: '¿Dónde lo grabaste?',
          time: DateTime.now().subtract(Duration(minutes: 2)),
        ),
      ],
    ),
    Comment(
      username: 'User4',
      commentText: 'Muy interesante, ¡sigue así!',
      time: DateTime.now().subtract(Duration(hours: 1)),
    ),
  ];

  void _addComment(String username, String commentText) {
    setState(() {
      _comments.add(
        Comment(
          username: username,
          commentText: commentText,
          time: DateTime.now(),
        ),
      );
    });
  }

  void _addReply(int index, String username, String commentText) {
    setState(() {
      _comments[index].replies.add(
        Comment(
          username: username,
          commentText: commentText,
          time: DateTime.now(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Comments',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          itemCount: _comments.length,
          itemBuilder: (context, index) {
            return _buildCommentTile(_comments[index], index);
          },
        ),
        SizedBox(height: 8),
        _buildCommentInput(),
      ],
    );
  }

  Widget _buildCommentTile(Comment comment, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          leading: CircleAvatar(
            child: Text(comment.username[0]),
          ),
          title: Text(
            comment.username,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                comment.commentText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    _formatTime(comment.time),
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      _showReplyDialog(index);
                    },
                    child: Text(
                      'Reply',
                      style: TextStyle(
                        color: Colors.blue,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (comment.replies.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Divider(color: Colors.grey[600]),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: comment.replies.length,
            itemBuilder: (context, idx) {
              return _buildReplyTile(comment.replies[idx]);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildReplyTile(Comment reply) {
    return ListTile(
      leading: CircleAvatar(
        child: Text(reply.username[0]),
      ),
      title: Text(
        reply.username,
        style: TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reply.commentText,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          SizedBox(height: 4),
          Text(
            _formatTime(reply.time),
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentInput() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Write a comment...',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[800],
                contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              ),
              onFieldSubmitted: (text) {
                _addComment('Current User', text);
              },
            ),
          ),
          SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              // Logic to post the comment
              _addComment('Current User', 'Example comment');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
            ),
            child: Text('Post'),
          ),
        ],
      ),
    );
  }

  void _showReplyDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reply to ${_comments[index].username}'),
          content: TextFormField(
            decoration: InputDecoration(
              hintText: 'Write a reply...',
              border: OutlineInputBorder(),
            ),
            onFieldSubmitted: (text) {
              Navigator.of(context).pop();
              _addReply(index, 'Current User', text);
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _addReply(index, 'Current User', 'Example reply');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: Text('Reply'),
            ),
          ],
        );
      },
    );
  }

  String _formatTime(DateTime time) {
    Duration difference = DateTime.now().difference(time);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
