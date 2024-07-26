import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class PhotoPerfilScreen extends StatefulWidget {
  final String token; // El token JWT

  PhotoPerfilScreen({required this.token});

  @override
  _PhotoPerfilScreenState createState() => _PhotoPerfilScreenState();
}

class _PhotoPerfilScreenState extends State<PhotoPerfilScreen> {
  String? _profileImageUrl;
  late String userId;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    userId = getUserIdFromToken(widget.token);
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final response = await http.get(
      Uri.parse('http://192.168.0.10:8088/api/v1/users/$userId/photo'),
      headers: {
        'Authorization': 'Bearer ${widget.token}'
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        _profileImageUrl =
        'data:image/png;base64,${base64Encode(response.bodyBytes)}';
      });
    }
  }

  Future<void> _uploadProfileImage(File imageFile) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.0.10:8088/api/v1/users/$userId/photo'),
    );
    request.files
        .add(await http.MultipartFile.fromPath('photo', imageFile.path));
    request.headers['Authorization'] = 'Bearer ${widget.token}';

    final response = await request.send();

    if (response.statusCode == 201) {
      _loadProfileImage();
    }
  }

  Future<void> _updateProfileImage(File imageFile) async {
    final request = http.MultipartRequest(
      'PUT',
      Uri.parse('http://192.168.0.10:8088/api/v1/users/$userId/photo'),
    );
    request.files
        .add(await http.MultipartFile.fromPath('photo', imageFile.path));
    request.headers['Authorization'] = 'Bearer ${widget.token}';

    final response = await request.send();

    if (response.statusCode == 200) {
      _loadProfileImage();
    }
  }

  Future<void> _deleteProfileImage() async {
    final response = await http.delete(
      Uri.parse('http://192.168.0.10:8088/api/v1/users/$userId/photo'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 204) {
      setState(() {
        _profileImageUrl = null;
      });
    }
  }

  void _handleImageSelection(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      File image = File(pickedFile.path);
      if (_profileImageUrl == null) {
        _uploadProfileImage(image);
      } else {
        _updateProfileImage(image);
      }
    }
  }

  String getUserIdFromToken(String token) {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    return decodedToken['sub'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: _profileImageUrl != null
                  ? NetworkImage(_profileImageUrl!)
                  : AssetImage('lib/assets/placeholder_user.jpg') as ImageProvider,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _handleImageSelection(ImageSource.gallery);
              },
              child: Text('Change Photo'),
            ),
            ElevatedButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Take photo from:"),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              GestureDetector(
                                child: Text("Gallery"),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  _handleImageSelection(ImageSource.gallery);
                                },
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                              ),
                              GestureDetector(
                                child: Text("Camera"),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  _handleImageSelection(ImageSource.camera);
                                },
                              )
                            ],
                          ),
                        ),
                      );
                    }
                );
              },
              child: Text('Take Photo'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _deleteProfileImage();
              },
              child: Text('Delete Photo'),
            ),
          ],
        ),
      ),
    );
  }
}
