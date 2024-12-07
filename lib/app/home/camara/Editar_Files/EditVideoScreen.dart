import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_player/video_player.dart';

import '../../../APIS-Consumir/Deezer-API-Musica/MusicModal.dart';
import '../../../APIS-Consumir/Tenor API/StickerModal.dart';
import '../../shortVideos/PreviewVideo/opciones de edicion/TextEdit/TextEditorHandler.dart';

class EditVideoScreen extends StatefulWidget {
  final File file;

  EditVideoScreen({required this.file});

  @override
  _EditVideoScreenState createState() => _EditVideoScreenState();
}

class _EditVideoScreenState extends State<EditVideoScreen>
    with TickerProviderStateMixin {
  VideoPlayerController? _controller;

  late AnimationController _animationController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  // Variables de texto
  String _displayText = '';
  TextStyle _textStyle =
  TextStyle(fontSize: 30, color: Colors.white, fontFamily: 'OpenSans');
  TextAlign _textAlign = TextAlign.center;

  @override
  void initState() {
    super.initState();

    // Inicializar el controlador de video usando el archivo proporcionado
    _controller = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        setState(() {});
        _controller!.play();
      });

    // Controlador de animación
    _animationController = AnimationController(
      duration: Duration(seconds: 1), // Duración del zoom
      vsync: this,
    );

    // Animación de escala
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15, // Un pequeño zoom hacia adelante
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Configurar un temporizador para repetir el efecto
    Timer.periodic(Duration(seconds: 3), (timer) {
      if (!_animationController.isAnimating) {
        _animationController.forward().then((_) {
          // Reiniciar la animación al finalizar
          _animationController.reset();
        });
      }
    });
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.dispose();
    }

    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Contenido principal (video)
          Positioned.fill(
            child: _controller != null && _controller!.value.isInitialized
                ? AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            )
                : Center(child: CircularProgressIndicator()),
          ),
          // Flecha de regreso
          buildCloseButton(context),
          // Botón de música
          buildAddMusicButton(context),
          // Carrusel de opciones
          Stack(
            children: [
              // Carrucel de opciones
              Positioned(
                bottom: 68, // Asegúrate de ajustar esto si es necesario
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildEditOption(Icons.text_fields, "Texto", () {
                          TextEditorHandler().openTextEditor(context, _setText);
                        }),
                        SizedBox(width: 20),
                        _buildEditOption(Icons.filter, "Filtrar", () {
                          // Acción para el botón de Filtrar
                          print("Filtrar botón presionado");
                        }),
                        SizedBox(width: 20),
                        _buildEditOption(Icons.rotate_right, "Rotar", () {
                          // Acción para el botón de Rotar
                          print("Rotar botón presionado");
                        }),
                        SizedBox(width: 20),
                        _buildEditOption(Icons.crop, "Recortar", () {
                          // Acción para el botón de Recortar
                          print("Recortar botón presionado");
                        }),
                        SizedBox(width: 20),
                        _buildEditOption(Icons.brightness_6, "Brillo", () {
                          // Acción para el botón de Brillo
                          print("Brillo botón presionado");
                        }),
                        SizedBox(width: 20),
                        _buildEditOption(Icons.blur_on, "Desenfoque", () {
                          // Acción para el botón de Desenfoque
                          print("Desenfoque botón presionado");
                        }),
                        SizedBox(width: 20),
                        _buildEditOption(Icons.draw, "Dibujar", () {
                          // Acción para el botón de Dibujar
                          print("Dibujar botón presionado");
                        }),
                        SizedBox(width: 20),
                        _buildEditOption(Icons.emoji_emotions, "Stickers", () {
                          // Acción para el botón de Stickers
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            builder: (context) => StickerModal(),
                          );
                        }),
                        SizedBox(width: 20),
                        _buildEditOption(Icons.auto_fix_high, "Mejorar", () {
                          // Acción para el botón de Mejorar
                          print("Mejorar botón presionado");
                        }),
                        SizedBox(width: 20),
                        _buildEditOption(Icons.grid_on, "Cuadro", () {
                          // Acción para el botón de Cuadro
                          print("Cuadro botón presionado");
                        }),
                        SizedBox(width: 20),
                        _buildEditOption(Icons.grid_4x4, "Mosaico", () {
                          // Acción para el botón de Mosaico
                          print("Mosaico botón presionado");
                        }),
                      ],
                    ),
                  ),
                ),
              ),
              // Botones finales
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  color: Colors.black,
                  padding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: buttonStyle(Colors.white, Colors.black),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.upload, color: Colors.black),
                              SizedBox(width: 5),
                              Text("Publicar",
                                  style:
                                  TextStyle(fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: buttonStyle(Colors.cyan, Colors.white),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("Siguiente",
                                  style:
                                  TextStyle(fontWeight: FontWeight.w700)),
                              SizedBox(width: 5),
                              Icon(Icons.arrow_forward_ios,
                                  size: 18, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.cyan,
        onPressed: () {
          setState(() {
            if (_controller!.value.isPlaying) {
              _controller!.pause();
            } else {
              _controller!.play();
            }
          });
        },
        child: Icon(
          _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      ),
    );
  }

  // Método para mostrar el modal de música
  void _showMusicModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MusicModal(); // Asegúrate de que `MusicModal` esté definido en tu proyecto
      },
    );
  }

  // Botón de música
  Widget buildAddMusicButton(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 1,
      left: MediaQuery.of(context).size.width / 2 - 50,
      child: SafeArea(
        child: GestureDetector(
          onTap: () => _showMusicModal(context),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.1),
              borderRadius: BorderRadius.circular(7),
              border: Border.all(
                color: Colors.grey.shade800,
                width: 0.1,
              ),
            ),
            padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  FontAwesomeIcons.music,
                  color: Colors.white,
                  size: 15,
                ),
                SizedBox(width: 7),
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..scale(_scaleAnimation.value),
                      child: Text(
                        'Música',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Botón de regreso
  Widget buildCloseButton(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top,
      left: 10,
      child: IconButton(
        onPressed: () {
          Navigator.pop(context);
        },
        icon: Icon(Icons.arrow_back_ios_new),
        color: Colors.white,
      ),
    );
  }

  // Estilo del botón
  ButtonStyle buttonStyle(Color color, Color textColor) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      elevation: 0,
      padding: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50),
      ),
    );
  }

  // Crear opciones para el carrusel de edición
  Widget _buildEditOption(IconData icon, String label, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(
              icon,
              size: 22,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // Método para establecer el texto
  void _setText(String text, TextStyle style, TextAlign align) {
    setState(() {
      _displayText = text;
      _textStyle = style;
      _textAlign = align;
    });
  }
}
