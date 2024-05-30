import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final bool isRead;
  final DateTime time;

  const MessageBubble({
    required this.message,
    required this.isMe,
    required this.isRead,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(color: isMe ? Colors.white : Colors.black),
            ),
            SizedBox(height: 4.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  time.hour.toString().padLeft(2, '0') +
                      ':' +
                      time.minute.toString().padLeft(2, '0'),
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.black54,
                    fontSize: 12.0,
                  ),
                ),
                if (isMe)
                  Icon(
                    isRead ? Icons.done_all : Icons.done,
                    color: isRead ? Colors.blue : Colors.grey,
                    size: 16.0,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
