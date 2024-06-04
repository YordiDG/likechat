import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class LikeChatScreen extends StatefulWidget {
  @override
  _LikeChatScreenState createState() => _LikeChatScreenState();
}

class _LikeChatScreenState extends State<LikeChatScreen> {
  List<String> _stories = [];
  int _currentIndex = 0;
  Timer? _timer;
  final double _storySize = 80.0;
  final double _activeStorySize = 90.0;

  File? _image;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
    ].request();
  }

  Future<void> _captureImage() async {
    PermissionStatus cameraPermissionStatus = await Permission.camera.status;
    if (cameraPermissionStatus.isGranted) {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
      }
    } else {
      await Permission.camera.request();
      if (await Permission.camera.isGranted) {
        final pickedFile =
            await ImagePicker().pickImage(source: ImageSource.camera);

        if (pickedFile != null) {
          setState(() {
            _image = File(pickedFile.path);
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text('Se requieren permisos de cámara para capturar imágenes.'),
        ));
      }
    }
  }

  Future<void> _captureVideo() async {
    PermissionStatus cameraPermissionStatus = await Permission.camera.status;
    PermissionStatus microphonePermissionStatus =
        await Permission.microphone.status;

    if (cameraPermissionStatus.isGranted &&
        microphonePermissionStatus.isGranted) {
      final pickedFile = await ImagePicker().pickVideo(
          source: ImageSource.camera, maxDuration: Duration(seconds: 15));

      if (pickedFile != null) {
        // Aquí puedes manejar el archivo de video seleccionado
      }
    } else {
      await Permission.camera.request();
      await Permission.microphone.request();
      if (await Permission.camera.isGranted &&
          await Permission.microphone.isGranted) {
        final pickedFile = await ImagePicker().pickVideo(
            source: ImageSource.camera, maxDuration: Duration(seconds: 15));

        if (pickedFile != null) {
          // Aquí puedes manejar el archivo de video seleccionado
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Se requieren permisos de cámara y micrófono para grabar videos.'),
        ));
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      setState(() {
        if (_stories.isNotEmpty) {
          _currentIndex = (_currentIndex + 1) % _stories.length;
        }
      });
    });
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _addStory() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        _stories.addAll(pickedFiles.map((file) => file.path));
        if (_stories.length == pickedFiles.length) {
          _startTimer();
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('No se seleccionaron imágenes.'),
      ));
    }
  }

  void _deleteStory(int index) {
    setState(() {
      _stories.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Contenido de tu pantalla de LikeChat
        Positioned(
          top: MediaQuery.of(context).size.height * 0.40,
          right: 16.0,
          child: Column(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: _image != null
                    ? FileImage(_image!)
                    : AssetImage('assets/placeholder.png') as ImageProvider,
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomRight,
                      child: IconButton(
                        icon: Icon(Icons.add_a_photo,
                            color: Colors.white, size: 30.0),
                        onPressed: () async {
                          showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return SafeArea(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    ListTile(
                                      leading: Icon(Icons.photo_library),
                                      title: Text('Galería'),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        _pickImage();
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.photo_camera),
                                      title: Text('Cámara'),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        _captureImage();
                                      },
                                    ),
                                    ListTile(
                                      leading: Icon(Icons.videocam),
                                      title: Text('Video'),
                                      onTap: () {
                                        Navigator.of(context).pop();
                                        _captureVideo();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.0),
            ],
          ),
        ),
        // Funcionalidad de las historias
        Container(
          margin: EdgeInsets.only(top: 0.0),
          padding: EdgeInsets.symmetric(vertical: 8.0),
          height: _activeStorySize + 40,
          width: 400,
          color: Color(0xFFD2D1D1),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 8.0, right: 16.0),
                  child: GestureDetector(
                    onTap: _addStory,
                    child: Container(
                      width: _storySize,
                      height: _storySize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Color(0xFFD9F103)),
                        color: Color(0xFF0D0D55),
                      ),
                      child: Icon(
                        Icons.add,
                        size: 40,
                        color: Color(0xFFD9F103),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    if (_stories.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenStoryViewer(
                            stories: _stories,
                            currentIndex: _currentIndex,
                            onDelete: _deleteStory,
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    width: _activeStorySize,
                    height: _activeStorySize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: ClipOval(
                      child: _stories.isNotEmpty
                          ? Image.file(
                              File(_stories[_currentIndex]),
                              fit: BoxFit.cover,
                            )
                          : Container(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class FullScreenStoryViewer extends StatelessWidget {
  final List<String> stories;
  final int currentIndex;
  final Function(int) onDelete;

  FullScreenStoryViewer({
    required this.stories,
    required this.currentIndex,
    required this.onDelete,
  });

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.privacy_tip),
              title: Text('Privacidad'),
              onTap: () {
                Navigator.pop(context);
                // Implementar la acción de privacidad aquí
              },
            ),
            ListTile(
              leading: Icon(Icons.delete),
              title: Text('Eliminar'),
              onTap: () {
                Navigator.pop(context);
                onDelete(currentIndex);
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: () {
            if (currentIndex < stories.length - 1) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => FullScreenStoryViewer(
                    stories: stories,
                    currentIndex: currentIndex + 1,
                    onDelete: onDelete,
                  ),
                ),
              );
            } else {
              Navigator.pop(context);
            }
          },
          onLongPress: () {
            onDelete(currentIndex);
            Navigator.pop(context);
          },
          onHorizontalDragEnd: (details) {
            double sensitivity = 50;
            if (details.primaryVelocity! > sensitivity) {
              if (currentIndex > 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenStoryViewer(
                      stories: stories,
                      currentIndex: currentIndex - 1,
                      onDelete: onDelete,
                    ),
                  ),
                );
              }
            } else if (details.primaryVelocity! < -sensitivity) {
              if (currentIndex < stories.length - 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenStoryViewer(
                      stories: stories,
                      currentIndex: currentIndex + 1,
                      onDelete: onDelete,
                    ),
                  ),
                );
              }
            }
          },
          child: Stack(
            children: [
              Center(
                child: Image.file(
                  File(stories[currentIndex]),
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 80,
                right: 16,
                child: GestureDetector(
                  onTap: () {
                    _showOptions(context);
                  },
                  child: Icon(
                    Icons.more_vert,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Icon(
                      Icons.remove_red_eye,
                      color: Color(0xFFD9F103),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Visto por:',
                      style: TextStyle(
                        color: Color(0xFFD9F103),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
