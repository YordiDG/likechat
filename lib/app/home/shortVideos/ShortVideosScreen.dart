import 'package:LikeChat/app/home/shortVideos/searchRapida/SearchScreen.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:volume_controller/volume_controller.dart';
import '../../APIS-Consumir/service/PexelsService.dart';
import '../../Globales/estadoDark-White/DarkModeProvider.dart';
import '../../camera/UserAvatar.dart';
import '../camara/VideoCaptureScreen.dart';
import 'LikeButton.dart';
import 'Posts/PostClass.dart';
import 'PreviewVideo/PublicarVideo/VideoPublishScreen.dart';
import 'PreviewVideo/VideoPreviewScreen.dart';
import 'package:vibration/vibration.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class ShortVideosScreen extends StatefulWidget {
  @override
  _ShortVideosScreenState createState() => _ShortVideosScreenState();
}

class _ShortVideosScreenState extends State<ShortVideosScreen> {
  final List<dynamic> _videos = [];
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;
  int _likes = 0;
  int _comments = 0;
  double _volumeListenerValue = 0;
  double _setVolumeValue = 0;
  int _videoDuration = 0;
  int _currentIndex = 0;
  int _selectedIndex = 0;
  bool _isLiked = false;
  bool _isPlaying = true;
  bool _isVideoPaused = false;
  bool _isSnippetsTab = true;
  bool _floatingActionButtonVisible = false;
  bool _isSwitched = false;

  String? _videoPath;
  TextEditingController _descriptionController = TextEditingController();

  PageController _pageController = PageController();

  //de video api
  final PexelsService _pexelsService = PexelsService();
  late Future<List<dynamic>> _fetchVideosFuture;
  List<String> _videoUrls = []; // Guarda las URLs de los videos


  @override
  void initState() {
    super.initState();
    if (_videos.isNotEmpty) {
      _initializeVideoPlayer(_videos[_currentIndex]);
      _updateFloatingActionButtonVisibility();
    }

    // Inicializar el controlador de la página con el índice inicial
    _pageController = PageController(initialPage: _selectedIndex);

    VolumeController().listener((volume) {
      setState(() => _volumeListenerValue = volume);
    });

    VolumeController().getVolume().then((volume) => _setVolumeValue = volume);

    // Inicializar el primer video si hay videos disponibles
    if (_videos.isNotEmpty) {
      _initializeVideoPlayer(_videos[_currentIndex]);
    }

    _fetchVideosFuture = fetchAndLoadVideos();
  }

  void _initializeVideoPlayer(dynamic video) {
    if (_controller != null) {
      _controller!.dispose();
    }

    if (video is String) {
      _controller = VideoPlayerController.network(video);
    } else if (video is File) {
      _controller = VideoPlayerController.file(video);
    }

    _initializeVideoPlayerFuture = _controller!.initialize().then((_) {
      setState(() {
        _videoDuration = _controller!.value.duration.inSeconds;
        _controller!.setLooping(true);

        // Reproducir automáticamente si estamos en la pestaña de 'Snippets'
        if (_isSnippetsTab && !_isVideoPaused) {
          _controller!.play();
        } else {
          _controller!
              .pause(); // Asegurar que el video se pausa inicialmente si no está en la pestaña 'Snippets'
        }
      });
    });

    _controller!.addListener(() {
      setState(() {
        _videoDuration = _controller!.value.duration.inSeconds;
      });
    });
  }

