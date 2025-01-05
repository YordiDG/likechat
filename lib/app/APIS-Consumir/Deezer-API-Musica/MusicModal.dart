import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import '../../Globales/estadoDark-White/DarkModeProvider.dart';

class MusicModal extends StatefulWidget {
  @override
  _MusicModalState createState() => _MusicModalState();
}

class _MusicModalState extends State<MusicModal> with TickerProviderStateMixin {
  List<dynamic> songs = [];
  String searchQuery = '';
  late AudioPlayer _audioPlayer;

  // Estado del reproductor
  PlayerState? _playerState;
  Duration? _duration;
  Duration? _position;
  String? _currentSongUrl;

  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;

  // Reflesh de música
  bool _isLoading = false;

  // Animación de letra
  late AnimationController _titleAnimationController;
  late Animation<Offset> _titleAnimation;

  final TextEditingController _controller =
  TextEditingController(); // Controlador del campo de búsqueda

  bool isActivated = false;

  // Nuevos controladores para los iconos de música
  late List<AnimationController> _musicIconControllers;
  late List<Animation<double>> _musicIconScales;
  late List<Animation<double>> _musicIconOpacities;

  late List<double> _noteAngles; // Añadir esta variable a la clase

  @override
  void initState() {
    super.initState();

    _titleAnimationController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );

