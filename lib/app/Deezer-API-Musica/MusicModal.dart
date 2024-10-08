import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initPlayer();
    _fetchPopularSongs(); // Cargar canciones populares
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
    _playerStateChangeSubscription = _audioPlayer.onPlayerStateChanged.listen((state) {
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

    final response = await http.get(Uri.parse('https://api.deezer.com/search?q=$query'));

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
    if (_currentSongUrl == previewUrl && _playerState == PlayerState.playing) return; // Evitar reproducir de nuevo

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

  Future<void> _stopSong() async {
    await _audioPlayer.stop();
    setState(() {
      _playerState = PlayerState.stopped;
      _position = Duration.zero;
    });
  }

  @override
  void dispose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) {
          return Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  _buildDragIndicator(),
                  SizedBox(height: 10),
                  _buildSearchField(),
                  SizedBox(height: 10),
                  _buildSongList(),
                  SizedBox(height: 10),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDragIndicator() {
    return Container(
      width: 60,
      height: 6,
      decoration: BoxDecoration(
        color: Colors.grey[600],
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Buscar música...',
        hintStyle: TextStyle(color: Colors.grey),
        prefixIcon: Icon(Icons.search, color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.grey[800],
      ),
      style: TextStyle(color: Colors.white),
      onChanged: (query) {
        searchSongs(query);
      },
    );
  }

  Widget _buildSongList() {
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

  Widget _buildSongTile(dynamic song) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8), // Reduce el espaciado interno del ListTile
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(song['album']['cover'], width: 50, height: 50, fit: BoxFit.cover),
            ),
            title: Text(song['title'], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text(song['artist']['name'], style: TextStyle(color: Colors.grey)),
            trailing: Column(
              mainAxisSize: MainAxisSize.min, // Para que la columna ocupe el mínimo espacio
              children: [
                GestureDetector(
                  onTap: () {
                    _currentSongUrl == song['preview'] && _playerState == PlayerState.playing
                        ? _pauseSong()
                        : _playSong(song['preview']);
                  },
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Línea circular delgada cuando no está reproduciendo
                      if (_currentSongUrl != song['preview'] || _playerState != PlayerState.playing)
                        CircularProgressIndicator(
                          value: null, // Sin valor, es un indicador de carga
                          color: Colors.grey[400], // Color de la línea circular delgada
                          strokeWidth: 2, // Grosor de la línea circular
                        ),
                      // Icono de reproducción con espaciado
                      Positioned(
                        child: Padding(
                          padding: const EdgeInsets.all(2.0), // Reduce el espaciado interior alrededor del icono
                          child: Icon(
                            _currentSongUrl == song['preview'] && _playerState == PlayerState.playing
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: 25, // Tamaño del icono
                          ),
                        ),
                      ),
                      // Circular progress indicator dinámico
                      if (_currentSongUrl == song['preview'] && _playerState == PlayerState.playing)
                        Positioned.fill(
                          child: CircularProgressIndicator(
                            value: (_duration != null && _position != null && _duration!.inSeconds > 0)
                                ? _position!.inSeconds.toDouble() / _duration!.inSeconds.toDouble()
                                : 0.0,
                            color: Colors.cyan,
                            strokeWidth: 2, // Grosor de la línea circular
                          ),
                        ),
                    ],
                  ),
                ),
                // Mostrar el contador de tiempo solo si está en reproducción
                SizedBox(height: 2), // Reduce el espaciado entre el botón y el tiempo
                if (_currentSongUrl == song['preview'] && _playerState == PlayerState.playing)
                  Text(
                    _position != null ? '${_position!.inMinutes}:${(_position!.inSeconds.remainder(60)).toString().padLeft(2, '0')}' : '0:00',
                    style: TextStyle(color: Colors.grey, fontSize: 10),
                  ),
              ],
            ),
          ),
          Divider(color: Colors.grey[600]), // Añadir un divisor para separar las canciones
        ],
      ),
    );
  }


}