  Future<List<String>> fetchAndLoadVideos() async {
    final videos = await PexelsService().fetchVideos();

    // Extrae las URLs de los videos, asegurando que el tipo sea correcto
    _videoUrls = videos.map<String>((video) {
      // Comprueba si 'video_files' tiene al menos un elemento antes de acceder
      if (video['video_files'] != null && video['video_files'].isNotEmpty) {
        return video['video_files'][0]['link']; // Cambia el índice si quieres una calidad diferente
      }
      // Si no hay videos, devuelve una cadena vacía o maneja el error según lo necesites
      return '';
    }).where((url) => url.isNotEmpty).toList(); // Filtra las cadenas vacías

    return _videoUrls; // Devuelve la lista de URLs
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final backgroundColor = darkModeProvider.backgroundColor;

    // Función para determinar el texto a mostrar según el ancho
    String getResponsiveText(String fullText, double width) {
      if (width < 320) return '...';
      if (width < 380) return fullText.substring(0, 3) + '...';
      return fullText;
    }

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = MediaQuery.of(context).size.width;
            final iconSize = screenWidth < 360 ? 22.0 : 25.0;
            final titleFontSize = screenWidth < 360 ? 12.0 : 14.0;
            final appBarHeight = screenWidth < 360 ? 50.0 : 60.0;
            final indicatorWidth = screenWidth * 0.13;
            final notificationSize = screenWidth < 360 ? 22.0 : 26.0;
            final badgeSize = screenWidth < 360 ? 16.0 : 18.0;

            return AppBar(
              backgroundColor: backgroundColor,
              elevation: 0,
              toolbarHeight: appBarHeight,
              leading: Padding(
                padding: EdgeInsets.only(left: screenWidth * 0.03),
                child: IconButton(
                  icon: Icon(Icons.menu_sharp, color: iconColor, size: iconSize),
                  onPressed: () => _showOptionsModal(context),
                ),
              ),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Botón Fragmentos
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(0,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            getResponsiveText('Snippets', screenWidth),
                            style: TextStyle(
                              color: _selectedIndex == 0
                                  ? (isDarkMode ? Colors.white : Colors.black)
                                  : Colors.grey,
                              fontSize: titleFontSize,
                              fontWeight: _selectedIndex == 0
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          Container(
                            height: 3.0,
                            width: indicatorWidth,
                            color: _selectedIndex == 0 ? Colors.cyan : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Botón Publicaciones
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        _pageController.animateToPage(1,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            getResponsiveText('Posts', screenWidth),
                            style: TextStyle(
                              color: _selectedIndex == 1
                                  ? (isDarkMode ? Colors.white : Colors.black)
                                  : Colors.grey,
                              fontSize: titleFontSize,
                              fontWeight: _selectedIndex == 1
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Container(
                            height: 3.0,
                            width: indicatorWidth,
                            color: _selectedIndex == 1 ? Colors.cyan : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.01),
                  child: IconButton(
                    icon: Icon(Icons.search, color: iconColor, size: iconSize),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SearchScreen()),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(right: screenWidth * 0.02),
                  child: IconButton(
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          Icons.notifications,
                          color: iconColor,
                          size: notificationSize,
                        ),
                        Positioned(
                          right: -4,
                          top: -5,
                          child: Container(
                            padding: EdgeInsets.all(2),
                            constraints: BoxConstraints(
                              minWidth: badgeSize,
                              minHeight: badgeSize,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 0.7,
                              ),
                            ),
                            child: Center(
                              child: FittedBox(
                                child: Text(
                                  '5',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth < 360 ? 9 : 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () => Navigator.pushNamed(context, '/avisos'),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          _disposeVideoPlayer();
          setState(() {
            _selectedIndex = index;
            _currentIndex = index;
            _initializeVideoPlayer(_videoUrls[_currentIndex]);
            _updateFloatingActionButtonVisibility();
          });
        },
        children: [
          _buildSnippetsPage(),
          PostClass(),
        ],
      ),
      floatingActionButton:
      _floatingActionButtonVisible ? _buildFloatingActionButton() : null,
    );
  }

// Método que muestra el modal del app bar
  void _showOptionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              color: Color(0xFF121212), // Gris oscuro para el fondo principal
              child: Wrap(
                children: <Widget>[
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 13.0), // Espaciado superior
                      width: 40.0,
                      height: 4.0,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 28.0),
                  // Encabezado con fondo negro
                  Container(
                    color: Color(0xFF1A1A1A), // Fondo negro para el encabezado
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'Opciones',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 11.0),
                  // Opciones del menú
                  _buildListTile(
                    context,
                    Icons.camera_alt,
                    'Crear Publicación',
                    'Publica un nuevo contenido',
                    Colors.cyan,
                        () {
                      Navigator.pop(context);
                      _navigateToVideoScreen(context);
                    },
                  ),
                  _buildListTile(
                    context,
                    Icons.video_call,
                    'Crear Video',
                    'Graba un nuevo video',
                    Colors.green,
                        () {
                      Navigator.pop(context);
                      _navigateToVideoScreen(context);
                    },
                  ),
                  _buildLiveTile(context),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Divider(color: Colors.white54),
                  ),
                  SwitchListTile(
                    value: _isSwitched,
                    onChanged: (bool value) {
                      setModalState(() {
                        _isSwitched = value;
                      });
                      _updateFloatingActionButtonVisibility();
                    },
                    title: Text(
                      'Mostrar botón flotante',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    activeColor: Colors.cyan,
                    inactiveThumbColor: Colors.grey,
                    inactiveTrackColor: Colors.grey[300],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

// Navegación a VideoScreen
  void _navigateToVideoScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => VideoCaptureScreen()),
    );
  }

// Widget para un ListTile genérico
  Widget _buildListTile(BuildContext context, IconData icon, String title,
      String subtitle, Color iconColor, VoidCallback onTap) {
    return ListTile(
      leading: CircleAvatar(
        radius: 28.0,
        backgroundColor: Colors.white.withOpacity(0.1),
        child: Icon(icon, color: iconColor, size: 23.0),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Montserrat',
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 11,
          color: Colors.white70,
          fontFamily: 'Montserrat',
        ),
      ),
      onTap: onTap,
    );
  }


// Widget para el botón de 'Transmitir en Vivo'
  Widget _buildLiveTile(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 56.0,
        height: 56.0,
        child: Stack(
          alignment: Alignment.center,
          children: [
            CircleAvatar(
              radius: 28.0,
              backgroundColor: Colors.white.withOpacity(0.1),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Icon(
                  Icons.live_tv,
                  color: Colors.red,
                  size: 25.0,
                ),
              ),
            ),
            Positioned(
              bottom: 4.0,
              child: Text(
                'LIVE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10.0,
                ),
              ),
            ),
          ],
        ),
      ),
      title: Text(
        'Transmitir en Vivo',
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Montserrat',
        ),
      ),
      subtitle: Text(
        'Trasmite en directo permite e interactua con tu audiencia',
        style: TextStyle(
          fontSize: 11,
          color: Colors.white70,
          fontFamily: 'Montserrat',
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        showCreateDialog(context, 'Opción Adicional');
      },
    );
  }

