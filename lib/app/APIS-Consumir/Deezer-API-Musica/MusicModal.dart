import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:lottie/lottie.dart';

class MusicModal extends StatefulWidget {
  @override
  _MusicModalState createState() => _MusicModalState();
}

class _MusicModalState extends State<MusicModal> {
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

  final TextEditingController _controller =
      TextEditingController(); // Controlador del campo de búsqueda

  bool isActivated = false;
  String selectedItem = 'Recomendar';

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initPlayer();
    _fetchPopularSongs(); // Cargar canciones populares
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    _audioPlayer.dispose();
    _controller.dispose(); // Limpiar el controlador al desechar el widget
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
                      color: Color(0xFF111111).withOpacity(0.9),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(15)),
                    ),
                    child: Column(
                      children: [
                        //linea de modal
                        _buildDragIndicator(),
                        //palabras
                        _buildTopNavigation(),
                        Divider(
                          color: Colors.grey.shade500.withOpacity(0.4),
                          height: 1,
                          thickness: 0.7,
                        ),
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

  Widget _buildTopNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildNavigationItem('Recomendar', 'Recomendar'),
        _buildNavigationItem('Favoritos', 'Favoritos'),
        _buildNavigationItem('Sonidos', 'Sonidos'),
        IconButton(
          icon: Icon(Icons.search, color: Colors.white),
          onPressed: () {
            // Acción de búsqueda
          },
        ),
      ],
    );
  }

  Widget _buildNavigationItem(String label, String value) {
    bool isSelected = selectedItem == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedItem = value;
        });
      },
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (selectedItem == 'Recomendar') {
      return Center(
        child: Text(
          'Vista de Recomendar',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    } else if (selectedItem == 'Favoritos') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, color: Colors.white, size: 100),
            SizedBox(height: 10),
            Text(
              'No hay favoritos aún',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      );
    } else if (selectedItem == 'Sonidos') {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.sentiment_dissatisfied, color: Colors.white, size: 100),
            SizedBox(height: 10),
            Text(
              'No hay sonidos disponibles',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      );
    }
    return Container();
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
              child: Container(
                width: 17,
                height: 17,
                decoration: BoxDecoration(
                  color: isActivated ? Colors.cyan : Colors.transparent,
                  border: Border.all(
                    color: isActivated ? Colors.cyan : Colors.grey,
                    width: 1.2,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            SizedBox(width: 8), // Espacio entre el círculo y el texto
            Text(
              'Sonido original',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
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
                  Icon(Icons.volume_up, size: 22, color: Colors.white),
                  SizedBox(width: 5),
                  Text(
                    'Volumen',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
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

  //barra de encima del modal
  Widget _buildDragIndicator() {
    return Container(
      width: 60,
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
                hintStyle: TextStyle(color: Colors.grey, fontSize: 12),
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
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
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
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close, color: Colors.white, size: 16),
                ),
              )
            : SizedBox.shrink(),
      ],
    );
  }

  Widget _buildSongList() {
    if (songs.isEmpty) {
      // Verifica si la lista de canciones está vacía
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 50), // Espacio en la parte superior
            Icon(Icons.music_off, color: Colors.grey, size: 50),
            SizedBox(height: 10),
            Text(
              "No se encontró la música",
              style: TextStyle(color: Colors.grey, fontSize: 18),
            ),
          ],
        ),
      );
    } else {
      return ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
          return _buildSongTile(song);
        },
      );
    }
  }

  Widget _buildSongTile(dynamic song) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      // Espacio vertical entre canciones
      child: GestureDetector(
        onTap: () {
          // Reproduce o pausa la canción al tocar la fila
          _currentSongUrl == song['preview'] &&
                  _playerState == PlayerState.playing
              ? _pauseSong()
              : _playSong(song['preview']);
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            // Alinea los elementos al centro
            children: [
              SizedBox(width: 3), // espacio a la izquierda de la imagen
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  song['album']['cover'],
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 12), // Espacio entre la imagen y el texto
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Título de la canción
                        Text(
                          song['title'].length > 25
                              ? '${song['title'].substring(0, 25)}...'
                              : song['title'],
                          // Agregar "..." si el título es largo
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // Nombre del artista
                        Text(
                          song['artist']['name'].length > 20
                              ? '${song['artist']['name'].substring(0, 20)}...'
                              : song['artist']['name'],
                          // Agregar "..." si el nombre es largo
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        ),
                        SizedBox(width: 6),
                        // Espacio entre el nombre del artista y la duración
                        Text(
                          formatDuration(song['duration']),
                          // Duración de la canción
                          style: TextStyle(color: Colors.grey, fontSize: 10),
                        ),
                        // Icono musical
                        Icon(
                          Icons.music_note, // Icono musical
                          size: 12,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Icono de reproducción/pausa
              Container(
                margin: EdgeInsets.only(right: 2), // Añadir margen a la derecha
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.cyan, // Color de fondo del icono
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _currentSongUrl == song['preview'] &&
                                    _playerState == PlayerState.playing
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        // Circular progress indicator dinámico SOLO cuando está reproduciendo
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
                              color: Colors.white,
                              strokeWidth: 2, // Grosor de la barra circular
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 2),
                    // contador de tiempo cuando está en reproducción
                    if (_currentSongUrl == song['preview'] &&
                        _playerState == PlayerState.playing)
                      Text(
                        _position != null
                            ? '${_position!.inMinutes}:${(_position!.inSeconds.remainder(60)).toString().padLeft(2, '0')}'
                            : '0:00',
                        style: TextStyle(color: Colors.grey, fontSize: 10),
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

// Función para formatear la duración
  String formatDuration(int durationInSeconds) {
    final minutes = (durationInSeconds / 60).floor();
    final seconds = durationInSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
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
              onTap: () {}, // Evita cerrar el modal al tocar dentro del contenedor
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
                        fontSize: 18,
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
                          style: TextStyle(fontSize: 14, color: Colors.black54),
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
                          style: TextStyle(fontSize: 14, color: Colors.black54),
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
                      child: Text('Aplicar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),),
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
        trackHeight: 8, // Altura de la barra
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10), // Tamaño del "thumb"
        overlayShape: RoundSliderOverlayShape(overlayRadius: 20), // Efecto al presionar
      ),
      child: Slider(
        value: value,
        min: 0,
        max: 100,
        divisions: 100,
        activeColor: Colors.cyan, // Color de la barra activa
        inactiveColor: Colors.grey.shade300, // Color de la barra inactiva
        onChanged: onChanged,
      ),
    );
  }
}

