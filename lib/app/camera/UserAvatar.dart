import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserAvatar extends StatefulWidget {
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
                  icon: Icon(Icons.add_circle, color: Colors.red, size: 30.0),
                  onPressed: () async {
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
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
}
