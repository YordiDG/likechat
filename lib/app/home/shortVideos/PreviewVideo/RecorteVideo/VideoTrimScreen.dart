import 'package:flutter/material.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import '../opciones de edicion/TextEdit/TextEditorHandler.dart';

class VideoTrimScreen extends StatefulWidget {
  final String videoPath;

  VideoTrimScreen({required this.videoPath});

  @override
  _VideoTrimScreenState createState() => _VideoTrimScreenState();
}

class _VideoTrimScreenState extends State<VideoTrimScreen> {
  final Trimmer _trimmer = Trimmer();
  VideoPlayerController? _videoPlayerController; // Cambiar a nullable
  bool _isPlaying = false;
  double _videoPosition = 0.0;

  String _displayText = '';
  TextStyle _textStyle =
      TextStyle(fontSize: 30, color: Colors.white, fontFamily: 'OpenSans');
  TextAlign _textAlign = TextAlign.center;

  double _frameWidth = 50.0;

  @override
  void initState() {
    super.initState();
    _loadVideo();
  }

  void _loadVideo() async {
    await _trimmer.loadVideo(videoFile: File(widget.videoPath));
    _videoPlayerController = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {
          _isPlaying = true; // Inicia la reproducción automáticamente
          _videoPlayerController!.play(); // Reproduce el video
        });
      });
    _videoPlayerController!.addListener(() {
      setState(() {
        _videoPosition =
            _videoPlayerController!.value.position.inSeconds.toDouble();
        if (_videoPlayerController!.value.position ==
            _videoPlayerController!.value.duration) {
          _isPlaying = false; // Detiene la reproducción cuando termina el video
        }
      });
    });
  }

  void _togglePlayback() {
    setState(() {
      if (_videoPlayerController != null) {
        // Asegúrate de que no sea null
        _isPlaying = !_isPlaying;
        _isPlaying
            ? _videoPlayerController!.play()
            : _videoPlayerController!.pause();
      }
    });
  }

  @override
  void dispose() {
    _trimmer.dispose();
    _videoPlayerController?.dispose(); // Asegúrate de que sea null
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Edición Video',
          style: TextStyle(
              color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navegación de regreso
          },
        ),
        actions: [
          Container(
            height: 40,
            // Altura del contenedor
            margin: EdgeInsets.symmetric(horizontal: 10),
            padding: EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.cyan, // Fondo rosa
              borderRadius: BorderRadius.circular(11),
            ),
            child: TextButton(
              onPressed: () {
                // Implementa aquí la lógica para guardar los cambios o navegar
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                // Centra el contenido horizontalmente
                mainAxisSize: MainAxisSize.min,
                // Ajusta el tamaño del Row al contenido
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
            // Contenedor para el VideoPlayer
            Container(
              margin: EdgeInsets.symmetric(horizontal: 80.0),
              height: _videoPlayerController != null
                  ? MediaQuery.of(context).size.width *
                      0.5 /
                      _videoPlayerController!.value.aspectRatio
                  : 0.0, // Altura por defecto en caso de que sea nulo
              child: _videoPlayerController != null
                  ? AspectRatio(
                      aspectRatio: _videoPlayerController!.value.aspectRatio,
                      child: VideoPlayer(_videoPlayerController!),
                    )
                  : Center(
                      child:
                          CircularProgressIndicator()), // Cargar indicador si es nulo
            ),
            SizedBox(height: 10.0),

            // Controles de reproducción debajo del video
            if (_videoPlayerController?.value.isInitialized ?? false)
              _buildPlaybackControls(),

            SizedBox(height: 5.0),

            // Línea de tiempo de frames con línea de progreso vertical y duración total
            if (_videoPlayerController?.value.isInitialized ?? false)
              Column(
                children: [
                  // Línea horizontal superior
                  Container(
                    height: 1.0, // Altura de la línea
                    color: Colors.white, // Color de la línea
                  ),

                  Row(
                    children: [
                      // Línea vertical gruesa al inicio con efecto
                      Container(
                        width: 4.0, // Ancho de la línea
                        height: 60.0, // Altura de la línea
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue, Colors.white], // Color del degradado
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5.0),
                            bottomLeft: Radius.circular(5.0),
                          ),
                        ),
                      ),

                      // Línea de progreso vertical encima de los frames
                      Container(
                        width: 2.0,
                        height: 60.0,
                        color: Colors.white, // Color de la línea de progreso
                        margin: EdgeInsets.only(
                          left: _videoPosition * _frameWidth / _videoPlayerController!.value.duration!.inSeconds,
                        ),
                      ),

                      // Línea de tiempo de frames con control de posición
                      Expanded(
                        child: SizedBox(
                          height: 60.0,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _videoPlayerController!.value.duration!.inSeconds + 1,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  _videoPlayerController!.seekTo(Duration(seconds: index));
                                },
                                child: Container(
                                  width: _frameWidth,
                                  child: Stack(
                                    alignment: Alignment.bottomCenter,
                                    children: <Widget>[
                                      VideoPlayer(_videoPlayerController!),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Línea vertical gruesa al final con efecto
                      Container(
                        width: 4.0, // Ancho de la línea
                        height: 60.0, // Altura de la línea
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue, Colors.white], // Color del degradado
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(5.0),
                            bottomRight: Radius.circular(5.0),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Línea horizontal inferior
                  Container(
                    height: 1.0, // Altura de la línea
                    color: Colors.white, // Color de la línea
                  ),

                  SizedBox(height: 8.0),

                  // Mostrar la duración total del video
                  Text(
                    "${_videoPosition.toStringAsFixed(1)} / ${_videoPlayerController!.value.duration.inSeconds.toString()} segundos",
                    style: TextStyle(color: Colors.white, fontSize: 12.0),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),

            SizedBox(height: 16.0),
            Expanded(child: Container()),
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
            if (_videoPlayerController != null) {
              final position = _videoPlayerController!.value.position;
              final newPosition = position - Duration(seconds: 5);
              _videoPlayerController!.seekTo(newPosition);
            }
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
            if (_videoPlayerController != null) {
              final position = _videoPlayerController!.value.position;
              final newPosition = position + Duration(seconds: 5);
              _videoPlayerController!.seekTo(newPosition);
            }
          },
        ),
        IconButton(
          icon: Icon(Icons.fullscreen, size: 27.0, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      FullScreenVideo(_videoPlayerController!)),
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
              if (label == 'Texto') {
                // Crear una instancia de TextEditorHandler y llamar a openTextEditor
                TextEditorHandler().openTextEditor(
                  context,
                  (String text, TextStyle style, TextAlign align) {
                    // Lógica para manejar el texto editado
                    _setText(text, style, align);
                  },
                );
              }
              // Implementa la lógica para otros botones aquí si es necesario
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

  void _setText(String text, TextStyle style, TextAlign align) {
    // Lógica para manejar el texto editado
    setState(() {
      _displayText = text;
      _textStyle = style;
      _textAlign = align;
    });
  }
}

class FullScreenVideo extends StatelessWidget {
  final VideoPlayerController videoPlayerController;

  FullScreenVideo(this.videoPlayerController);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AspectRatio(
          aspectRatio: videoPlayerController.value.aspectRatio,
          child: VideoPlayer(videoPlayerController),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (videoPlayerController.value.isPlaying) {
            videoPlayerController.pause();
          } else {
            videoPlayerController.play();
          }
        },
        child: Icon(
          videoPlayerController.value.isPlaying
              ? Icons.pause
              : Icons.play_arrow,
        ),
      ),
    );
  }
}
