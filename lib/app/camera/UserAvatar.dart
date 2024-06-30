import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserAvatar extends StatefulWidget {
  final bool isOwner;
  final Function(List<String>)? addFriendCallback; // Función para agregar amigos

  const UserAvatar({Key? key, required this.isOwner, this.addFriendCallback, required double size})
      : super(key: key);

  @override
  _UserAvatarState createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  File? _image;
  bool _showButtons = false;


  void _addFriend() {
    // Lógica para agregar amigo
    // Por ejemplo, aquí estoy simulando agregar amigos a una lista
    final List<String> friendsList = [];
    widget.addFriendCallback?.call(friendsList);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _showButtons = !_showButtons;
            });
          },
          child: Center(
            child: CircleAvatar(
              radius: 27,
              backgroundImage: _image != null
                  ? FileImage(_image!)
                  : AssetImage('lib/assets/placeholder_user.jpg') as ImageProvider,
            ),
          ),
        ),
      ],
    );
  }
}
