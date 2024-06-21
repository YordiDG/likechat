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
  double _getVolume = 0;
  double _setVolumeValue = 0;
  int  _videoDuration = 0;
  int _currentIndex = 0;

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
      body: _videos.isEmpty
          ? _buildPlaceholder()
          : FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return PageView.builder(
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
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
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
            'No videos available. Add a new video!',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _showVideoOptions(context);
            },
            child: Text('Add Video'),
          ),
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

  Future<void> _recordImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      // Aplicar filtro a la imagen grabada desde la cámara
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

    // Actualizar la imagen en la lista de videos
    setState(() {
      _videos.add(imagen);
      _videos.add(filtroSepia);
      _videos.add(filtroCartoon);
      _videos.add(filtroAcuarela);
      _videos.add(filtroEspejo);
    });
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