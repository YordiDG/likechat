import 'dart:io';
import 'dart:ui';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../../Globales/estadoDark-White/DarkModeProvider.dart';
import '../../shortVideos/PreviewVideo/opciones de edicion/TextEdit/TextEditorHandler.dart';

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
  TextEditingController _descriptionController = TextEditingController();

  bool _showIcons = true;
  bool _showDescription = false;
  String _displayText = '';
  TextStyle _textStyle = TextStyle(
      fontSize: 30, color: Colors.white, fontFamily: 'OpenSans');
  TextAlign _textAlign = TextAlign.center;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final blurHeight = screenHeight * 0.2;

    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final backgroundColor = darkModeProvider.backgroundColor;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
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
          // Desenfoque en la parte superior
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
          // Desenfoque en la parte inferior completa
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            top: MediaQuery.of(context).size.height * 0.4,
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
          Positioned(
            bottom: 0.1,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: _showDescription ? 1.0 : 0.0,
              duration: Duration(milliseconds: 300),
              child: Container(
                color: Colors.black.withOpacity(0.4),
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _descriptionController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Añade una descripción...',
                    hintStyle: TextStyle(color: textColor),
                    border: InputBorder.none,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.cyan),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  maxLines: 3,
                  maxLength: 150,
                  cursorColor: Colors.white,
                ),
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
                        Future.delayed(Duration(seconds: 2), () {
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
                          borderRadius: BorderRadius.circular(10.0),
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
              bottom: 160.0,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.images.length, (index) {
                  return Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                    width: 9.0,
                    height: 9.0,
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
          if (_showIcons)
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
                      tooltip: 'Recortar',
                    ),
                    _buildEditButton(
                      icon: Icons.text_fields,
                      onPressed: () {
                        TextEditorHandler().openTextEditor(
                            context, _setText);
                      },
                      tooltip: 'Añadir texto',
                    ),
                    _buildEditButton(
                      icon: Icons.filter_alt_outlined,
                      onPressed: () {
                        // Implementar funcionalidad de filtro
                      },
                      tooltip: 'Filtros',
                    ),
                    _buildEditButton(
                      icon: Icons.emoji_emotions,
                      onPressed: () {
                        // Implementar funcionalidad de stickers
                      },
                      tooltip: 'Stickers',
                    ),
                    _buildEditButton(
                      icon: Icons.brush,
                      onPressed: () {
                        // Implementar funcionalidad de dibujo
                      },
                      tooltip: 'Dibujo',
                    ),
                    _buildEditButton(
                      icon: Icons.adjust,
                      onPressed: () {
                        // Implementar funcionalidad de ajuste
                      },
                      tooltip: 'Ajustes',
                    ),
                  ],
                ),
              ),
            ),
          Positioned(
            bottom: 140.0,
            left: 20.0,
            child: FloatingActionButton(
              onPressed: () {
                setState(() {
                  _showIcons = !_showIcons;
                  _showDescription = !_showDescription;
                });
              },
              backgroundColor: Colors.cyan.withOpacity(0.7),
              child: Icon(
                _showIcons
                    ? FontAwesomeIcons.solidComment
                    : FontAwesomeIcons.pencilAlt,
                color: Colors.white,
                size: 25,
              ),
            ),
          ),
          if (_showStatusMessage)
            Positioned(
              bottom: 90.0,
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

  void _setText(String text, TextStyle style, TextAlign align) {
    setState(() {
      _displayText = text;
      _textStyle = style;
      _textAlign = align;
    });
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
        print('Error al publicar historia: $e');
        success = false;
      }
    }

    setState(() {
      _statusMessage = success ? 'Historia(s) enviada(s) con éxito' : 'Error al enviar historia(s). Inténtelo de nuevo más tarde.';
    });
  }

  void _deleteCurrentStory() {
    setState(() {
      widget.images.removeAt(_currentPage);
      if (widget.images.isEmpty) {
        Navigator.pop(context);
      } else {
        _currentPage = (_currentPage - 1).clamp(0, widget.images.length - 1);
        _pageController.jumpToPage(_currentPage);
      }
    });
  }

  Widget _buildEditButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10.0),
        padding: EdgeInsets.all(8.0), // Ajusta el padding si es necesario
        constraints: BoxConstraints(
          maxWidth: 160.0, // Aumenta el ancho máximo si es necesario para acomodar el texto
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5), // Fondo negro con opacidad
          borderRadius: BorderRadius.circular(8.0), // Bordes redondeados
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Asegúrate de que Column ocupe solo el espacio necesario
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Tooltip(
              message: tooltip,
              child: Icon(
                icon,
                size: 25.0,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 5.0),
            // Usa `Flexible` para ajustar el tamaño del texto
            Flexible(
              fit: FlexFit.loose,
              child: FittedBox(
                fit: BoxFit.scaleDown, // Ajusta el texto para que se ajuste al contenedor
                child: Text(
                  tooltip,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.0, // Tamaño de la fuente mantenido en 15
                  ),
                  textAlign: TextAlign.center, // Centra el texto si es necesario
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
