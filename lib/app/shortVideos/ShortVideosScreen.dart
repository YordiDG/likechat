import 'package:LikeChat/app/shortVideos/searchRapida/SearchScreen.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:volume_controller/volume_controller.dart';

import '../camera/UserAvatar.dart';

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

  @override
  void initState() {
    super.initState();
    if (_videos.isNotEmpty) {
      _initializeVideoPlayer(_videos[_currentIndex]);
    }
    VolumeController().listener((volume) {
      setState(() => _volumeListenerValue = volume);
    });

    VolumeController().getVolume().then((volume) => _setVolumeValue = volume);
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
        _controller!.play();
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
          icon: Icon(Icons.menu, color: Colors.white,),
          onPressed: () {

          },
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedIndex = 0;
                });
              },
              child: Text(
                'Snippets',
                style: TextStyle(
                  color: _selectedIndex == 0 ? Colors.white : Colors.grey,
                  fontSize: 18,
                  fontWeight: _selectedIndex == 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedIndex = 1;
                });
              },
              child: Text(
                'Posts',
                style: TextStyle(
                  color: _selectedIndex == 1 ? Colors.white : Colors.grey,
                  fontSize: 18,
                  fontWeight: _selectedIndex == 1 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: Colors.white, size: 30,),
            onPressed: () {
              // Navegar a la pantalla de búsqueda cuando se presiona el ícono de búsqueda
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchScreen()),
              );
            },
          ),

        ],
      ),
      body: _videos.isEmpty
          ? _buildPlaceholder()
          : RefreshIndicator(
        onRefresh: _handleRefresh,
        child: PageView.builder(
          scrollDirection: Axis.vertical,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
              _initializeVideoPlayer(_videos[_currentIndex]);
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
                ],
              ),
            );
          },
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
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

  Widget _buildIcons() {
    return Positioned(
      bottom: 90.0, // Ajusta el valor según sea necesario
      right: 19.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Positioned(
            top: MediaQuery.of(context).size.height * 0.30,
            right: 20.0,
            child: UserAvatar(
              isOwner: true, // O false, según corresponda
              addFriendCallback: (List<String> friendsList) {
                // Lógica para agregar amigos si no eres el propietario del video
              },
            ),
          ),
          IconButton(
            icon: SvgPicture.asset(
              'lib/assets/favorite.svg',
              width: 34.0,
              height: 34.0,
              color: Colors.white,
            ),
            onPressed: () {
              // Acción al presionar el botón de "Compartir"
            },
          ),
          Text(
            '$_likes',
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 12.0),
          IconButton(
            icon: SvgPicture.asset(
              'lib/assets/mesage.svg',
              width: 34.0,
              height: 34.0,
              color: Colors.white,
            ),
            onPressed: () {
              // Acción al presionar el botón de "Compartir"
            },
          ),
          Text(
            '$_comments',
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 12.0),
          IconButton(
            icon: SvgPicture.asset(
              'lib/assets/shared.svg',
              width: 34.0,
              height: 34.0,
              color: Colors.white,
            ),
            onPressed: () {
              // Acción al presionar el botón de "Compartir"
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white, size: 30.0), // Icono de tres puntos
            onPressed: () {
              // Acción al presionar el botón de tres puntos
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FloatingActionButton(
          onPressed: () {
            _showVideoOptions(context);
          },
          child: Icon(
            Icons.camera_alt_rounded,
            size: 33, // Tamaño del icono
            color: Colors.red, // Color del icono
          ),
        ),
      ],
    );
  }

  Future<void> _handleRefresh() async {
    // Simular carga de datos o actualizar la lista de videos
    await Future.delayed(Duration(seconds: 2)); // Simula una carga de 2 segundos
    setState(() {
      _videos.clear(); // Limpiar la lista de videos
    });
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
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Record Video'),
              onTap: () {
                Navigator.pop(context); // Utiliza Navigator.pop para regresar
                _recordVideo();
              },
            ),
            ListTile(
              leading: Icon(Icons.video_library),
              title: Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context); // Utiliza Navigator.pop para regresar
                _pickVideo();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text('Choose Image'),
              onTap: () {
                Navigator.pop(context); // Utiliza Navigator.pop para regresar
                _pickImage();
              },
            ),
            // Agrega más opciones según sea necesario
          ],
        );
      },
    );
  }

  // Método para pausar/activar el video al hacer clic en él
  void _toggleVideoPlayback() {
    if (_controller!.value.isPlaying) {
      _controller!.pause(); // Pausar el video si está reproduciéndose
    } else {
      _controller!.play(); // Reanudar la reproducción si el video está pausado
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Aplicar filtro a la imagen seleccionada
      await _applyImageFilter(File(pickedFile.path));
    }
  }

  Future<void> _applyImageFilter(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final imagen = img.decodeImage(bytes);
    final filtroSepia = img.grayscale(imagen!);
    final filtroCartoon = _aplicarCartoon(imagen);
    final filtroAcuarela = _aplicarAcuarela(imagen);
    final filtroEspejo = img.flipHorizontal(imagen);

    // Actualizar la lista de videos
    setState(() {
      var pickedFile;
      _videos.add(File(pickedFile.path));
      _videos.add(filtroSepia);
      _videos.add(filtroCartoon);
      _videos.add(filtroAcuarela);
      _videos.add(filtroEspejo);
      _currentIndex = _videos.length - 1;
      _initializeVideoPlayer(_videos[_currentIndex]);
    });
  }

  Future<void> _recordImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      // Aplicar filtro a la imagen grabada desde la cámara
      await _applyImageFilter(File(pickedFile.path));
    }
  }


  img.Image _aplicarCartoon(img.Image imagen) {
    final grayscale = img.grayscale(imagen);
    final sobel = img.sobel(grayscale);
    return img.invert(sobel);
  }

  img.Image _aplicarAcuarela(img.Image imagen) {
    final blur = img.gaussianBlur(imagen, radius: 20);
    return img.colorOffset(blur, red: 30, green: 30, blue: 30);
  }

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

  @override
  void dispose() {
    _controller?.dispose();
    VolumeController().removeListener();
    super.dispose();
  }
}
