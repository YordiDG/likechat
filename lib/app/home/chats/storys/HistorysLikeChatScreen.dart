import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui' as ui;
import 'dart:ui';
import '../../../Globales/estadoDark-White/DarkModeProvider.dart';
import 'PreviewHistory.dart';
import 'detail/FullScreenStoryViewer.dart';
import 'package:provider/provider.dart';


class HistorysLikeChatScreen extends StatefulWidget {
  @override
  _LikeChatScreenState createState() => _LikeChatScreenState();
}

class _LikeChatScreenState extends State<HistorysLikeChatScreen> {
  List<String> _stories = [];
  int _currentIndex = 0;
  Timer? _timer;
  final double _storySize = 77.0;
  final double _activeStorySize = 90.0;

  File? _image;
  File? _video;

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
      color: backgroundColor,
      child: Padding(
        padding: EdgeInsets.only(top: 30.0),
        child: Container(
          height: 140,
          color: backgroundColor,
          child: Stack(
            children: [
              buildHeaderRow(),
              buildStoryContainer(),
            ],
          ),
        ),
      ),
    );
  }

  //header de estados:
  Widget buildHeaderRow() {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final iconColor = darkModeProvider.iconColor;

    return Row(
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
            showOptionsDialog(context);
          },
        ),
      ],
    );
  }

  //contruye la iamgen:
  Widget buildStoryContainer() {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final iconColor = darkModeProvider.iconColor;

    return Container(
      margin: EdgeInsets.only(top: 43.0),
      height: _activeStorySize + 1,
      width: 500,
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
                              image: AssetImage('lib/assets/placeholder_user.jpg'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 1.0,
                        right: 1.0,
                        child: Container(
                          width: 29.0,
                          height: 29.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDarkMode ? Colors.cyan : Colors.cyan,
                            border: Border.all(color: isDarkMode ? Colors.black : Colors.white, width: 2.0),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.3),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              Icons.add,
                              size: 24,
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
            if (_stories.isNotEmpty) buildActiveStory(),
          ],
        ),
      ),
    );
  }

  //contrye la histori activa
  Widget buildActiveStory() {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final iconColor = darkModeProvider.iconColor;

    return GestureDetector(
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
        width: _activeStorySize + 2.0,
        height: _activeStorySize + 2.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.cyan,
            width: 2.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(2.5),
          child: Stack(
            children: [
              ClipOval(
                child: Container(
                  width: _activeStorySize - 6.0,
                  height: _activeStorySize - 6.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: FileImage(File(_stories[_currentIndex])),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 8.0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.black87 : Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4.0,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Tu historia',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontSize: 12.0,
                      fontWeight: FontWeight.w600,
                    ),
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

  void showOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Opciones'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.message),
                title: Text('Enviar mensaje'),
                onTap: () {
                  // Acción para enviar mensaje
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.call),
                title: Text('Hacer llamada'),
                onTap: () {
                  // Acción para hacer llamada
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo),
                title: Text('Enviar foto'),
                onTap: () {
                  // Acción para enviar foto
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.video_call),
                title: Text('Iniciar videollamada'),
                onTap: () {
                  // Acción para iniciar videollamada
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.copy),
                title: Text('Copiar texto'),
                onTap: () {
                  // Acción para copiar texto
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.report),
                title: Text('Reportar'),
                onTap: () {
                  // Acción para reportar
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.block),
                title: Text('Bloquear'),
                onTap: () {
                  // Acción para bloquear
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.settings),
                title: Text('Configuración'),
                onTap: () {
                  // Acción para configuración
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
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

  Future<void> _addStory() async {
    _showMediaOptions();
  }

  void _showMediaOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Seleccionar Archivo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.image, size: 27, color: Colors.cyan),
                title: Text('Seleccionar Imagen'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
              ListTile(
                leading: Icon(Icons.video_library,size: 27, color: Colors.cyan),
                title: Text('Seleccionar Video'),
                onTap: () {
                  Navigator.pop(context);
                  _pickVideo();
                },
              ),
              ListTile(
                leading: Icon(Icons.videocam, size: 27, color: Colors.cyan),
                title: Text('Grabar Video'),
                onTap: () {
                  Navigator.pop(context);
                  _captureVideo();
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt, size: 27, color: Colors.cyan),
                title: Text('Capturar Imagen'),
                onTap: () {
                  Navigator.pop(context);
                  _captureImage();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickVideo() async {
    final pickedFile = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _video = File(pickedFile.path);
      });
      // Aquí puedes manejar el archivo de video seleccionado
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('No se seleccionó ningún video.'),
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
