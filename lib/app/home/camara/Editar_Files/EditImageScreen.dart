import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:video_player/video_player.dart';

import '../../../APIS-Consumir/Deezer-API-Musica/MusicModal.dart';
import '../../../APIS-Consumir/Tenor API/StickerModal.dart';
import '../../shortVideos/Posts/OpenCamara/preview/PreviewScreen.dart';
import '../../shortVideos/Posts/PostClass.dart';
import '../../shortVideos/PreviewVideo/PublicarVideo/VideoPublishScreen.dart';
import '../../shortVideos/PreviewVideo/opciones de edicion/Recorte/ImageCropperService.dart';
import '../../shortVideos/PreviewVideo/opciones de edicion/TextEdit/TextEditorHandler.dart';
import 'configuracion/PrivacyAndPermissionsModal.dart';

class EditImageScreen extends StatefulWidget {
  late final File file;
  final bool isVideo;

  EditImageScreen({required this.file, required this.isVideo});

  @override
  _EditImageScreenState createState() => _EditImageScreenState();
}

class _EditImageScreenState extends State<EditImageScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _controller;

  //variables de texto
  String _displayText = '';
  TextStyle _textStyle =
      TextStyle(fontSize: 30, color: Colors.white, fontFamily: 'OpenSans');
  TextAlign _textAlign = TextAlign.center;

  //variables
  TextEditingController _descriptionController = TextEditingController();
  String? _imagePath;
  List<Post> _publishedPosts = [];

  bool isZoomed = false;

  final String _lyricText = 'Añadir Música';
  late AnimationController _animationController;
  late String _currentLyric = '';
  bool _isWriting = true;

  @override
  void initState() {
    super.initState();

    // Configuración del controlador de animación
    _animationController = AnimationController(
      duration: const Duration(seconds: 2), // Ajusta la duración de la animación
      vsync: this,
    );

    // Iniciar el ciclo de letras
    _startLyricCycle();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

// Método para el ciclo de letras
  void _startLyricCycle() {
    // Añade un listener para manejar el estado de la animación
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Cuando la animación se completa, espera 5 segundos y luego desaparece
        Future.delayed(const Duration(seconds: 10), () {
          if (mounted) {
            setState(() {
              _isWriting = false;
            });
            _animationController.reset();  // Resetea la animación (texto desaparece)
          }
        });
      }

      if (status == AnimationStatus.dismissed) {
        // Cuando la animación ha desaparecido completamente
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            setState(() {
              _isWriting = true;
            });
            _animationController.forward(); // Empieza a escribir de nuevo
          }
        });
      }
    });

    // Inicia la primera animación (escribir)
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.black, // Establece el fondo negro
        child: Stack(
          children: [
            // Contenido principal (imagen o video)
            Positioned.fill(
              child: InteractiveViewer(
                panEnabled: isZoomed,
                scaleEnabled: true,
                minScale: 1.0,
                // Escala mínima
                maxScale: 3.0,
                // Limita el zoom a 1x, sin posibilidad de ampliación
                child: widget.isVideo
                    ? _controller != null && _controller!.value.isInitialized
                        ? AspectRatio(
                            aspectRatio: _controller!.value.aspectRatio,
                            child: VideoPlayer(_controller!),
                          )
                        : Center(child: CircularProgressIndicator())
                    : Image.file(
                        widget.file,
                        fit: BoxFit.contain,
                      ),
              ),
            ),
            // Flecha de regreso
            buildCloseButton(context),
            // Botón de música
            buildAddMusicButton(context),
            buildConfiguration(context),
            // Carrusel de opciones
            Stack(
              children: [
                // Carrusel de opciones
                buidlBotonesCarrucel(context),
                // Botones finales
                buildBottomBar(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  //botones carrucel
  Widget buidlBotonesCarrucel(BuildContext context) {
    return Positioned(
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
              _buildEditOption(Icons.cut, "Recortar", () {
                ImageCropperService cropperService = ImageCropperService();
                cropperService.showCropOptions(
                    context: context,
                    imageFile: widget.file,
                    onCropped: (croppedFile) {
                      setState(() {
                        widget.file = croppedFile;
                      });
                    });
              }),
              SizedBox(width: 20),
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
    );
  }

  //botones de inferior
  Widget buildBottomBar(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Colors.black,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => PostClass()));
                },
                style: buttonStyle(Colors.white, Colors.black),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.upload, color: Colors.black),
                    SizedBox(width: 5),
                    Text(
                      "Publicar",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (_imagePath != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PreviewScreen(
                          imagePath: _imagePath!,
                          descriptionController: _descriptionController,
                          onPublish: _publishPost,
                        ),
                      ),
                    );
                  } else {
                    // Mostrar un mensaje de error si no se ha tomado una foto
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              "Por favor, toma una foto antes de continuar.")),
                    );
                  }
                },
                style: buttonStyle(Colors.cyan, Colors.white),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Siguiente",
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(width: 5),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _publishPost() {
    String description = _descriptionController.text;

    // Validar que haya una imagen
    if (_imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                "No se puede publicar sin una imagen. Toma una foto antes de continuar.")),
      );
      return;
    }

    List<String> imagePaths = [_imagePath!];

    if (description.isNotEmpty || imagePaths.isNotEmpty) {
      // Crear un nuevo post
      Post newPost = Post(description: description, imagePaths: imagePaths);

      // Agregar el post publicado a la lista
      setState(() {
        _publishedPosts.add(newPost);
        _descriptionController.clear();
        _imagePath = null; // Restablecer la imagen
      });

      // Volver a la pantalla principal
      Navigator.of(context).pop();
    }
  }

