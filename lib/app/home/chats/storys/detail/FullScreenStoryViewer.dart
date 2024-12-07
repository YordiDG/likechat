import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../Globales/estadoDark-White/DarkModeProvider.dart';

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
  double _totalTime = 6.0;
  bool _isPaused = false;
  int _viewCount = 0;
  List<String> _comments = [];
  TextEditingController _commentController = TextEditingController();

  late int _currentStoryIndex;

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
    _currentStoryIndex = widget.currentIndex;
    _startTimer();
    _incrementViewCount();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
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
          if (_currentTime >= _totalTime) {
            _currentTime = 0.0;
            _goToNextStory();
          }
        });
      }
    });
  }

  void _pauseStory() {
    setState(() {
      _isPaused = true;
    });
  }

  void _goToNextStory() {
    if (_currentStoryIndex < widget.stories.length - 1) {
      setState(() {
        _currentStoryIndex++;
        _currentTime = 0.0;
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _goToPreviousStory() {
    if (_currentStoryIndex > 0) {
      setState(() {
        _currentStoryIndex--;
        _currentTime = 0.0;
      });
    }
  }

  @override
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
          onLongPress: _pauseStory,
          onLongPressEnd: (details) {
            setState(() {
              _isPaused = false;
            });
          },
          onTapUp: (details) {
            final width = MediaQuery.of(context).size.width;
            if (details.globalPosition.dx < width / 1) {
              _goToPreviousStory();
            } else {
              _goToNextStory();
            }
          },
          onHorizontalDragEnd: (details) {
            double sensitivity = 50;
            if (details.primaryVelocity! > sensitivity) {
              _goToPreviousStory();
            } else if (details.primaryVelocity! < -sensitivity) {
              _goToNextStory();
            }
          },
          child: Stack(
            children: [
              _buildBackgroundImage(),
              _buildBlurOverlay(),
              _buildCenterImage(),
              _buildUserInfo(),
              _buildStoryProgressBar(context),
              _buildViewersButton(),
              _buildOptionsButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Positioned.fill(
      child: Image.file(
        File(widget.stories[_currentStoryIndex]),
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildBlurOverlay() {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
        child: Container(
          color: Colors.black.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildCenterImage() {
    return Center(
      child: Image.file(
        File(widget.stories[_currentStoryIndex]),
        fit: BoxFit.contain,
      ),
    );
  }

  //hora y user
  String _getTimeAgoText(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'hace unos instantes';
    } else if (difference.inMinutes < 60) {
      return 'hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    } else if (difference.inHours < 24) {
      return 'hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else {
      return 'hace 1 día'; // o "expirado" si deseas mostrar que ha caducado
    }
  }

  Widget _buildUserInfo() {
    DateTime storyCreationTime = DateTime.now().subtract(Duration(hours: 1, minutes: 15)); // Cambia esta fecha a la fecha real de la historia
    String timeAgoText = _getTimeAgoText(storyCreationTime);

    return Positioned(
      top: 56.0,
      left: 26.0,
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey.shade300,
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
              _buildTextWithShadow(_generateFakeName(), 18, Colors.white),
              SizedBox(height: 4),
              _buildTextWithShadow(timeAgoText, 10, Colors.white),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildTextWithShadow(String text, double fontSize, Color color) {
    return Stack(
      children: [
        Text(
          text,
          style: TextStyle(
            color: Colors.transparent,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.8),
                offset: Offset(0, 0),
                blurRadius: 3,
              ),
            ],
          ),
        ),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                offset: Offset(1, 1),
                blurRadius: 20,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStoryProgressBar(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12.0,
      left: 12.0,
      right: 12.0,
      child: Row(
        children: List.generate(widget.stories.length, (index) {
          return Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 2.0),
              height: 2.3, // altura barra de historia
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                color: Colors.grey[400],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8.0),
                child: LinearProgressIndicator(
                  value: index == _currentStoryIndex
                      ? _currentTime / _totalTime
                      : index < _currentStoryIndex
                      ? 1.0
                      : 0.0,
                  backgroundColor: Colors.transparent,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.cyan,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildViewersButton() {
    return Positioned(
      bottom: 20.0,
      left: 20.0,
      right: 20.0,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.remove_red_eye, color: Colors.white),
              onPressed: _showViewersModal,
            ),
            SizedBox(width: 2.0),
            Text(
              'Vistas',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionsButton(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 20.0,
      right: 20.0,
      child: IconButton(
        icon: Icon(Icons.more_vert, color: Colors.white, size: 28),
        onPressed: () => _showOptions(context),
      ),
    );
  }

  void _incrementViewCount() {
    setState(() {
      _viewCount++;
    });
  }

  void _resetTimer() {
    setState(() {
      _currentTime = 0.0;
    });
  }

  //configuracion o modal multiple
  void _showOptions(BuildContext context) {
    _pauseStory();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            // Optional: Pause video if the user taps outside the menu
          },
          child: AnimatedContainer(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              color: Color(0xFF121212), // Dark gray for the main background
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
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
                  // Title bar with vibrant color
                  Container(
                    color: Color(0xFF1A1A1A), // Darker gray for title background
                    padding: EdgeInsets.all(12.0),
                    child: Center(
                      child: Text(
                        'Configuración',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 11.0),
                  // Icon options
                  ListTile(
                    leading: Icon(Icons.privacy_tip_outlined, size: 26, color: Colors.white),
                    title: Text(
                      'Privacidad',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      // Implement privacy action here
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.delete_outline, size: 26, color: Colors.white),
                    title: Text(
                      'Eliminar',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      widget.onDelete(widget.currentIndex);
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.share_outlined, size: 26, color: Colors.white),
                    title: Text(
                      'Compartir',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      // Implement share action here
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.save_alt_outlined, size: 26, color: Colors.white),
                    title: Text(
                      'Guardar',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      // Implement save action here
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.comment_outlined, size: 26, color: Colors.white),
                    title: Text(
                      'Comentar',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showCommentDialog();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.visibility_outlined, size: 26, color: Colors.white),
                    title: Text(
                      'Vistos por',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      _showViewersModal();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).whenComplete(() {
      // Resume playback when the menu is closed
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

  String _generateFakeName() {
    final names = ['John Doe', 'Jane Smith', 'Emily Johnson', 'Michael Brown'];
    return names[widget.currentIndex % names.length];
  }
}
