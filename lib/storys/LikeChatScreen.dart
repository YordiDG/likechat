import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

  @override
  void initState() {
    super.initState();
    _startTimer();
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

  Future<void> _addStory() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      setState(() {
        _stories.addAll(pickedFiles.map((file) => file.path));
        if (_stories.length == pickedFiles.length) {
          _startTimer(); // Comienza el temporizador cuando se agregan las historias
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
    return Container(
      margin: EdgeInsets.only(top: 0.0),
      padding: EdgeInsets.symmetric(vertical: 8.0),
      height: _activeStorySize + 40,
      color: Color(0xFFB7ABF5),
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
                    border: Border.all(color: Color(0xFF6545E3)),
                    color: Color(0xFFEAEAEA), // Color de fondo del botón de añadir
                  ),
                  child: Icon(
                    Icons.add,
                    size: 40,
                    color: Color(0xFF6545E3),
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

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (currentIndex == 0) {
          Navigator.pop(context);
          return true;
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => FullScreenStoryViewer(
                stories: stories,
                currentIndex: 0,
                onDelete: onDelete,
              ),
            ),
          );
          return false;
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onTap: () {
            Navigator.pop(context);
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
                bottom: 16,
                left: 0,
                right: 0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
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
                      },
                      icon: Icon(Icons.arrow_back_ios, color: Colors.purple),
                    ),
                    Icon(
                      Icons.remove_red_eye,
                      color: Colors.purple,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Visto', // Placeholder para el número de visualizaciones
                      style: TextStyle(
                        color: Colors.purple,
                        fontSize: 16,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
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
                      },
                      icon: Icon(Icons.arrow_forward_ios, color: Colors.purple),
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









