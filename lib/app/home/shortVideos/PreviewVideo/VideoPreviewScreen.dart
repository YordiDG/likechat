import 'package:flutter/material.dart';
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
  bool _progressVisibility = false;
  double _startValue = 0.0;
  double _endValue = 20.0;
  String _displayText = '';
  TextStyle _textStyle = TextStyle(fontSize: 30, color: Colors.white, fontFamily: 'OpenSans');
  TextAlign _textAlign = TextAlign.center;
  late final String videoPath;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'Nuevo Video',
          style: TextStyle(fontSize: 21,color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navegación de regreso
          },
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 12.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPublishScreen(
                      videoPath: widget.videoPath,
                      publishOptions: PublishOptions(
                        description: '',
                        // Inicializa la descripción según necesites
                        hashtags: [],
                        // Inicializa los hashtags según necesites
                        mentions: [],
                        // Inicializa las menciones según necesites
                        privacyOption: 'publico',
                        // Inicializa la opción de privacidad según necesites
                        allowSave: true,
                        // Inicializa la opción de guardar según necesites
                        allowComments: true,
                        // Inicializa la opción de comentarios según necesites
                        allowPromote: false,
                        // Inicializa la opción de promoción según necesites
                        allowDownloads: true,
                        // Inicializa la opción de descargas según necesites
                        allowLocationTagging:
                        true, // Inicializa la opción de etiquetado de ubicación según necesites
                      ),
                    ),
                  ),
                );
              },
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
            top: 140,
            right: 15,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCircularIconButton(Icons.text_fields, () {
                  TextEditorHandler().openTextEditor(context, _setText);
                }),
                SizedBox(height: 16.0),
                _buildCircularIconButton(Icons.music_note, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MusicHandler(),
                    ),
                  );
                }),
                SizedBox(height: 16.0),
                _buildCircularIconButton(Icons.photo_library, () {
                  // Agregar funcionalidad para aplicar filtros
                }),
                SizedBox(height: 16.0),
                _buildCircularIconButton(Icons.download, () {
                  _downloadVideo(context);
                }),
                SizedBox(height: 16.0),
                _buildCircularIconButton(Icons.cut, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoTrimScreen(videoPath: widget.videoPath),
                    ),
                  );
                }),
                SizedBox(height: 16.0),
                _buildCircularIconButton(Icons.emoji_emotions, () {
                  // Agregar funcionalidad para emojis
                }),
              ],
            ),
          ),
          Positioned(
            top: 50,
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
          /*Positioned(
            top: 10.0,
            left: 1.0,
            right: 1.0,
            child: Visibility(
              visible: !_progressVisibility,
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 18.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      color: Colors.black.withOpacity(0.7),
                    ),
                    child: CustomPaint(
                      painter: _TrimViewerPainter(
                        trimmer: _trimmer,
                        controller: _controller,
                        startValue: _startValue,
                        endValue: _endValue,
                      ),
                      child: TrimViewer(
                        trimmer: _trimmer,
                        viewerHeight: 50.0,
                        viewerWidth: MediaQuery.of(context).size.width,
                        maxVideoLength: Duration(seconds: 20),
                        onChangeStart: (value) {
                          setState(() {
                            _startValue = value;
                          });
                        },
                        onChangeEnd: (value) {
                          setState(() {
                            _endValue = value;
                          });
                        },
                        onChangePlaybackState: (value) {
                          setState(() {
                            _isPlaying = value;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),*/
        ],
      ),
    );
  }

  void _downloadVideo(BuildContext context) async {
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
    }
  }

  Widget _buildCircularIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.5),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

}

/*class _TrimViewerPainter extends CustomPainter {
  final Trimmer trimmer;
  final VideoPlayerController controller;
  final double startValue;
  final double endValue;

  _TrimViewerPainter({
    required this.trimmer,
    required this.controller,
    required this.startValue,
    required this.endValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final Paint progressPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    final double videoDuration = trimmer.videoPlayerController!.value.duration.inSeconds.toDouble();
    final double currentPosition = controller.value.position.inSeconds.toDouble();
    final double left = (startValue / videoDuration) * size.width;
    final double right = (endValue / videoDuration) * size.width;
    final double position = (currentPosition / videoDuration) * size.width;

    // Draw the selected trim area
    canvas.drawRect(Rect.fromLTRB(left, 0, right, size.height), paint);

    // Draw the current progress
    canvas.drawRect(Rect.fromLTRB(left, 0, position, size.height), progressPaint);

    // Draw the current position line
    final Paint positionPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawLine(Offset(position, 0), Offset(position, size.height), positionPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}*/
