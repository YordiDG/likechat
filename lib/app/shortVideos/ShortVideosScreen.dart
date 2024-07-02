import 'package:LikeChat/app/shortVideos/searchRapida/SearchScreen.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:volume_controller/volume_controller.dart';

import '../camera/UserAvatar.dart';
import 'Comments/CommentSection.dart';
import 'LikeButton.dart';
import 'Posts/PostClass.dart';

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
  bool _floatingActionButtonVisible = true;

  PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    if (_videos.isNotEmpty) {
      _initializeVideoPlayer(_videos[_currentIndex]);
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
          _controller!.pause(); // Asegurar que el video se pausa inicialmente si no está en la pestaña 'Snippets'
        }
      });
    });

    _controller!.addListener(() {
      setState(() {
        _videoDuration = _controller!.value.duration.inSeconds;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                _pageController.animateToPage(0,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut);
              },
              child: Text(
                'Snippets',
                style: TextStyle(
                  color: _selectedIndex == 0 ? Colors.white : Colors.grey,
                  fontSize: 18,
                  fontWeight:
                  _selectedIndex == 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _pageController.animateToPage(1,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut);
              },
              child: Text(
                'Posts',
                style: TextStyle(
                  color: _selectedIndex == 1 ? Colors.white : Colors.grey,
                  fontSize: 18,
                  fontWeight:
                  _selectedIndex == 1 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white, size: 30),
            onPressed: () {
              // Navigate to search screen
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchScreen()),
              );
            },
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
            _floatingActionButtonVisible = index == 0; // Mostrar FAB solo en Snippets
          });
        },
        children: [
          _buildSnippetsPage(),
          PostClass(), // Mostrar PostClass en la segunda página
        ],
      ),
      floatingActionButton: _floatingActionButtonVisible
          ? _buildFloatingActionButton()
          : null,
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
            _isSnippetsTab = index == 0; // Ajustar según la pestaña actual

            // Actualizar visibilidad del FAB
            _floatingActionButtonVisible = _isSnippetsTab && _videos.isNotEmpty;

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
        itemCount: _videos.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: _toggleVideoPlayback,
            child: Stack(
              children: [
                Center(
                  child: AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
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

  Widget _buildFloatingActionButton() {
    if (!_floatingActionButtonVisible) {
      return SizedBox(); // Ocultar el FAB si no es visible
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0, right: 16.0),
      child: Align(
        alignment: Alignment.bottomRight,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 9,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: FloatingActionButton(
            backgroundColor: Colors.white,
            onPressed: () {
              _showVideoOptions(context);
            },
            child: Icon(
              Icons.video_camera_back_outlined,
              size: 33,
              color: Colors.red,
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
            onPressed: () {
              // Acción al presionar el botón de "Mensaje"
            },
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
      setState(() {
        _videos.add(File(pickedFile.path));
        _currentIndex = _videos.length - 1;
        _initializeVideoPlayer(_videos[_currentIndex]);
      });
    }
  }

  void _showVideoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt, color: Colors.white),
              title: Text(
                'Grabar Video',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _recordVideo();
              },
            ),
            ListTile(
              leading: Icon(Icons.video_library, color: Colors.white),
              title: Text(
                'Seleccionar de la Galería',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickVideo();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo, color: Colors.white),
              title: Text(
                'Seleccionar Imagen',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            // Puedes agregar más opciones aquí según sea necesario
          ],
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


  // Método para grabar un nuevo video
  void _recordVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: Duration(seconds: 20),
    );
    if (pickedFile != null) {
      setState(() {
        _videos.add(File(pickedFile.path));
        _currentIndex = _videos.length - 1;
        _initializeVideoPlayer(_videos[_currentIndex]);
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
