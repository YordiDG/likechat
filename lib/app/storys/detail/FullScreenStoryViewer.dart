import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';

class FullScreenStoryViewer extends StatefulWidget {
  final List<String> stories;
  final int currentIndex;
  final Function(int) onDelete;

  FullScreenStoryViewer({
    required this.stories,
    required this.currentIndex,
    required this.onDelete,
  });

  @override
  _FullScreenStoryViewerState createState() => _FullScreenStoryViewerState();
}

class _FullScreenStoryViewerState extends State<FullScreenStoryViewer> {
  late Timer _timer;
  double _currentTime = 0.0;
  double _totalTime = 5.0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      setState(() {
        _currentTime += 0.1;
      });

      if (_currentTime >= _totalTime) {
        _goToNextStory();
      }
    });
  }

  void _resetTimer() {
    setState(() {
      _currentTime = 0.0;
    });
  }

  void _goToNextStory() {
    _resetTimer();
    if (widget.currentIndex < widget.stories.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => FullScreenStoryViewer(
            stories: widget.stories,
            currentIndex: widget.currentIndex + 1,
            onDelete: widget.onDelete,
          ),
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

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
                widget.onDelete(widget.currentIndex);
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
            _resetTimer();
            _goToNextStory();
          },
          onLongPress: () {
            _showOptions(context);
          },
          onHorizontalDragEnd: (details) {
            double sensitivity = 50;
            if (details.primaryVelocity! > sensitivity) {
              if (widget.currentIndex > 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenStoryViewer(
                      stories: widget.stories,
                      currentIndex: widget.currentIndex - 1,
                      onDelete: widget.onDelete,
                    ),
                  ),
                );
              }
            } else if (details.primaryVelocity! < -sensitivity) {
              if (widget.currentIndex < widget.stories.length - 1) {
                _goToNextStory(); // Avanza a la siguiente historia al deslizar hacia la izquierda
              } else {
                Navigator.pop(context);
              }
            }
          },
          child: Stack(
            children: [
              Center(
                child: Image.file(
                  File(widget.stories[widget.currentIndex]),
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 56.0,
                left: 26.0,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 25,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person,
                        color: Colors.grey[800],
                        size: 30,
                      ),
                    ),
                    SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _generateFakeName(), // Nombre de usuario ficticio
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${DateTime.now().hour}:${DateTime.now().minute}', // Hora de publicación
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 15.0,
                left: 15.0,
                right: 15.0,
                child: LinearProgressIndicator(
                  value: _currentTime / _totalTime,
                  backgroundColor: Colors.grey[800],
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD9F103)),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 28.0,
                right: 16.0,
                child: GestureDetector(
                  onTap: () {
                    _showOptions(context);
                  },
                  child: Icon(
                    Icons.more_vert,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              Positioned(
                bottom: 16,
                left: 0,
                right: 0,
                child: Column(
                  children: [
                    Text(
                      'Visto por:',
                      style: TextStyle(
                        color: Color(0xFFD9F103),
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.remove_red_eye,
                          color: Color(0xFFD9F103),
                          size: 20,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'View', // Texto para indicar visualizaciones
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
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

  // Función para generar un nombre ficticio aleatorio
  String _generateFakeName() {
    List<String> names = ['John', 'Emma', 'Michael', 'Sophia', 'Daniel'];
    List<String> lastNames = ['Smith', 'Johnson', 'Williams', 'Brown', 'Jones'];
    return '${names[widget.currentIndex % names.length]} ${lastNames[widget.currentIndex % lastNames.length]}';
  }
}
