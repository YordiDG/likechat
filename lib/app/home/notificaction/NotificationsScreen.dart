import 'package:flutter/material.dart';


class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: Icon(Icons.person, color: Colors.cyan),
          title: Text('Friend request accepted'),
        ),
        ListTile(
          leading: Icon(Icons.thumb_up, color: Colors.cyan),
          title: Text('Someone liked your post'),
        ),
        ListTile(
          leading: Icon(Icons.comment, color: Colors.cyan),
          title: Text('New comment on your post'),
        ),
        ListTile(
          leading: Icon(Icons.group_add, color: Colors.cyan),
          title: Text('New friend suggestion'),
        ),
      ],
    );
  }
}