  void _updateFloatingActionButtonVisibility() {
    setState(() {
      _floatingActionButtonVisible = _isSwitched && _selectedIndex == 0;
    });
  }

  void showCreateDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(
              'Aquí puedes agregar más contenido o configuraciones para ' +
                  title),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }


  Widget _buildSnippetsPage() {
    return _videos.isEmpty
        ? _buildPlaceholder()
        : RefreshIndicator(
            onRefresh: _handleRefresh,
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                  _initializeVideoPlayer(_videos[_currentIndex]);
                  _isSnippetsTab = true; // Ajustar según la pestaña actual

                  // Actualizar visibilidad del FAB
                  _floatingActionButtonVisible =
                      _isSnippetsTab && _videos.isNotEmpty;

                  if (!_isSnippetsTab) {
                    _controller!.pause();
                    setState(() {
                      _isPlaying = false;
                      _isVideoPaused = true; // Mostrar el ícono de pausa
                    });
                  } else {
                    _controller!.play();
                    setState(() {
                      _isPlaying = true;
                      _isVideoPaused = false; // Ocultar el ícono de pausa
                    });
                  }
                });
              },

              /* return GestureDetector(
                  onTap: _toggleVideoPlayback,
                  child: Stack(
                    children: [
                      Center(
                        child: AspectRatio(
                          aspectRatio: _controller?.value.aspectRatio ?? 16 / 9, // Proporcionar un valor por defecto
                          child: _controller != null && _controller!.value.isInitialized
                              ? VideoPlayer(_controller!)
                              : CircularProgressIndicator(), // Mostrar indicador de carga mientras se inicializa
                        ),
                      ),
                      _buildIcons(),
                      _avatarPhoto(context),
                      _pauseVideo(context),
                    ],
                  ),
                );
              */
              itemCount: _videos.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: _toggleVideoPlayback,
                  child: Stack(
                    children: [
                      Center(
                        child: AspectRatio(
                          aspectRatio: _controller?.value.aspectRatio ?? 16 / 9,
                          child: _controller != null && _controller!.value.isInitialized
                              ? VideoPlayer(_controller!)
                              : CircularProgressIndicator(), // Mostrar indicador de carga mientras se inicializa
                        ),
                      ),
                      _buildIcons(),
                      _avatarPhoto(context),
                      _pauseVideo(context),
                    ],
                  ),
                );
              },
            ),
          );
  }

  void _disposeVideoPlayer() {
    if (_controller != null) {
      _controller!.dispose();
      _controller = null; // Asegúrate de liberar el controlador
    }
  }

  Widget _buildFloatingActionButton() {
    if (!_floatingActionButtonVisible) {
      return SizedBox(); // Ocultar el FAB si no es visible
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 28.0, right: 18.0),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 5,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: FloatingActionButton(
            backgroundColor: Colors.cyan,
            onPressed: () {
              _showVideoOptions(context);
            },
            child: Icon(
              Icons.video_camera_back,
              size: 33,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _pauseVideo(BuildContext context) {
    return Center(
      child: Visibility(
        visible: _isVideoPaused, // Mostrar cuando el video está pausado
        child: IconButton(
          icon: Icon(
            _isPlaying ? Icons.pause_circle : Icons.play_circle,
            size: 80,
            color: Colors.grey[400]?.withOpacity(0.3), // Icono con opacidad
          ),
          onPressed: () {
            _toggleVideoPlayback();
          },
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library,
            color: Colors.white,
            size: 80.0,
          ),
          SizedBox(height: 20),
          Text(
            'No videos available!',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _avatarPhoto(BuildContext context) {
    return Positioned(
      bottom: 20.0,
      left: 20.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              UserAvatar(
                isOwner: true, // O false, según corresponda
                addFriendCallback: (List<String> friendsList) {
                  // Lógica para agregar amigos si no eres el propietario del video
                },
                size: 25.0, // Ajusta el tamaño del avatar
              ),
              SizedBox(width: 8.0),
              Text(
                'Yordi Gonzales',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: 8.0),
              ElevatedButton(
                onPressed: () {
                  // Implementar lógica para seguir al usuario
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                  // Color del texto
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(10.0), // Bordes redondeados
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                  // Tamaño más delgado
                  textStyle: TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.bold), // Tamaño de la fuente
                ),
                child: Text('Follow'),
              ),
            ],
          ),
          SizedBox(height: 4),
          Text(
            'User description or status',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcons() {
    return Positioned(
      bottom: 140.0, // Ajusta el valor según sea necesario
      right: 19.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          LikeButton(
            iconPath: 'lib/assets/favorite.svg',
            isFilled: true,
            onLiked: (bool isLiked, int likes) {
              setState(() {
                _isLiked = isLiked; // Actualiza el estado de _isLiked
                _likes = likes; // Actualiza el contador de likes
              });
            },
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2), // Color de la sombra
                  spreadRadius: 1, // Extensión de la sombra
                  blurRadius: 28, // Difuminado de la sombra
                  offset: Offset(0, 2), // Desplazamiento de la sombra
                ),
              ],
            ),
            iconSize: 30,
          ),
          _buildIconButton(
            iconPath: 'lib/assets/mesage.svg',
            onPressed: () {},
            isFilled: true, // Rellenar el icono de blanco
            iconSize: 40.0, // Tamaño del icono
          ),
          Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3), // Color de la sombra
                  spreadRadius: 1, // Extensión de la sombra
                  blurRadius: 8, // Difuminado de la sombra
                  offset: Offset(0, 2), // Desplazamiento de la sombra
                ),
              ],
            ),
            child: Text(
              '$_comments',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.3),
                    offset: Offset(0, 2),
                    blurRadius: 3,
                  ),
                ],
              ),
            ),
          ),
          _buildIconButton(
            iconPath: 'lib/assets/shared.svg',
            onPressed: () {
              // Acción al presionar el botón de "Compartir"
            },
            isFilled: true,
            iconSize: 40.0, // Tamaño del icono
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required String iconPath,
    required VoidCallback onPressed,
    bool isFilled = false,
    double iconSize = 34.0,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 0.0),
      // Ajusta el margen inferior entre íconos
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Color de la sombra
            spreadRadius: 1, // Extensión de la sombra
            blurRadius: 8, // Difuminado de la sombra
            offset: Offset(0, 2), // Desplazamiento de la sombra
          ),
        ],
      ),
      child: IconButton(
        icon: SvgPicture.asset(
          iconPath,
          width: iconSize,
          // Usa iconSize en lugar de un valor fijo para width
          height: iconSize,
          // Usa iconSize en lugar de un valor fijo para height
          color: isFilled
              ? Colors.white
              : null, // Color del interior relleno si es necesario
        ),
        onPressed: onPressed,
        iconSize: iconSize, // Usa iconSize para el tamaño del icono
      ),
    );
  }

  Future<void> _handleRefresh() async {
    // Simular carga de datos o actualizar la lista de videos
    // Aquí deberías tener lógica para verificar conectividad antes de actualizar
    await _checkInternetConnectivity(context);

    await Future.delayed(
        Duration(seconds: 2)); // Simula una carga de 2 segundos

    if (_videos.isNotEmpty) {
      setState(() {
        _currentIndex = _videos.length - 1;
        _initializeVideoPlayer(_videos[_currentIndex]);
      });
    }
  }

  Future<void> _checkInternetConnectivity(BuildContext context) async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No hay conexión a Internet',
            textAlign: TextAlign.center, // Alineación centrada del texto
          ),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          // Hace que el SnackBar flote en la parte superior
          margin: EdgeInsets.all(10), // Margen para el SnackBar
        ),
      );
      throw 'No hay conexión a Internet';
    }
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: Duration(seconds: 20),
    );
    if (pickedFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPreviewScreen(videoPath: pickedFile.path),
        ),
      );
    }
  }

  // Método para grabar un nuevo video
  void _recordVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: Duration(seconds: 20),
    );
    if (pickedFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VideoPreviewScreen(videoPath: pickedFile.path),
        ),
      );
    }
  }

  void _showVideoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: Color(0xFF121212), // Gris oscuro para el fondo principal
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
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
            child: SingleChildScrollView(
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
                  // Título con fondo más oscuro
                  Container(
                    color: Color(0xFF1A1A1A),
                    // Gris más oscuro para el fondo del título
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'Opciones de Video',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 11.0),
                  // Opciones de íconos
                  ListTile(
                    leading: CircleAvatar(
                      radius: 28.0,
                      // Tamaño del círculo
                      backgroundColor: Colors.white.withOpacity(0.1),
                      // Fondo más claro
                      child: FaIcon(
                        FontAwesomeIcons.video,
                        color: Colors.red, // Ícono blanco
                        size: 20.0, // Tamaño del ícono
                      ),
                    ),
                    title: Text(
                      'Grabar Video',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    subtitle: Text(
                      'Captura un nuevo video',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                          fontFamily: 'Montserrat'),
                    ),
                    onTap: () {
                      if (Vibration.hasVibrator() != null) {
                        Vibration.vibrate(duration: 50);
                      }
                      Navigator.pop(context);
                      _recordVideo();
                    },
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      radius: 28.0,
                      // Tamaño del círculo
                      backgroundColor: Colors.white.withOpacity(0.1),
                      // Fondo más claro
                      child: Icon(
                        FontAwesomeIcons.photoVideo,
                        color: Colors.cyan, // Ícono blanco
                        size: 20.0, // Tamaño del ícono
                      ),
                    ),
                    title: Text(
                      'Seleccionar de la Galería',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    subtitle: Text(
                      'Elige un video existente',
                      style: TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                          fontFamily: 'Montserrat'),
                    ),
                    onTap: () {
                      if (Vibration.hasVibrator() != null) {
                        Vibration.vibrate(duration: 50);
                      }
                      Navigator.pop(context);
                      _pickVideo();
                    },
                  ),
                  ListTile(
                    leading: CircleAvatar(
                      radius: 28.0,
                      // Tamaño del círculo
                      backgroundColor: Colors.white.withOpacity(0.1),
                      // Fondo más claro
                      child: FaIcon(
                        FontAwesomeIcons.image,
                        color: Colors.green, // Ícono blanco
                        size: 20.0, // Tamaño del ícono
                      ),
                    ),
                    title: Text(
                      'Seleccionar Imagen',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Montserrat',
                      ),
                    ),
                    subtitle: Text(
                      'Elige una imagen existente',
                      style: TextStyle(
                          color: Colors.white70,
                          fontFamily: 'Montserrat',
                          fontSize: 13),
                    ),
                    onTap: () {
                      if (Vibration.hasVibrator() != null) {
                        Vibration.vibrate(duration: 50);
                      }
                      Navigator.pop(context);
                      _pickImage();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Método para pausar/activar la reproducción del video
  Future<void> _toggleVideoPlayback() async {
    if (_controller!.value.isPlaying) {
      await _controller!.pause();
      setState(() {
        _isPlaying = false;
        _isVideoPaused = true; // Mostrar el ícono de pausa
      });
    } else {
      await _controller!.play();
      setState(() {
        _isPlaying = true;
        _isVideoPaused = false; // Ocultar el ícono de pausa
      });
    }
  }

  // Método para elegir una imagen desde la galería
  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final image = img.decodeImage(bytes);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _controller?.dispose();
    super.dispose();
  }
}
