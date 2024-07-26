import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_sound/flutter_sound.dart';

class MusicHandler extends StatefulWidget {
  @override
  _MusicHandlerState createState() => _MusicHandlerState();
}

class _MusicHandlerState extends State<MusicHandler> {
  final FlutterSoundPlayer _flutterSoundPlayer = FlutterSoundPlayer();
  bool _isPlaying = false;
  bool _isPaused = false;
  String? _filePath;
  Duration _currentPosition = Duration.zero;
  Duration _duration = Duration.zero;
  List<double> _waveformData = List.generate(100, (index) => 0.0);
  double _volume = 0.5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _flutterSoundPlayer.setSubscriptionDuration(Duration(milliseconds: 50));
    _flutterSoundPlayer.onProgress?.listen((e) {
      setState(() {
        _currentPosition = e.position;
        _duration = e.duration;
        _waveformData = List.generate(
          100,
              (index) => sin(index / 10 + _currentPosition.inSeconds / 2) * 50 + 50,
        );
      });
    });
  }

  @override
  void dispose() {
    _flutterSoundPlayer.closePlayer();
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _pickAndPlayMusic() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);

    if (result != null && result.files.single.path != null) {
      setState(() {
        _filePath = result.files.single.path!;
        _currentPosition = Duration.zero;
        _isPlaying = false;
        _isPaused = false;
        _waveformData = List.generate(100, (index) => 0.0);
      });

      await _flutterSoundPlayer.closePlayer();
      await _flutterSoundPlayer.startPlayer(
        fromURI: _filePath,
        whenFinished: () {
          setState(() {
            _isPlaying = false;
            _timer?.cancel();
          });
        },
      );

      setState(() {
        _isPlaying = true;
        _isPaused = false;
      });

      _flutterSoundPlayer.setVolume(_volume);

      // Iniciar un temporizador para actualizar la forma de onda y la línea de tiempo
      _timer = Timer.periodic(Duration(milliseconds: 50), (timer) {
        if (_isPlaying) {
          setState(() {
            _waveformData = List.generate(
              100,
                  (index) => sin(index / 10 + _currentPosition.inSeconds / 2) * 50 + 50,
            );
          });
        } else {
          timer.cancel();
        }
      });
    }
  }

  void _togglePlayPause() async {
    if (_isPlaying) {
      if (_isPaused) {
        await _flutterSoundPlayer.resumePlayer();
      } else {
        await _flutterSoundPlayer.pausePlayer();
      }
      setState(() {
        _isPaused = !_isPaused;
      });
    } else if (_filePath != null) {
      await _flutterSoundPlayer.startPlayer(
        fromURI: _filePath,
        whenFinished: () {
          setState(() {
            _isPlaying = false;
            _timer?.cancel();
          });
        },
      );
      setState(() {
        _isPlaying = true;
        _isPaused = false;
      });

      _flutterSoundPlayer.setVolume(_volume);
    }
  }

  void _seekTo(Duration position) async {
    await _flutterSoundPlayer.seekToPlayer(position);
    setState(() {
      _currentPosition = position;
    });
  }

  void _setVolume(double volume) {
    setState(() {
      _volume = volume;
      _flutterSoundPlayer.setVolume(volume);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Music Handler'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _pickAndPlayMusic,
              child: Text('Seleccionar y Reproducir Música'),
            ),
            if (_filePath != null) ...[
              SizedBox(height: 20),
              Container(
                height: 150,
                child: CustomPaint(
                  painter: EEGWaveformPainter(
                    waveformData: _waveformData,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text('Reproduciendo: ${_currentPosition.inSeconds}s'),
              Slider(
                value: _currentPosition.inSeconds.toDouble(),
                min: 0,
                max: _duration.inSeconds.toDouble(),
                onChanged: (value) {
                  _seekTo(Duration(seconds: value.toInt()));
                },
                label: 'Posición: ${_currentPosition.inSeconds}s',
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(_isPlaying ? (_isPaused ? Icons.play_arrow : Icons.pause) : Icons.play_arrow),
                    onPressed: _togglePlayPause,
                  ),
                  IconButton(
                    icon: Icon(Icons.skip_next),
                    onPressed: () {
                      // Lógica para cambiar la música
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.save),
                    onPressed: () {
                      // Lógica para guardar el audio
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.post_add),
                    onPressed: () {
                      // Lógica para postear el audio
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              Slider(
                value: _volume,
                min: 0,
                max: 1,
                onChanged: (value) {
                  _setVolume(value);
                },
                label: 'Volumen: ${(_volume * 100).toInt()}%',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class EEGWaveformPainter extends CustomPainter {
  final List<double> waveformData;

  EEGWaveformPainter({required this.waveformData});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final Path path = Path();
    double xInterval = size.width / (waveformData.length - 1);
    double yCenter = size.height / 2;

    path.moveTo(0, yCenter - waveformData[0]);

    for (int i = 1; i < waveformData.length; i++) {
      path.lineTo(i * xInterval, yCenter - waveformData[i]);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
