import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';
import 'package:video_trimmer/video_trimmer.dart';
import 'dart:io';
import '../../../APIS-Consumir/Deezer-API-Musica/MusicModal.dart';
import '../../../APIS-Consumir/Tenor API/StickerModal.dart';
import '../../camara/Editar_Files/configuracion/PrivacyAndPermissionsModal.dart';
import '../Posts/PostClass.dart';
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
  bool _showFullIcons =
      true; // Cambiado a true para mostrar los íconos desplegados por defecto
  double _startValue = 0.0;
  double _endValue = 20.0;
  String _displayText = '';
  bool _isLoading = false;
  TextStyle _textStyle =
      TextStyle(fontSize: 30, color: Colors.white, fontFamily: 'OpenSans');
  TextAlign _textAlign = TextAlign.center;

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

  void _toggleIcons() {
    setState(() {
      _showFullIcons = !_showFullIcons;
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

  void _downloadVideo(BuildContext context) async {
    setState(() {
      _isLoading = true; // Mostrar el indicador de carga
    });

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
    } finally {
      setState(() {
        _isLoading = false; // Ocultar el indicador de carga
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (_isLoading) {
      // Mostrar una advertencia si la descarga está en progreso
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('La descarga está en progreso. Espere a que termine.'),
          duration: Duration(seconds: 3),
        ),
      );
      return false; // Impedir que el usuario navegue hacia atrás
    }
    return true; // Permitir navegar hacia atrás si no hay descarga en progreso
  }

  Widget _buildCircularIconButton(
      IconData icon, String? label, VoidCallback onPressed) {
    bool isPlusIcon =
        icon == Icons.add_circle; // Verifica si el ícono es de "Más"

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 8.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: isPlusIcon
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3), // Sombra más sutil
                      blurRadius: 3.0,
                      spreadRadius: 1.0,
                      offset: Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: IconButton(
            icon: Icon(icon, size: 27, color: Colors.black),
            onPressed: onPressed,
          ),
        ),
        if (label != null) ...[
          SizedBox(height: 2.0), // Espacio entre ícono y texto
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold, // Etiqueta en negrita
              shadows: [
                Shadow(
                  blurRadius: 3.0, // Sombra más sutil para el texto
                  color: Colors.black.withOpacity(0.3),
                  offset: Offset(0, 2),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        body: Stack(
          children: [
            GestureDetector(
              onTap: _playPause, // Reproduce o pausa al tocar cualquier parte
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
              top: 10,
              left: 16.0,
              right: 100.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  buildCloseButton(context),
                  buildAddMusicButton(context),
                  buildConfiguration(context),
                ],
              ),
            ),
            Positioned(
              top: 120,
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
            // Ícono de pausa que aparece cuando el video está pausado
            if (!_controller.value.isPlaying)
              Center(
                child: GestureDetector(
                  onTap: _playPause, // Reproduce el video al tocar el ícono
                  child: Container(
                    width: 60, // Tamaño del fondo circular
                    height: 60, // Tamaño del fondo circular
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.4),
                      // Fondo gris transparente
                      shape: BoxShape.circle, // Forma circular
                    ),
                    child: Center(
                      child: Icon(
                        Icons.play_arrow,
                        size: 40, // Tamaño reducido del ícono
                        color: Colors.white.withOpacity(0.5), // Color del ícono
                      ),
                    ),
                  ),
                ),
              ),
            if (_isLoading) ...[
              ModalBarrier(
                  dismissible: false, color: Colors.black.withOpacity(0.5)),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Lottie.asset('lib/assets/downloadel.json',
                        width: 100, height: 100),
                    Text(
                      'Guardando...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Stack(children: [
              Positioned(
                bottom: 68.0,
                left: 0,
                right: 0,
                child: Container(
                  color: _showFullIcons
                      ? Colors.black.withOpacity(0.6)
                      : Colors.transparent,
                  padding: EdgeInsets.symmetric(vertical: 14.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (!_showFullIcons)
                        _buildCircularIconButton(
                            Icons.add_circle, 'Más', _toggleIcons),
                      if (_showFullIcons) ...[
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildCircularIconButton(
                                    Icons.remove_circle, 'Menos', _toggleIcons),
                                SizedBox(width: 8.0),
                                _buildCircularIconButton(
                                    Icons.text_fields, 'Texto', () {
                                  TextEditorHandler()
                                      .openTextEditor(context, _setText);
                                }),
                                _buildCircularIconButton(
                                    Icons.photo_library, 'Filtros', () {
                                  // Agregar funcionalidad para aplicar filtros
                                }),
                                _buildCircularIconButton(Icons.cut, 'Recortar',
                                    () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => VideoTrimScreen(
                                              videoPath: widget.videoPath)));
                                }),
                                _buildCircularIconButton(
                                    Icons.emoji_emotions, 'Emojis', () {
                                  showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    builder: (context) => StickerModal(),
                                  );
                                }),
                                _buildCircularIconButton(
                                    Icons.download, 'Descargar', () {
                                  _downloadVideo(context);
                                }),
                                // Nuevas opciones
                                _buildCircularIconButton(
                                    Icons.brightness_7, 'Brillo', () {
                                  // Funcionalidad para ajustar el brillo
                                }),
                                _buildCircularIconButton(
                                    Icons.transfer_within_a_station,
                                    'Transición', () {
                                  // Funcionalidad para aplicar transiciones
                                }),
                                _buildCircularIconButton(Icons.flare, 'Efectos',
                                    () {
                                  // Funcionalidad para aplicar efectos especiales
                                }),
                                _buildCircularIconButton(
                                    Icons.speed, 'Velocidad', () {
                                  // Funcionalidad para ajustar la velocidad
                                }),
                                _buildCircularIconButton(
                                    Icons.subtitles, 'Subtítulos', () {
                                  // Funcionalidad para agregar subtítulos
                                }),
                                _buildCircularIconButton(
                                    Icons.volume_up, 'Volumen', () {
                                  // Funcionalidad para ajustar el volumen
                                }),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
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
                          onPressed: () {
                          },
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
                          onPressed: !_isLoading
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => VideoPublishScreen(
                                        videoPath: widget.videoPath,
                                        publishOptions: PublishOptions(
                                          description: '',
                                          hashtags: [],
                                          mentions: [],
                                          privacyOption: 'publico',
                                          allowSave: true,
                                          allowComments: true,
                                          allowPromote: false,
                                          allowDownloads: true,
                                          allowLocationTagging: true,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              : null,
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
            ])
          ],
        ),
      ),
    );
  }

  //configuracion
  Widget buildConfiguration(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 1, // Ajuste para el margen superior
      right: 2, // Ajuste para el margen derecho
      child: SafeArea(
        child: GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true, // Permite que el modal ocupe más espacio si es necesario
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
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
                color: Colors.grey.shade700,
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
                Text(
                  'Añadir Música',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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

// Botón de cerrar alineado a la izquierda
  Widget buildCloseButton(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top +
          1, // Alinea con el top de la barra de estado
      left: 20, // Ajusta la distancia desde el borde izquierdo
      child: SafeArea(
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
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
}
