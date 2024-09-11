import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../PreviewVideo/PublicarVideo/VideoPublishScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:vibration/vibration.dart';

import '../PreviewVideo/VideoPreviewScreen.dart';


class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;
  final PublishOptions publishOptions;

  VideoPlayerScreen({
    required this.videoPath,
    required this.publishOptions,
  });

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isPaused = false;
  bool _isLiked = false;
  bool _floatingActionButtonVisible = true;
  static List<String> videoList = []; // Lista temporal de videos
  int currentIndex = 0; // Índice del video actual

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {
          _controller.play();
        });
      });

    _controller.addListener(() {
      if (_controller.value.isPlaying != !_isPaused) {
        setState(() {
          _isPaused = !_controller.value.isPlaying;
        });
      }
    });

    // Agregar video a la lista y actualizar el índice
    setState(() {
      videoList.add(widget.videoPath);
      currentIndex = videoList.length - 1;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPaused = true;
      } else {
        _controller.play();
        _isPaused = false;
      }
    });
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });
  }

  void _refreshPage() {
    // Método para refrescar la página actual
    setState(() {
      // Actualizar estado aquí si es necesario
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _togglePlayPause, // Toggle play/pause on tap
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta! > 0) {
            // Deslizar hacia abajo
            _refreshPage(); // Refrescar la pantalla actual
          } else if (details.primaryDelta! < 0) {
            // Deslizar hacia arriba
            // Navegar al siguiente video si hay
            if (currentIndex < videoList.length - 1) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen(
                    videoPath: videoList[currentIndex + 1],
                    publishOptions: widget.publishOptions,
                  ),
                ),
              );
            }
          }
        },
        child: Stack(
          children: [
            Center(
              child: _controller.value.isInitialized
                  ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
                  : Center(child: CircularProgressIndicator()),
            ),
            if (_isPaused || !_controller.value.isPlaying)
              Center(
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white.withOpacity(0.5),
                  size: 80,
                ),
              ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(10),
                color: Colors.black.withOpacity(0.5),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.publishOptions.description,
                      style: TextStyle(color: Colors.white, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                _isLiked ? Icons.favorite : Icons.favorite_border,
                                color: _isLiked ? Colors.pink : Colors.white,
                              ),
                              onPressed: _toggleLike,
                            ),
                            Text('123', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                        SizedBox(width: 20), // Espacio entre grupos de íconos
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.comment, color: Colors.white),
                              onPressed: () {
                                // Manejar acción de comentario
                              },
                            ),
                            Text('45', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                        SizedBox(width: 20), // Espacio entre grupos de íconos
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.share, color: Colors.white),
                              onPressed: () {
                                // Manejar acción de compartir
                              },
                            ),
                            Text('67', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _floatingActionButtonVisible
          ? FloatingActionButton(
        onPressed: _buildFloatingActionButton, // Subir nuevo video
        child: Icon(Icons.add),
      )
          : null,
    );
  }

  Widget _buildFloatingActionButton() {
    if (!_floatingActionButtonVisible) {
      return SizedBox(); // Ocultar el FAB si no es visible
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 28.0, right: 18.0),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: FloatingActionButton(
            backgroundColor: Colors.cyan,
            onPressed: () {
              _showVideoOptions(context);
            },
            child: Icon(
              Icons.video_camera_back,
              size: 33,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  void _showVideoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: Color(0xFF121212), // Gris oscuro para el fondo principal
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                spreadRadius: 8,
                blurRadius: 15,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding:
            const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.0,
                      height: 4.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  // Título con fondo más oscuro
                  Container(
                    color: Color(0xFF1A1A1A),
                    // Gris más oscuro para el fondo del título
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'Opciones de Video',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 11.0),
                  // Opciones de íconos
                  ListTile(
                    leading: CircleAvatar(
                      radius: 28.0,
                      // Tamaño del círculo
                      backgroundColor: Colors.white.withOpacity(0.1),
                      // Fondo más claro
                      child: FaIcon(
                        FontAwesomeIcons.video,
                        color: Colors.red, // Ícono blanco
                        size: 20.0, // Tamaño del ícono
                      ),
                    ),
                    title: Text(
                      'Grabar Video',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    subtitle: Text(
                      'Captura un nuevo video',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                          fontFamily: 'Montserrat'),
                    ),
                    onTap: () {
                      if (Vibration.hasVibrator() != null) {
                        Vibration.vibrate(duration: 50);
                      }
                      Navigator.pop(context);
                      _recordVideo();
                    },
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      radius: 28.0,
                      // Tamaño del círculo
                      backgroundColor: Colors.white.withOpacity(0.1),
                      // Fondo más claro
                      child: Icon(
                        FontAwesomeIcons.photoVideo,
                        color: Colors.cyan, // Ícono blanco
                        size: 20.0, // Tamaño del ícono
                      ),
                    ),
                    title: Text(
                      'Seleccionar de la Galería',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    subtitle: Text(
                      'Elige un video existente',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                          fontFamily: 'Montserrat'),
                    ),
                    onTap: () {
                      if (Vibration.hasVibrator() != null) {
                        Vibration.vibrate(duration: 50);
                      }
                      Navigator.pop(context);
                      _pickVideo();
                    },
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      radius: 28.0,
                      // Tamaño del círculo
                      backgroundColor: Colors.white.withOpacity(0.1),
                      // Fondo más claro
                      child: FaIcon(
                        FontAwesomeIcons.image,
                        color: Colors.green, // Ícono blanco
                        size: 20.0, // Tamaño del ícono
                      ),
                    ),
                    title: Text(
                      'Seleccionar Imagen',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    subtitle: Text(
                      'Elige una imagen existente',
                      style: TextStyle(
                          color: Colors.white70,
                          fontFamily: 'Montserrat',
                          fontSize: 13),
                    ),
                    onTap: () {
                      if (Vibration.hasVibrator() != null) {
                        Vibration.vibrate(duration: 50);
                      }
                      Navigator.pop(context);
                      _pickImage();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
    }
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: Duration(seconds: 20),
    );
    if (pickedFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPreviewScreen(videoPath: pickedFile.path),
        ),
      );
    }
  }

  // Método para grabar un nuevo video
  void _recordVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: Duration(seconds: 20),
    );
    if (pickedFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPreviewScreen(videoPath: pickedFile.path),
        ),
      );
    }
  }
}