//metodo de musica
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
              color: Colors.grey.withOpacity(0.2),
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
                    // Calcula el texto a mostrar basado en la animación
                    String displayedText = _isWriting
                        ? _lyricText.substring(0, (_animationController.value * _lyricText.length).toInt())
                        : ''; // Deja el texto vacío cuando no está escribiendo

                    return Opacity(
                      opacity: _isWriting ? 1.0 : 0.0, // Controla la visibilidad del texto
                      child: SizedBox(
                        width: 83,
                        child: Text(
                          displayedText,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
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

// Botón de cerrar alineado a la izquierda
  Widget buildCloseButton(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top +
          1, // Alinea con el top de la barra de estado
      left: 20, // Ajusta la distancia desde el borde izquierdo
      child: SafeArea(
        child: Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 22,
              icon: Icon(
                Icons.close,
                color: Colors.white,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 15),
                            Text(
                              "¿Estás seguro de que quieres salir?",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Si sales ahora, el video se descartará y no se descargará. ¿Deseas continuar?",
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    backgroundColor: Colors.grey[300],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Cancelar"),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.pushNamed(context, '/home');
                                  },
                                  child: Text(
                                    "Continuar",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  //configuracion
  Widget buildConfiguration(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top, // Ajuste para el margen superior
      right: 20, // Ajuste para el margen derecho
      child: SafeArea(
        child: GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              // Permite que el modal ocupe más espacio si es necesario
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (BuildContext context) {
                return PrivacyAndPermissionsModal(
                  publishOptions: PublishOptions(
                    privacyOption: 'publico', // Valores iniciales
                    allowDownloads: true,
                    allowLocationTagging: false,
                    allowComments: true,
                  ),
                  onPrivacyOptionChange: (option) {
                    // Lógica para actualizar el estado de privacidad
                    print('Nueva privacidad seleccionada: $option');
                  },
                  onAllowDownloadsChange: (value) {
                    // Lógica para permitir descargas
                    print('Descargas permitidas: $value');
                  },
                  onAllowLocationTaggingChange: (value) {
                    // Lógica para permitir ubicación
                    print('Ubicación permitida: $value');
                  },
                  onAllowCommentsChange: (value) {
                    // Lógica para permitir comentarios
                    print('Comentarios permitidos: $value');
                  },
                );
              },
            );
          },
          child: Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.settings, // Ícono de configuración
              color: Colors.white,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  //metodo de icono
  Widget _buildEditOption(IconData icon, String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 28),
          SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
                color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  //disñeo de botones de publicar y siguiente
  ButtonStyle buttonStyle(Color backgroundColor, Color foregroundColor) {
    return ElevatedButton.styleFrom(
      foregroundColor: foregroundColor,
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  //metodo de texto
  void _setText(String text, TextStyle style, TextAlign align) {
    setState(() {
      _displayText = text;
      _textStyle = style;
      _textAlign = align;
    });
  }
}
