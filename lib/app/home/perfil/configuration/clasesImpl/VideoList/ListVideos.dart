import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';


class VideoListScreen extends StatefulWidget {
  @override
  _VideoListScreenState createState() => _VideoListScreenState();
}


class _VideoListScreenState extends State<VideoListScreen> {
  late Future<List<dynamic>> videos;

  @override
  void initState() {
    super.initState();
    videos = fetchYouTubeVideos();
  }

  Future<List<dynamic>> fetchYouTubeVideos() async {
    final response = await http.get(
      Uri.parse(
        'https://www.googleapis.com/youtube/v3/search?key=AIzaSyDPIB3x8AuTrTec8YJc_Av_eUC5lGYSJ1I&channelId=UC_x5XG1OV2P6uZZ5FSM9Ttw&part=snippet&type=video&maxResults=40',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['items'];
    } else {
      throw Exception('Failed to load videos');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: Text('Lista de Videos', style: TextStyle( fontWeight: FontWeight.bold, color: Colors.white),),
        centerTitle: true,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: videos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar videos'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No se encontraron videos'));
          } else {
            return GridView.builder(
              padding: EdgeInsets.all(4.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 1.0,
                mainAxisSpacing: 1.0,
                childAspectRatio: 1.0,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final video = snapshot.data![index];
                final thumbnailUrl = video['snippet']['thumbnails']['medium']['url'];
                final videoId = video['id']['videoId'];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoDetailScreen(
                          videoId: videoId,
                          videos: snapshot.data!,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: Stack(
                      children: [
                        Image.network(
                          thumbnailUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                        Positioned.fill(
                          child: Align(
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.play_circle_filled,
                              color: Colors.white70,
                              size: 50,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class VideoDetailScreen extends StatefulWidget {
  final String videoId;
  final List<dynamic> videos;
  final int initialIndex;

  VideoDetailScreen({
    required this.videoId,
    required this.videos,
    required this.initialIndex,
  });

  @override
  _VideoDetailScreenState createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  late YoutubePlayerController _controller;
  late int currentIndex;
  bool _isPaused = false;
  int likes = 123;  // Inicialización del contador de me gusta
  int comments = 45;  // Inicialización del contador de comentarios
  int shares = 67;  // Inicialización del contador de compartidos

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoId,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );

    _controller.addListener(() {
      setState(() {
        _isPaused = !_controller.value.isPlaying;
      });
    });
  }

  void _loadVideo(int index) {
    setState(() {
      currentIndex = index;
      _controller.load(widget.videos[currentIndex]['id']['videoId']);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            Expanded(
              child: Container(
                height: 35,
                child: TextField(
                  textAlignVertical: TextAlignVertical.center,
                  cursorColor: Colors.cyan,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                    hintText: 'Buscar contenido',
                    hintStyle: TextStyle(color: Colors.white, fontSize: 12),
                    filled: true,
                    fillColor: Colors.transparent,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey.shade500),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.cyan),
                    ),
                    prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, '/search-rapida');
                  },
                  onSubmitted: (value) {
                    Navigator.pushNamed(context, '/search-rapida');
                  },
                ),
              ),
            ),
            SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/search-rapida');
              },
              child: Container(
                height: 27,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.cyan,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.cyan),
                ),
                child: Text(
                  'Buscar',
                  style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        centerTitle: false,
      ),
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            if (currentIndex < widget.videos.length - 1) {
              _loadVideo(currentIndex + 1);
            }
          } else if (details.primaryVelocity! > 0) {
            if (currentIndex > 0) {
              _loadVideo(currentIndex - 1);
            }
          }
        },
        child: Center(
          child: Stack(
            fit: StackFit.expand, // Expand the stack to fill the available space
            children: [
              Container(
                color: Colors.black, // Black background
              ),
              YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
              ),
              if (_isPaused)
                Center(
                  child: Icon(Icons.pause_circle_filled, color: Colors.white70, size: 100),
                ),
              Positioned(
                bottom: 40,
                right: 10,
                child: Column(
                  children: [
                    IconButton(
                      icon: Icon(Icons.favorite, color: Colors.white, size: 30),
                      onPressed: () {
                        setState(() {
                          likes++;
                        });
                      },
                    ),
                    Text(
                      '$likes',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    IconButton(
                      icon: Icon(Icons.comment, color: Colors.white, size: 30),
                      onPressed: () {},
                    ),
                    Text(
                      '$comments',
                      style: TextStyle(color: Colors.white),
                    ),
                    SizedBox(height: 8),
                    IconButton(
                      icon: Icon(Icons.share, color: Colors.white, size: 30),
                      onPressed: () {
                        setState(() {
                          shares++;
                        });
                      },
                    ),
                    Text(
                      '$shares',
                      style: TextStyle(color: Colors.white),
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}


class PlaceholderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_camera_back_rounded,
            color: Colors.grey[600],
            size: 80,
          ),
          SizedBox(height: 20),
          Text(
            'No hay videos aún',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            '¡Sé el primero en publicar uno!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}
