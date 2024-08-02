import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui' as ui;
import 'dart:ui';
import '../../../estadoDark-White/DarkModeProvider.dart';
import 'PreviewHistory.dart';
import 'detail/FullScreenStoryViewer.dart';
import 'package:provider/provider.dart';


class LikeChatScreen extends StatefulWidget {
  @override
  _LikeChatScreenState createState() => _LikeChatScreenState();
}

class _LikeChatScreenState extends State<LikeChatScreen> {
  List<String> _stories = [];
  int _currentIndex = 0;
  Timer? _timer;
  final double _storySize = 75.0;
  final double _activeStorySize = 90.0;

  File? _image;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final backgroundColor = darkModeProvider.backgroundColor;

    return Container(
      color: Colors.black.withOpacity(0.2),
      child: Padding(
        padding: EdgeInsets.only(top: 30.0),
        child: Container(
          height: 130,
          color: backgroundColor,
          child: Stack(
            children: [
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: 30.0),
                    child: Text(
                      'LikeChat',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.cyan,
                        fontSize: 26.0,
                        fontWeight: FontWeight.bold,

                      ),
                    ),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(Icons.search, color: iconColor, size: 28),
                    onPressed: () {
                      // Acción de búsqueda
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.add, color: iconColor, size: 28),
                    onPressed: _addStory,
                  ),
                  IconButton(
                    icon: Icon(Icons.more_vert, color: iconColor, size: 28),
                    onPressed: () {
                      // Otras funcionalidades
                    },
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.only(top: 43.0),
                height: _activeStorySize + 1,
                width: 600,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 17.0, right: 5.0),
                        child: GestureDetector(
                          onTap: _addStory,
                          child: Container(
                            width: _storySize,
                            height: _storySize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[300],
                            ),
                            child: Stack(
                              children: [
                                Center(
                                  child: _image != null
                                      ? Container(
                                    width: _storySize,
                                    height: _storySize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: FileImage(File(_image!.path)),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  )
                                      : Container(
                                    width: _storySize,
                                    height: _storySize,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: AssetImage(
                                            'lib/assets/placeholder_user.jpg'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 1.0,
                                  right: 1.0,
                                  child: Container(
                                    width: 30.0,
                                    height: 30.0,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDarkMode ? Colors.cyan : Colors
                                          .cyan,
                                      border: Border.all(color: isDarkMode
                                          ? Colors.black
                                          : Colors.white, width: 2.0),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.add,
                                        size: 26,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      if (_stories.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            if (_stories.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FullScreenStoryViewer(
                                        stories: _stories,
                                        currentIndex: _currentIndex,
                                        onDelete: _deleteStory,
                                      ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            width: _activeStorySize + 8.0,
                            // Aumenta el ancho del contenedor para incluir el espacio de separación
                            height: _activeStorySize + 8.0,
                            // Aumenta el alto del contenedor para incluir el espacio de separación
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.cyan,
                                width: 3.0,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(4.0),
                              // Añade padding para separar el contenido del borde
                              child: Stack(
                                children: [
                                  ClipOval(
                                    child: Container(
                                      width: _activeStorySize,
                                      height: _activeStorySize,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                          image: FileImage(
                                              File(_stories[_currentIndex])),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 1.0,
                                    left: 0.0,
                                    right: 0.0,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 4.0),
                                      decoration: BoxDecoration(
                                        color: isDarkMode
                                            ? Colors.black54
                                            : Colors.black.withOpacity(0.4),
                                        // Fondo negro transparente
                                        borderRadius: BorderRadius.circular(
                                            10.0),
                                        border: Border.all(
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.white,
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Text(
                                        'Tu historia',
                                        style: TextStyle(
                                          color: Colors.white, // Texto blanco
                                          fontSize: 12.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
      Permission.storage,
    ].request();
  }

  Future<void> _captureImage() async {
    PermissionStatus cameraPermissionStatus = await Permission.camera.status;
    if (cameraPermissionStatus.isGranted) {
      final pickedFile = await ImagePicker().pickImage(
          source: ImageSource.camera);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });
        _navigateToPreview(_image! as List<File>);
      }
    } else {
      await Permission.camera.request();
      if (await Permission.camera.isGranted) {
        final pickedFile = await ImagePicker().pickImage(
            source: ImageSource.camera);

        if (pickedFile != null) {
          setState(() {
            _image = File(pickedFile.path);
          });
          _navigateToPreview(_image! as List<File>);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Se requieren permisos de cámara para capturar imágenes.'),
        ));
      }
    }
  }

  Future<void> _captureVideo() async {
    PermissionStatus cameraPermissionStatus = await Permission.camera.status;
    PermissionStatus microphonePermissionStatus = await Permission.microphone
        .status;

    if (cameraPermissionStatus.isGranted &&
        microphonePermissionStatus.isGranted) {
      final pickedFile = await ImagePicker().pickVideo(
          source: ImageSource.camera, maxDuration: Duration(seconds: 15));

      if (pickedFile != null) {
        // Aquí puedes manejar el archivo de video seleccionado
      }
    } else {
      await Permission.camera.request();
      await Permission.microphone.request();
      if (await Permission.camera.isGranted &&
          await Permission.microphone.isGranted) {
        final pickedFile = await ImagePicker().pickVideo(
            source: ImageSource.camera, maxDuration: Duration(seconds: 15));

        if (pickedFile != null) {
          // Aquí puedes manejar el archivo de video seleccionado
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
              'Se requieren permisos de cámara y micrófono para grabar videos.'),
        ));
      }
    }
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

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      // Navegar a la pantalla de previsualización
      _navigateToPreview(_image! as List<File>);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('No se seleccionó ninguna imagen.'),
      ));
    }
  }

  Future<void> _addStory() async {
    final picker = ImagePicker();
    var pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      // Limitar el número de imágenes a 10
      if (pickedFiles.length > 10) {
        // Mostrar mensaje de advertencia y cortar la lista a 10 imágenes
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Solo se puede subir un máximo de 10 imágenes.',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating, // Hacer que el snackbar flote
          duration: Duration(seconds: 3), // Duración del mensaje
          margin: EdgeInsets.all(16.0), // Margen para el snackbar
        ));
        // Solo toma las primeras 10 imágenes
        pickedFiles = pickedFiles.take(10).toList();
      }

      // Crear una lista para mantener las imágenes seleccionadas
      List<File> imagesToPreview = pickedFiles.map((file) => File(file.path)).toList();

      // Mostrar la pantalla de previsualización para todas las imágenes
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewHistory(
            images: imagesToPreview, // Pasar la lista de imágenes
            onPostStory: _postStory,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'No se seleccionaron imágenes.',
          style: TextStyle(color: Colors.white), // Color del texto
        ),
        backgroundColor: Color.fromRGBO(0, 255, 255, 0.5), // Fondo cian con opacidad
        behavior: SnackBarBehavior.floating, // Hacer que el snackbar flote
        duration: Duration(seconds: 3), // Duración del mensaje
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Bordes redondeados
          side: BorderSide(color: Colors.cyan, width: 2.0), // Borde cian
        ),
        margin: EdgeInsets.all(16.0), // Margen para el snackbar
      ));
    }
  }

  void _navigateToPreview(List<File> images) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PreviewHistory(
          images: images, // Pasar la lista de imágenes
          onPostStory: _postStory,
        ),
      ),
    );
  }

  void _deleteStory(int index) {
    setState(() {
      _stories.removeAt(index);
    });
  }


  void _postStory(File image) {
    setState(() {
      _stories.add(image.path);
    });
    // Aquí puedes añadir el código para postear la historia en tu backend
  }

}





