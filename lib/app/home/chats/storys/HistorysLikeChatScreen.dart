import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

  //Global de menu de headder
  final GlobalKey _menuKey = GlobalKey();

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
      color:  backgroundColor,
      child: Padding(
        padding: EdgeInsets.only(top: 30.0),
        child: Container(
          height: 150,
          color: backgroundColor ,
          child: Stack(
            children: [
              buildHeaderRow(),
              buildStoryContainer(),
              Divider(
                color: isDarkMode ? Colors.grey.shade200 : Colors.grey.shade700,
                thickness: 0.1,
                height: 0.1,
              ),
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
    final buttonColor = isDarkMode ? Colors.white : const Color(0xFF2C3E50);
    final backgroundColor = isDarkMode ? Colors.grey.shade900.withOpacity(0.2) : Colors.grey.withOpacity(0.1);

    final double circleSize = 40.0;

    return Row(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 30.0),
          child: Text(
            'LikeChat',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontSize: 17.0,
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Spacer(),
        GestureDetector(
          onTap: () {},
          child: Container(
            width: circleSize,
            height: circleSize,
            margin: EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor,
            ),
            child: Icon(
              Icons.search,
              color: buttonColor,
              size: circleSize * 0.6,
            ),
          ),
        ),
        GestureDetector(
          onTap: _addStory,
          child: Container(
            width: circleSize,
            height: circleSize,
            margin: EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor,
            ),
            child: Icon(
              Icons.add_circle_outline,
              color: buttonColor,
              size: circleSize * 0.6,
            ),
          ),
        ),
        GestureDetector(
          key: _menuKey,
          onTap: () {
            final RenderBox renderBox = _menuKey.currentContext!.findRenderObject() as RenderBox;
            final Offset position = renderBox.localToGlobal(Offset.zero);
            final double yOffset = position.dy + renderBox.size.height;

            showMenu(
              context: context,
              position: RelativeRect.fromLTRB(
                position.dx,
                yOffset,
                position.dx + renderBox.size.width,
                yOffset + 200, // Altura estimada del menú
              ),
              items: [
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(Icons.settings_rounded, color: buttonColor, size: 20),
                    title: Text(
                      'Configuración',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  onTap: () {
                    Future.delayed(Duration.zero, () {
                      showChatListOptionsDialog(context);
                    });
                  },
                ),
                PopupMenuItem(
                  child: ListTile(
                    leading: Icon(
                      isDarkMode ? Icons.light_mode : Icons.dark_mode,
                      color: buttonColor,
                      size: 20,
                    ),
                    title: Text(
                      isDarkMode ? 'Modo claro' : 'Modo oscuro',
                      style: TextStyle( fontWeight: FontWeight.w500),
                    ),
                  ),
                  onTap: () {
                    Future.delayed(Duration.zero, () {
                      darkModeProvider.toggleDarkMode();
                    });
                  },
                ),
              ],
            );
          },
          child: Container(
            width: circleSize,
            height: circleSize,
            margin: EdgeInsets.symmetric(horizontal: 4.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: backgroundColor,
            ),
            child: Icon(
              Icons.menu,
              color: buttonColor,
              size: circleSize * 0.6,
            ),
          ),
        ),
      ],
    );
  }

  // Widget para el Avatar
  Widget buildAvatarStory(double avatarSize, bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.only(left: 17.0, right: 5.0),
      child: Column(
        children: [
          GestureDetector(
            onTap: _addStory,
            child: Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey[300],
              ),
              child: Stack(
                children: [
                  Center(
                    child: _image != null
                        ? Container(
                      width: avatarSize - 4,
                      height: avatarSize - 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: FileImage(File(_image!.path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                        : Container(
                      width: avatarSize - 2,
                      height: avatarSize - 2,
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
                      width: 27.0,
                      height: 27.0,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.cyan,
                        border: Border.all(
                            color: isDarkMode ? Colors.black : Colors.white,
                            width: 2.0
                        ),
                      ),
                      child: Icon(
                        Icons.add,
                        size: 22,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

// Widget para la Historia Compartida
  Widget buildSharedStory(double storyImageSize, bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.only(right: 5.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
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
              width: storyImageSize,
              height: storyImageSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF9B30FF),
                    Color(0xFF00BFFF),
                    Color(0xFF00FFFF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.all(2.8),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isDarkMode ? Colors.black : Colors.white,
                    width: 2.0,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: FileImage(File(_stories[_currentIndex])),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 1),
          Text(
            'Tu Historia',
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontSize: 10.0,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

// Widget principal que contiene ambos
  Widget buildStoryContainer() {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;

    // Tamaños ajustados
    final double avatarSize = 77.0;
    final double storyImageSize = 77.0;
    final double storyContainerHeight = 110.0;

    return Container(
      margin: EdgeInsets.only(top: 43.0),
      height: storyContainerHeight,
      width: 500,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Alinea los elementos al inicio
          children: [
            buildAvatarStory(avatarSize, isDarkMode),
            SizedBox(width: 8),
            if (_stories.isNotEmpty)
              buildSharedStory(storyImageSize, isDarkMode),
          ],
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

  void showChatListOptionsDialog(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: isDark ? Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(28),
              topRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: EdgeInsets.all(24),
                child: Row(
                  children: [
                    Text(
                      'Gestionar chats',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.close_rounded,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      _buildOption(
                        context,
                        icon: Icons.archive_rounded,
                        label: 'Chats archivados',
                        subtitle: '3 conversaciones',
                        color: Colors.blue.shade400,
                        onTap: () => Navigator.pop(context),
                        badgeCount: 3,
                      ),
                      _buildOption(
                        context,
                        icon: Icons.block_rounded,
                        label: 'Contactos bloqueados',
                        subtitle: '2 contactos',
                        color: Colors.red.shade400,
                        onTap: () => Navigator.pop(context),
                        badgeCount: 2,
                      ),
                      _buildOption(
                        context,
                        icon: Icons.notifications_off_rounded,
                        label: 'Chats silenciados',
                        subtitle: '5 conversaciones',
                        color: Colors.orange.shade400,
                        onTap: () => Navigator.pop(context),
                        badgeCount: 5,
                      ),
                      _buildOption(
                        context,
                        icon: Icons.star_rounded,
                        label: 'Mensajes destacados',
                        subtitle: '8 mensajes',
                        color: Colors.amber.shade400,
                        onTap: () => Navigator.pop(context),
                        badgeCount: 8,
                      ),
                      _buildOption(
                        context,
                        icon: Icons.delete_outline_rounded,
                        label: 'Papelera',
                        subtitle: 'Chats eliminados',
                        color: Colors.grey.shade400,
                        onTap: () => Navigator.pop(context),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Divider(height: 40),
                      ),
                      _buildOption(
                        context,
                        icon: Icons.settings_rounded,
                        label: 'Configuración de chats',
                        color: isDark ? Colors.white70 : Colors.grey.shade700,
                        onTap: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOption(
      BuildContext context, {
        required IconData icon,
        required String label,
        String? subtitle,
        required Color color,
        required VoidCallback onTap,
        int? badgeCount,
      }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(isDark ? 0.2 : 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (badgeCount != null)
              Container(
                margin: EdgeInsets.only(right: 12),
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(isDark ? 0.3 : 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badgeCount.toString(),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white38 : Colors.black38,
              size: 24,
            ),
          ],
        ),
      ),
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

    if (pickedFiles != null && pickedFiles.isNotEmpty) {
      // Limitar el número de imágenes a 10
      if (pickedFiles.length > 10) {
        // Mostrar un toast de advertencia y cortar la lista a 10 imágenes
        Fluttertoast.showToast(
          msg: 'Solo se puede subir un máximo de 10 imágenes.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3, // Duración del mensaje
          backgroundColor: Colors.grey.shade800,
          textColor: Colors.white,
          fontSize: 11.0,
        );
        // Solo toma las primeras 10 imágenes
        pickedFiles = pickedFiles.take(10).toList();
      }

      // Crear una lista para mantener las imágenes seleccionadas
      List<File> imagesToPreview = pickedFiles.map((file) => File(file.path)).toList();

      if (imagesToPreview.isNotEmpty) {
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
        // Si no hay imágenes válidas para previsualizar
        Fluttertoast.showToast(
          msg: 'No hay imágenes válidas para previsualizar.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 3, // Duración del mensaje
          backgroundColor: Colors.grey.shade800,
          textColor: Colors.white,
          fontSize: 11.0,
        );
      }
    } else {
      Fluttertoast.showToast(
        msg: 'No se seleccionaron imágenes.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 3, // Duración del mensaje
        backgroundColor: Colors.grey.shade800,
        textColor: Colors.white,
        fontSize: 11.0,
      );
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
                width: 40,
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
                  fontSize: 14,
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
