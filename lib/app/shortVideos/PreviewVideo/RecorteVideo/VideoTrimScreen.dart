import 'package:flutter/material.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class VideoTrimScreen extends StatefulWidget {
  final String videoPath;

  VideoTrimScreen({required this.videoPath});

  @override
  _VideoTrimScreenState createState() => _VideoTrimScreenState();
}

class _VideoTrimScreenState extends State<VideoTrimScreen> {
  final Trimmer _trimmer = Trimmer();
  late VideoPlayerController _videoPlayerController;
  bool _isPlaying = false;
  double _videoPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  void _loadVideo() async {
    await _trimmer.loadVideo(videoFile: File(widget.videoPath));
    _videoPlayerController = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
      });
    _videoPlayerController.addListener(() {
      setState(() {
        _videoPosition = _videoPlayerController.value.position.inSeconds.toDouble();
      });
    });
  }

  void _togglePlayback() {
    setState(() {
      _isPlaying = !_isPlaying;
      _isPlaying ? _videoPlayerController.play() : _videoPlayerController.pause();
    });
  }

  @override
  void dispose() {
    _trimmer.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Edición Video',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navegación de regreso
          },
        ),
        actions: [
          Container(
            height: 40, // Altura del contenedor
            padding: EdgeInsets.symmetric(horizontal: 20), // Padding horizontal para el espacio izquierdo y derecho
            decoration: BoxDecoration(
              color: Colors.blue, // Fondo azul
              borderRadius: BorderRadius.circular(20), // Borde redondeado
            ),
            child: TextButton(
              onPressed: () {
                // Implementa aquí la lógica para guardar los cambios o navegar
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center, // Centra el contenido horizontalmente
                mainAxisSize: MainAxisSize.min, // Ajusta el tamaño del Row al contenido
                children: [
                  Text(
                    "Guardar",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16, // Tamaño del texto
                    ),
                  ),
                ],
              ),
            ),
          )



        ],
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  if (_videoPlayerController.value.isInitialized) ...[
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 50.0),
                          height: MediaQuery.of(context).size.width *
                              0.6 /
                              _videoPlayerController.value.aspectRatio,
                          child: AspectRatio(
                            aspectRatio: _videoPlayerController.value.aspectRatio,
                            child: VideoPlayer(_videoPlayerController),
                          ),
                        ),
                        Positioned(
                          left: 40.0,
                          right: 40.0,
                          bottom: 20.0,
                          child: Container(
                            height: 60.0,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _videoPlayerController.value.duration!.inSeconds + 1,
                              itemBuilder: (context, index) {
                                return GestureDetector(
                                  onTap: () {
                                    _videoPlayerController.seekTo(Duration(seconds: index));
                                  },
                                  child: Container(
                                    width: 60.0,
                                    margin: EdgeInsets.symmetric(horizontal: 2.0),
                                    child: Stack(
                                      alignment: Alignment.bottomCenter,
                                      children: <Widget>[
                                        VideoPlayer(_videoPlayerController),
                                        Positioned(
                                          bottom: 0,
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            height: 6.0,
                                            color: index <= _videoPosition ? Colors.red.withOpacity(0.8) : Colors.grey.withOpacity(0.5),
                                            width: 60.0,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.0),
                  ],
                  _buildPlaybackControls(),
                  SizedBox(height: 5.0),
                ],
              ),
            ),
            _buildBottomCarousel(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaybackControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.replay_10, size: 26.0, color: Colors.white),
          onPressed: () {
            final position = _videoPlayerController.value.position;
            final newPosition = position - Duration(seconds: 10);
            _videoPlayerController.seekTo(newPosition);
          },
        ),
        IconButton(
          icon: Icon(
            _isPlaying ? Icons.pause : Icons.play_arrow,
            size: 30.0,
            color: Colors.white,
          ),
          onPressed: _togglePlayback,
        ),
        IconButton(
          icon: Icon(Icons.forward_10, size: 26.0, color: Colors.white),
          onPressed: () {
            final position = _videoPlayerController.value.position;
            final newPosition = position + Duration(seconds: 10);
            _videoPlayerController.seekTo(newPosition);
          },
        ),
        IconButton(
          icon: Icon(Icons.fullscreen, size: 27.0, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FullScreenVideo(_videoPlayerController)),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBottomCarousel() {
    final List<Widget> iconsWithLabels = [
      _buildCarouselItem(Icons.cut, 'Recortar'),
      _buildCarouselItem(Icons.music_note, 'Música'),
      _buildCarouselItem(Icons.text_fields, 'Texto'),
      _buildCarouselItem(Icons.filter, 'Filtros'),
      _buildCarouselItem(Icons.star, 'Favoritos'),
      _buildCarouselItem(Icons.layers, 'Capas'),
      _buildCarouselItem(Icons.settings, 'Ajustes'),
    ];

    return Container(
      height: 80.0,
      color: Colors.black,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: iconsWithLabels,
      ),
    );
  }

  Widget _buildCarouselItem(IconData icon, String label) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: Icon(icon, size: 26.0, color: Colors.white),
            onPressed: () {
              // Add functionality as needed for each button
            },
          ),
          Text(
            label,
            style: TextStyle(color: Colors.white, fontSize: 11.0),
          ),
        ],
      ),
    );
  }
}

class FullScreenVideo extends StatelessWidget {
  final VideoPlayerController controller;

  FullScreenVideo(this.controller);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}
