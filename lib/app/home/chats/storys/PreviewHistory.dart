import 'dart:io';
import 'dart:ui';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';

class PreviewHistory extends StatefulWidget {
  final List<File> images;
  final Function(File) onPostStory;

  const PreviewHistory({required this.images, required this.onPostStory});

  @override
  _PreviewHistoryState createState() => _PreviewHistoryState();
}

class _PreviewHistoryState extends State<PreviewHistory> {
  PageController _pageController = PageController();
  int _currentPage = 0;
  String _statusMessage = '';
  bool _showStatusMessage = false;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final blurHeight = screenHeight * 0.2;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemCount: widget.images.length,
                itemBuilder: (context, index) {
                  return Image.file(
                    widget.images[index],
                    fit: BoxFit.cover,
                    color: Colors.black.withOpacity(0.2),
                    colorBlendMode: BlendMode.darken,
                  );
                },
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: blurHeight,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
              child: Container(
                color: Colors.teal.withOpacity(0.2),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: blurHeight,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
              child: Container(
                color: Colors.teal.withOpacity(0.2),
              ),
            ),
          ),
          Center(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                return ClipRect(
                  child: Align(
                    alignment: Alignment.center,
                    widthFactor: 1.0,
                    heightFactor: 1.0,
                    child: Image.file(
                      widget.images[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 40.0,
            left: 16.0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.4),
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
                iconSize: 28.0,
              ),
            ),
          ),
          Stack(
            children: [
              Positioned(
                top: 40.0,
                right: 16.0,
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await _postAllStories();
                        setState(() {
                          _showStatusMessage = true;
                        });
                        Future.delayed(Duration(seconds: 3), () {
                          setState(() {
                            _showStatusMessage = false;
                          });
                          if (_statusMessage == 'Historia(s) enviada(s) con éxito') {
                            Navigator.pop(context);
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Text(
                        'Postear',
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 45.0,
                left: MediaQuery.of(context).size.width / 2 - 22, // Centra el ícono de tachar
                child: Container(
                  width: 44.0,
                  height: 44.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.3),
                  ),
                  child: Center(
                    child: IconButton(
                      icon: Icon(Icons.delete_sweep, color: Colors.red),
                      onPressed: () {
                        _deleteCurrentStory();
                      },
                      iconSize: 28.0,
                      tooltip: 'Borrar historia',
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (widget.images.length > 1)
            Positioned(
              bottom: 100.0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.images.length, (index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    width: 11.0,
                    height: 11.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 1.0,
                      ),
                      color: _currentPage == index ? Colors.pink : Colors.transparent,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 2.0,
                          spreadRadius: 1.0,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          Positioned(
            bottom: 20.0,
            left: 0,
            right: 0,
            child: Container(
              height: 60.0,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                children: [
                  _buildEditButton(
                    icon: Icons.crop,
                    onPressed: () {
                      // Implementar funcionalidad de recorte
                    },
                  ),
                  _buildEditButton(
                    icon: Icons.text_fields,
                    onPressed: () {
                      // Implementar funcionalidad de añadir texto
                    },
                  ),
                  _buildEditButton(
                    icon: Icons.filter_alt_outlined,
                    onPressed: () {
                      // Implementar funcionalidad de filtro
                    },
                  ),
                  _buildEditButton(
                    icon: Icons.emoji_emotions,
                    onPressed: () {
                      // Implementar funcionalidad de stickers
                    },
                  ),
                  _buildEditButton(
                    icon: Icons.brush,
                    onPressed: () {
                      // Implementar funcionalidad de dibujo
                    },
                  ),
                  _buildEditButton(
                    icon: Icons.adjust,
                    onPressed: () {
                      // Implementar funcionalidad de ajuste
                    },
                  ),
                ],
              ),
            ),
          ),
          if (_showStatusMessage)
            Positioned(
              bottom: 90.0, // mensaje esté en la parte inferior
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                margin: EdgeInsets.symmetric(horizontal: 20.0),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  _statusMessage,
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }


  Future<void> _postAllStories() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _statusMessage = 'Error al enviar historia(s). Verifique su conexión a Internet.';
      });
      return;
    }

    bool success = true;
    for (File image in widget.images) {
      try {
        await widget.onPostStory(image);
      } catch (e) {
        print('Error al enviar historia: $e');
        success = false;
        setState(() {
          _statusMessage = 'Error al enviar historia(s). Intente nuevamente.';
        });
        break;
      }
    }

    if (success) {
      setState(() {
        _statusMessage = 'Historia(s) enviada(s) con éxito';
      });
    }
  }

  void _deleteCurrentStory() {
    setState(() {
      widget.images.removeAt(_currentPage);
      if (_currentPage >= widget.images.length) {
        _currentPage = widget.images.length - 1;
      }
    });
    if (widget.images.isEmpty) {
      Navigator.pop(context);
    }
  }

  Widget _buildEditButton({required IconData icon, required VoidCallback onPressed}) {
    return Container(
      margin: EdgeInsets.only(right: 16.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.5),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
        iconSize: 28.0,
      ),
    );
  }
}
