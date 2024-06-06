import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserAvatar extends StatefulWidget {
  final bool isOwner;
  final Function(List<String>)? addFriendCallback; // Función para agregar amigos

  const UserAvatar({Key? key, required this.isOwner, this.addFriendCallback})
      : super(key: key);

  @override
  _UserAvatarState createState() => _UserAvatarState();
}

class _UserAvatarState extends State<UserAvatar> {
  File? _image;
  bool _showButtons = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _recordVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(
        source: ImageSource.camera, maxDuration: const Duration(seconds: 10));

    if (pickedFile != null) {
      // Manejar el video grabado aquí
    }
  }

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
                  : AssetImage('assets/placeholder.png') as ImageProvider,
              child: _image == null
                  ? Icon(Icons.person, color: Colors.white, size: 20)
                  : null,
            ),
          ),
        ),
        if (_showButtons)
          Positioned(
            top: 10,
            right: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(height: 8),
                IconButton(
                  icon: widget.isOwner
                      ? Icon(Icons.add_circle,
                      color: Colors.red, size: 30.0)
                      : Icon(Icons.person_add,
                      color: Colors.green, size: 30.0), // Cambia el icono según si eres el propietario o no
                  onPressed: () async {
                    if (widget.isOwner) {
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Wrap(
                            children: [
                              ListTile(
                                leading: Icon(Icons.camera_alt),
                                title: Text('Grabar Video'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _recordVideo();
                                },
                              ),
                              ListTile(
                                leading: Icon(Icons.photo_library),
                                title: Text('Subir Imagen'),
                                onTap: () {
                                  Navigator.pop(context);
                                  _pickImage();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    } else {
                      _addFriend(); // Agregar amigo si no eres el propietario del video
                    }
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
}