    _titleAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(-0.5, 0),
    ).animate(CurvedAnimation(
      parent: _titleAnimationController,
      curve: Curves.linear,
    ));

    _audioPlayer = AudioPlayer();
    _initPlayer();
    _fetchPopularSongs();

    // Inicializar más ángulos aleatorios
    _noteAngles = List.generate(8, (index) => Random().nextDouble() * 2 * pi);

    // Más controladores con duración más larga para movimiento más suave
    _musicIconControllers = List.generate(
      8,
          (index) => AnimationController(
        duration: Duration(milliseconds: 2500 + (Random().nextInt(500))), // Duración variable
        vsync: this,
      ),
    );
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    _audioPlayer.dispose();
    _controller.dispose(); // Limpiar el controlador al desechar el widget

    _titleAnimationController.dispose();
    for (var controller in _musicIconControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  void _initPlayer() {
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
    _durationSubscription = _audioPlayer.onDurationChanged.listen((duration) {
      setState(() => _duration = duration);
    });
    _positionSubscription = _audioPlayer.onPositionChanged.listen((position) {
      setState(() => _position = position);
    });
    _playerCompleteSubscription = _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _playerState = PlayerState.stopped;
        _position = Duration.zero;
      });
    });
    _playerStateChangeSubscription =
        _audioPlayer.onPlayerStateChanged.listen((state) {
          setState(() => _playerState = state);
        });
  }

  Future<void> _fetchPopularSongs() async {
    final response = await http.get(Uri.parse('https://api.deezer.com/chart'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        songs = data['tracks']['data'];
      });
    } else {
      setState(() {
        songs = [];
      });
    }
  }

  void searchSongs(String query) async {
    if (query.isEmpty) {
      _fetchPopularSongs(); // Mostrar canciones populares si no hay búsqueda
      return;
    }

    final response =
    await http.get(Uri.parse('https://api.deezer.com/search?q=$query'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        songs = data['data'];
      });
    } else {
      setState(() {
        songs = [];
      });
    }
  }

  Future<void> _playSong(String previewUrl) async {
    if (_currentSongUrl == previewUrl && _playerState == PlayerState.playing)
      return; // Evitar reproducir de nuevo

    await _audioPlayer.play(UrlSource(previewUrl));
    setState(() {
      _currentSongUrl = previewUrl;
      _playerState = PlayerState.playing;
    });
  }

  Future<void> _pauseSong() async {
    await _audioPlayer.pause();
    setState(() => _playerState = PlayerState.paused);
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;

    return GestureDetector(
      onTap: () {
        Navigator.pop(context); // Cierra el modal al tocar fuera
      },
      child: Stack(
        children: [
          Material(
            color: Colors.transparent,
            child: DraggableScrollableSheet(
              initialChildSize: 0.74,
              minChildSize: 0.74,
              maxChildSize: 0.74,
              builder: (context, scrollController) {
                return GestureDetector(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Color(0xFF10141A) : Colors.white,
                      borderRadius:
                      BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: Column(
                      children: [
                        //linea de modal
                        _buildDragIndicator(),
                        SizedBox(height: 6),
                        _buildSearchField(),
                        // Barra de búsqueda
                        SizedBox(height: 7),

                        // Lista de canciones
                        Expanded(
                          child: SingleChildScrollView(
                            controller: scrollController,
                            child: Column(
                              children: [
                                _buildSongList(),
                                // Construir la lista de canciones
                                SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),

                        Divider(
                          color: Colors.grey.shade500.withOpacity(0.4),
                          height: 1,
                          thickness: 0.7,
                        ),

                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: _buildSoundBar(),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  //barra de encima del modal
  Widget _buildDragIndicator() {
    return Container(
      width: 40,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[600],
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  //barra de navegacion con detail
  Widget _buildSearchField() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 33,
            child: TextField(
              controller: _controller,
              cursorColor: Colors.cyan,
              decoration: InputDecoration(
                hintText: 'Buscar música...',
                hintStyle: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                    fontSize: 11),
                prefixIcon: Icon(Icons.search, size: 20, color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.cyan),
                ),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding:
                EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              ),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
              onChanged: (query) {
                searchSongs(query);
              },
            ),
          ),
        ),
        SizedBox(width: 8),
        _controller.text.isNotEmpty
            ? GestureDetector(
          onTap: () {
            _controller.clear(); // Limpiar el texto al tocar la "X"
            searchSongs(
                ""); // Llama a searchSongs con un string vacío para mostrar toda la música
            setState(
                    () {}); // Actualizar el estado para reflejar el cambio
          },
          child: Container(
            width: 23,
            height: 23,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.close,
              size: 15,
              color: Colors.white,
            ),
          ),
        )
            : SizedBox.shrink(),
      ],
    );
  }

  Widget _buildSongList() {
    if (songs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.withOpacity(0.1),
              ),
              child: ShaderMask(
                shaderCallback: (bounds) =>
                    const LinearGradient(
                      colors: [Color(0xFF9B30FF), Color(0xFF00BFFF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ).createShader(bounds),
                child: const Icon(
                  Icons.music_off_rounded,
                  size: 35,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "No se encontró la música",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Intenta buscar algo diferente o explora \nlas tendencias populares.",
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 9,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            InkWell(
              onTap: () async {
                setState(() {
                  _isLoading = true;
                });

                try {
                  final result = await InternetAddress.lookup('google.com');
                  if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
                    await _buildSearchField(); // Tu función de búsqueda
                  } else {
                    _showErrorSnackbar('Sin conexión a Internet');
                  }
                } on SocketException catch (_) {
                  _showErrorSnackbar('Sin conexión a Internet');
                } finally {
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF9B30FF), Color(0xFF00BFFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: _isLoading
                    ? Lottie.asset(
                  'lib/assets/loading/loading_infinity.json',
                  width: 40,
                  height: 40,
                )
                    : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Reintentar",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        return _buildSongTile(song);
      },
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  //musicaaaaas
  Widget _buildSongTile(dynamic song) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final bool isLongTitle = song['title'].length > 25;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: GestureDetector(
        onTap: () {
          if (_currentSongUrl == song['preview'] &&
              _playerState == PlayerState.playing) {
            _pauseSong();
            for (var controller in _musicIconControllers) {
              controller.stop();
            }
            if (isLongTitle) {
              _titleAnimationController.stop();
            }
          } else {
            _playSong(song['preview']);
            for (var controller in _musicIconControllers) {
              controller
                ..reset()
                ..repeat();
            }
            if (isLongTitle) {
              _titleAnimationController.repeat();
            }
          }
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    (song['album'] != null &&
                        song['album']['cover'] != null &&
                        song['album']['cover'].toString().isNotEmpty)
                        ? Image.network(
                      song['album']['cover'],
                      width: 45,
                      height: 45,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.broken_image,
                        color: Colors.grey,
                        size: 40,
                      ),
                    )
                        : Icon(
                      Icons.broken_image,
                      color: Colors.grey,
                      size: 40,
                    ),
                    if (_currentSongUrl == song['preview'] &&
                        _playerState == PlayerState.playing)
                      ...List.generate(8, (index) {
                        return AnimatedBuilder(
                          animation: _musicIconControllers[index],
                          builder: (context, child) {
                            final double progress = _musicIconControllers[index].value;
                            final double angle = _noteAngles[index];

                            // Radio más grande para más dispersión
                            final double radius = 25.0 * progress;
                            final double x = 22.5 + (radius * cos(angle));
                            final double y = 22.5 + (radius * sin(angle));

                            // Escala más suave
                            final double scale = 0.3 + (progress * 0.8);
                            // Opacidad más suave
                            final double opacity = sin(progress * pi) * 0.9;

                            return Positioned(
                              left: x - 6,
                              top: y - 6,
                              child: Transform.rotate(
                                angle: progress * 4 * pi, // Dos rotaciones completas
                                child: Opacity(
                                  opacity: opacity,
                                  child: Transform.scale(
                                    scale: scale,
                                    child: Icon(
                                      Icons.music_note,
                                      color: Colors.white,
                                      size: 10,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      }),
                  ],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ClipRect(
                            child: isLongTitle &&
                                _currentSongUrl == song['preview'] &&
                                _playerState == PlayerState.playing
                                ? SlideTransition(
                              position: _titleAnimation,
                              child: Text(
                                song['title'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                                maxLines: 1,
                              ),
                            )
                                : Text(
                              isLongTitle
                                  ? '${song['title'].substring(0, 20)}...'
                                  : song['title'],
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          song['artist']['name'].length > 15
                              ? '${song['artist']['name'].substring(0, 15)}...'
                              : song['artist']['name'],
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                        SizedBox(width: 6),
                        Text(
                          formatDuration(song['duration']),
                          style: TextStyle(color: Colors.grey, fontSize: 9),
                        ),
                        Icon(
                          Icons.music_note,
                          size: 10,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_currentSongUrl == song['preview'] &&
                  _playerState == PlayerState.playing)
                Row(
                  children: [
                    SizedBox(
                      height: 25,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF00BFFF),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        child: Text(
                          'Usar',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: () {
                          // Implementar lógica para usar
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.star_border, size: 27, color: Colors.amber),
                      onPressed: () {
                        // Implementar lógica para favoritos
                      },
                    ),
                  ],
                ),
              Container(
                margin: EdgeInsets.only(right: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF9B30FF),
                                Color(0xFF00BFFF),
                                Color(0xFF00FFFF),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _currentSongUrl == song['preview'] &&
                                _playerState == PlayerState.playing
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        if (_currentSongUrl == song['preview'] &&
                            _playerState == PlayerState.playing)
                          Positioned.fill(
                            child: CircularProgressIndicator(
                              value: (_duration != null &&
                                  _position != null &&
                                  _duration!.inSeconds > 0)
                                  ? _position!.inSeconds.toDouble() /
                                  _duration!.inSeconds.toDouble()
                                  : 0.0,
                              color:
                              isDarkMode ? Colors.white : Color(0xFF9B30FF),

                              strokeWidth: 2,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 2),
                    if (_currentSongUrl == song['preview'] &&
                        _playerState == PlayerState.playing)
                      Text(
                        _position != null
                            ? '${_position!.inMinutes}:${(_position!.inSeconds.remainder(60)).toString().padLeft(2, '0')}'
                            : '0:00',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 8,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _generateNewAngles() {
    _noteAngles = List.generate(8, (index) {
      // Ángulos más distribuidos
      return (index * (pi / 4)) + (Random().nextDouble() * 0.5);
    });
  }

  void _startIconSequence() {
    for (var controller in _musicIconControllers) {
      controller.reset();
    }

    void startNextAnimation(int index) {
      if (index >= _musicIconControllers.length) return;

      if (_playerState == PlayerState.playing) {
        _musicIconControllers[index].forward().whenComplete(() {
          if (_playerState == PlayerState.playing) {
            _musicIconControllers[index].reset();
            // Nuevo ángulo más suave
            _noteAngles[index] = Random().nextDouble() * 2 * pi;
            Future.delayed(Duration(milliseconds: 100), () {
              startNextAnimation(index);
            });
          }
        });
      }
    }

    // Iniciar secuencia con delays más cortos y distribuidos
    for (int i = 0; i < 8; i++) {
      Future.delayed(Duration(milliseconds: i * 300), () => startNextAnimation(i));
    }
  }

// Función para formatear la duración
  String formatDuration(int durationInSeconds) {
    final minutes = (durationInSeconds / 60).floor();
    final seconds = durationInSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  //boton de sonido
  Widget _buildSoundBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  isActivated = !isActivated;
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Círculo de fondo
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: isActivated ? Colors.cyan : Colors.transparent,
                      border: Border.all(
                        color: isActivated ? Colors.cyan : Colors.grey,
                        width: 1.2,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                  // Ícono de check
                  if (isActivated)
                    Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
                    ),
                ],
              ),
            ),
            SizedBox(width: 8), // Espacio entre el círculo y el texto
            Text(
              'Sonido original',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {
                // Llama al modal al hacer tap
                showDialog(
                  context: context,
                  builder: (context) => SoundSettingsModal(),
                );
              },
              child: Row(
                children: [
                  Icon(Icons.volume_up, size: 22),
                  SizedBox(width: 5),
                  Text(
                    'Volumen',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SoundSettingsModal extends StatefulWidget {
  @override
  _SoundSettingsModalState createState() => _SoundSettingsModalState();
}

class _SoundSettingsModalState extends State<SoundSettingsModal> {
  double originalSoundVolume = 50.0;
  double musicVolume = 50.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onTap: () => Navigator.pop(context), // Cierra el modal al tocar fuera
        child: Container(
          color: Colors.black.withOpacity(0.4), // Fondo negro opaco
          child: Center(
            child: GestureDetector(
              onTap: () {},
              // Evita cerrar el modal al tocar dentro del contenedor
              child: Container(
                padding: EdgeInsets.all(20),
                width: 300,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Configuración de Volumen',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 20),
                    // Barra de Sonido Original
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sonido Original',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        SizedBox(height: 8),
                        _buildVolumeBar(originalSoundVolume, (value) {
                          setState(() {
                            originalSoundVolume = value;
                          });
                        }),
                        Text(
                          '${originalSoundVolume.toInt()}%',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    // Barra de Música
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Música',
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        SizedBox(height: 8),
                        _buildVolumeBar(musicVolume, (value) {
                          setState(() {
                            musicVolume = value;
                          });
                        }),
                        Text(
                          '${musicVolume.toInt()}%',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ],
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {
                        print(
                            'Sonido Original: $originalSoundVolume, Música: $musicVolume');
                        Navigator.pop(context); // Cierra el modal
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Aplicar',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget de barra gráfica personalizada
  Widget _buildVolumeBar(double value, ValueChanged<double> onChanged) {
    return SliderTheme(
      data: SliderThemeData(
        trackHeight: 8,
        // Altura de la barra
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
        // Tamaño del "thumb"
        overlayShape:
        RoundSliderOverlayShape(overlayRadius: 20), // Efecto al presionar
      ),
      child: Slider(
        value: value,
        min: 0,
        max: 100,
        divisions: 100,
        activeColor: Colors.cyan,
        // Color de la barra activa
        inactiveColor: Colors.grey.shade300,
        // Color de la barra inactiva
        onChanged: onChanged,
      ),
    );
  }
}
