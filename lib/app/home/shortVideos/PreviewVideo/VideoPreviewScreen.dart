import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'dart:io';
import 'PublicarVideo/VideoPublishScreen.dart';
import 'RecorteVideo/VideoTrimScreen.dart';
import 'opciones de edicion/TextEdit/TextEditorHandler.dart';
import 'opciones de edicion/dowload/VideoDownloader.dart';
import 'opciones de edicion/musica/MusicHandler.dart';

class VideoPreviewScreen extends StatefulWidget {
  final String videoPath;

  VideoPreviewScreen({required this.videoPath});

  @override
  _VideoPreviewScreenState createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
  late VideoPlayerController _controller;
  final Trimmer _trimmer = Trimmer();
  bool _isPlaying = false;
  bool _showFullIcons = true; // Cambiado a true para mostrar los íconos desplegados por defecto
  double _startValue = 0.0;
  double _endValue = 20.0;
  String _displayText = '';
  bool _isLoading = false;
  TextStyle _textStyle = TextStyle(
      fontSize: 30, color: Colors.white, fontFamily: 'OpenSans');
  TextAlign _textAlign = TextAlign.center;

  @override
  void initState() {
    super.initState();
    _loadVideo();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
        setState(() {
          _isPlaying = true;
        });
      });

    _controller.addListener(() {
      if (_controller.value.position.inSeconds.toDouble() > _endValue) {
        _controller.seekTo(Duration(seconds: _startValue.toInt()));
      }
      setState(() {});
    });
  }

  void _loadVideo() {
    _trimmer.loadVideo(videoFile: File(widget.videoPath));
  }

  void _playPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
        _isPlaying = false;
      } else {
        _controller.play();
        _isPlaying = true;
      }
    });
  }

  void _toggleIcons() {
    setState(() {
      _showFullIcons = !_showFullIcons;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setText(String text, TextStyle style, TextAlign align) {
    setState(() {
      _displayText = text;
      _textStyle = style;
      _textAlign = align;
    });
  }

  void _downloadVideo(BuildContext context) async {
    setState(() {
      _isLoading = true; // Mostrar el indicador de carga
    });

    final videoDownloader = VideoDownloader();

    try {
      await videoDownloader.downloadAndSaveVideo(widget.videoPath);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Video guardado exitosamente')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el video')),
      );
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false; // Ocultar el indicador de carga
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (_isLoading) {
      // Mostrar una advertencia si la descarga está en progreso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('La descarga está en progreso. Espere a que termine.'),
          duration: Duration(seconds: 3),
        ),
      );
      return false; // Impedir que el usuario navegue hacia atrás
    }
    return true; // Permitir navegar hacia atrás si no hay descarga en progreso
  }

  Widget _buildCircularIconButton(IconData icon, String? label, VoidCallback onPressed) {
    bool isPlusIcon = icon == Icons.add_circle; // Verifica si el ícono es de "Más"

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.8),
            boxShadow: isPlusIcon
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 4.0,
                spreadRadius: 1.0,
                offset: Offset(0, 2),
              ),
            ]
                : [], // Aplica sombra solo si es el ícono de "Más"
          ),
          child: IconButton(
            icon: Icon(icon, color: Colors.black),
            onPressed: onPressed,
          ),
        ),
        if (label != null) ...[
          SizedBox(height: 4.0), // Espacio entre ícono y texto
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              shadows: [
                Shadow(
                  blurRadius: 4.0,
                  color: Colors.black.withOpacity(0.5),
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black,
          title: Text(
            'Nuevo Video',
            style: TextStyle(
                fontSize: 21, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              if (!_isLoading) {
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('La descarga está en progreso. Espere a que termine.'),
                    duration: Duration(seconds: 3),
                  ),
                );
              }
            },
          ),
          actions: [
            Container(
              margin: EdgeInsets.only(right: 12.0),
              child: ElevatedButton(
                onPressed: !_isLoading ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoPublishScreen(
                        videoPath: widget.videoPath,
                        publishOptions: PublishOptions(
                          description: '',
                          hashtags: [],
                          mentions: [],
                          privacyOption: 'publico',
                          allowSave: true,
                          allowComments: true,
                          allowPromote: false,
                          allowDownloads: true,
                          allowLocationTagging: true,
                        ),
                      ),
                    ),
                  );
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  'Siguiente',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            GestureDetector(
              onTap: _playPause,
              child: Container(
                color: Colors.black,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 120,
              left: 16.0,
              right: 16.0,
              child: Align(
                alignment: Alignment.topCenter,
                child: Text(
                  _displayText,
                  textAlign: _textAlign,
                  style: _textStyle,
                ),
              ),
            ),
            Positioned(
              bottom: 12.0,
              left: 0,
              right: 0,
              child: Container(
                color: _showFullIcons ? Colors.black.withOpacity(0.6) : Colors.transparent,
                padding: EdgeInsets.symmetric(vertical: 14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_showFullIcons)
                      _buildCircularIconButton(Icons.add_circle, 'Más', _toggleIcons),
                    if (_showFullIcons) ...[
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildCircularIconButton(
                                  Icons.remove_circle, 'Menos', _toggleIcons),
                              SizedBox(width: 8.0), // Espaciado entre íconos
                              _buildCircularIconButton(
                                  Icons.text_fields, 'Texto', () {
                                TextEditorHandler().openTextEditor(
                                    context, _setText);
                              }),
                              _buildCircularIconButton(
                                  Icons.music_note, 'Música', () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MusicHandler(),
                                  ),
                                );
                              }),
                              _buildCircularIconButton(
                                  Icons.photo_library, 'Filtros', () {
                                // Agregar funcionalidad para aplicar filtros
                              }),
                              _buildCircularIconButton(Icons.cut, 'Recortar', () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        VideoTrimScreen(
                                            videoPath: widget.videoPath),
                                  ),
                                );
                              }),
                              _buildCircularIconButton(
                                  Icons.emoji_emotions, 'Emojis', () {
                                // Agregar funcionalidad para emojis
                              }),
                              _buildCircularIconButton(
                                  Icons.download, 'Descargar', () {
                                _downloadVideo(context);
                              }),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (_isLoading) ...[
              ModalBarrier(dismissible: false, color: Colors.black.withOpacity(0.5)),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset('lib/assets/downloadel.json', width: 100, height: 100),
                    Text(
                      'Guardando...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
