import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../estadoDark-White/DarkModeProvider.dart';

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
  bool _isPaused = false;
  int _viewCount = 0;
  List<String> _comments = [];
  TextEditingController _commentController = TextEditingController();

  // Lista de personas que han visto la historia
  final List<Map<String, String>> _viewers = [
    {'name': 'Juan', 'photo': 'assets/images/person1.jpg', 'time': '12:30 PM'},
    {'name': 'Ana', 'photo': 'assets/images/person2.jpg', 'time': '12:32 PM'},
    {'name': 'Pedro', 'photo': 'assets/images/person3.jpg', 'time': '12:34 PM'},
    {'name': 'Luis', 'photo': 'assets/images/person4.jpg', 'time': '12:36 PM'},
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
    _incrementViewCount();
  }

  @override
  void dispose() {
    _timer.cancel();
    _commentController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (!_isPaused) {
        setState(() {
          _currentTime += 0.1;
        });

        if (_currentTime >= _totalTime) {
          _goToNextStory();
        }
      }
    });
  }

  void _resetTimer() {
    setState(() {
      _currentTime = 0.0;
    });
  }

  void _pauseStory() {
    setState(() {
      _isPaused = !_isPaused;
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
    _pauseStory();

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return GestureDetector(
          onTap: () {
            // Opcional: También podrías pausar el video si el usuario toca fuera del menú
          },
          child: Column(
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
              ListTile(
                leading: Icon(Icons.share),
                title: Text('Compartir'),
                onTap: () {
                  Navigator.pop(context);
                  // Implementar la acción de compartir aquí
                },
              ),
              ListTile(
                leading: Icon(Icons.save_alt),
                title: Text('Guardar'),
                onTap: () {
                  Navigator.pop(context);
                  // Implementar la acción de guardar aquí
                },
              ),
              ListTile(
                leading: Icon(Icons.comment),
                title: Text('Comentar'),
                onTap: () {
                  Navigator.pop(context);
                  _showCommentDialog();
                },
              ),
              ListTile(
                leading: Icon(Icons.visibility),
                title: Text('Vistos por'),
                onTap: () {
                  Navigator.pop(context);
                  _showViewersModal();
                },
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      // Reanuda la reproducción cuando se cierre el menú
      setState(() {
        _isPaused = false;
      });
    });
  }

  void _showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Agregar Comentario'),
          content: TextField(
            controller: _commentController,
            decoration: InputDecoration(hintText: 'Escribe tu comentario aquí'),
            maxLines: 3,
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  if (_commentController.text.isNotEmpty) {
                    _comments.add(_commentController.text);
                    _commentController.clear();
                  }
                });
                Navigator.pop(context);
              },
              child: Text('Enviar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  void _incrementViewCount() {
    setState(() {
      _viewCount += 1;
    });
  }

  void _showViewersModal() {
    _pauseStory();
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)), // Esquinas redondeadas en la parte superior
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.cyan, // Fondo de la AppBar
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)), // Esquinas redondeadas en la parte superior
                ),
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                child: Row(
                  children: [
                    Text(
                      'Vistos por:',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Color del texto
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      icon: Icon(Icons.info, color: Colors.white), // Ícono amigable
                      onPressed: () {
                        // Acción al presionar el ícono
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _viewers.length,
                  itemBuilder: (context, index) {
                    final viewer = _viewers[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundImage: AssetImage(viewer['photo']!),
                      ),
                      title: Text(viewer['name']!),
                      subtitle: Text(viewer['time']!),
                      trailing: Icon(Icons.message),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    ).whenComplete(() {
      // Reanuda la reproducción cuando se cierre el menú
      setState(() {
        _isPaused = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {

    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final backgroundColor = darkModeProvider.backgroundColor;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: GestureDetector(
          onLongPress: () {
            _pauseStory(); // Alterna entre pausar y reanudar
          },
          onLongPressEnd: (details) {
            setState(() {
              _isPaused = false; // Reanuda la reproducción al soltar el dedo
            });
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
                      backgroundColor: Colors.grey,
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
                            color: textColor,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${DateTime.now().hour}:${DateTime.now().minute}', // Hora de publicación
                          style: TextStyle(
                            color: textColor,
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
                left: 10.0,
                right: 10.0,
                child: Container(
                  height: 4.0, // Ajusta la altura del indicador de progreso
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2.0), // Radio del borde
                    border: Border.all(color: Colors.grey, width: 0.1), // Color y ancho del borde
                  ),
                  child: LinearProgressIndicator(
                    value: _currentTime / _totalTime,
                    backgroundColor: Colors.transparent, // Fondo transparente
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.cyan), // Color del progreso
                  ),
                ),
              ),
              Positioned(
                bottom: 20.0,
                left: 20.0,
                right: 20.0,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.remove_red_eye, color: iconColor),
                        onPressed: () {
                          _showViewersModal(); // Muestra quién ha visto la historia
                        },
                      ),
                      SizedBox(width: 8.0), // Espacio entre el ícono y el texto
                      Text(
                        'Vistas', // Texto al lado del ícono
                        style: TextStyle(color: textColor),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 20.0,
                right: 20.0,
                child: IconButton(
                  icon: Icon(Icons.more_vert, color: iconColor),
                  onPressed: () {
                    _showOptions(context);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _generateFakeName() {
    final names = ['John Doe', 'Jane Smith', 'Emily Johnson', 'Michael Brown'];
    return names[widget.currentIndex % names.length];
  }
}
