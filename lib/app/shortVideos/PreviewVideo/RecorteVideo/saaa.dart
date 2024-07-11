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
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  if (_videoPlayerController.value.isInitialized)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 40.0),
                      height: MediaQuery.of(context).size.width *
                          0.6 /
                          _videoPlayerController.value.aspectRatio,
                      child: AspectRatio(
                        aspectRatio: _videoPlayerController.value.aspectRatio,
                        child: VideoPlayer(_videoPlayerController),
                      ),
                    ),
                  SizedBox(height: 16.0),
                  TrimViewer(
                    trimmer: _trimmer,
                    viewerHeight: 50.0,
                    viewerWidth: MediaQuery.of(context).size.width,
                    maxVideoLength: Duration(seconds: 20),
                    onChangeStart: (value) {},
                    onChangeEnd: (value) {},
                    onChangePlaybackState: (value) {
                      setState(() {
                        _isPlaying = value;
                      });
                    },
                  ),

                  SizedBox(height: 2.0),
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
      // Añade más íconos según sea necesario
    ];

    return Container(
      height: 80.0, // Ajusta según tus necesidades
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
              // Agrega la funcionalidad deseada para cada botón
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
      backgroundColor: Colors.black,
      body: Center(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: VideoPlayer(controller),
        ),
      ),
    );
  }
}