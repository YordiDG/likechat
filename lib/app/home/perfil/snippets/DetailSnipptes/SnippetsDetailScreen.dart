import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';

import '../../../../Globales/estadoDark-White/DarkModeProvider.dart';

class VideoDetailScreen extends StatefulWidget {
  final List<String> videoUrls;
  final int initialIndex;

  const VideoDetailScreen({
    Key? key,
    required this.videoUrls,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _VideoDetailScreenState createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.videoUrls.length,
        itemBuilder: (context, index) {
          final videoUrl = widget.videoUrls[index];
          return VideoPlayerScreen(videoUrl: videoUrl);
        },
      ),
    );
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  bool _isPlaying = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  Widget build(BuildContext context) {

    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final backgroundColor = darkModeProvider.backgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Stack(
        children: [
          Center(
            child: _controller.value.isInitialized
                ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
                : Center(child: CircularProgressIndicator()),
          ),
          // Play/Pause Button at the center
          Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (_isPlaying) {
                    _controller.pause();
                  } else {
                    _controller.play();
                  }
                  _isPlaying = !_isPlaying;
                });
              },
              child: Container(
                width: 45, // Size of the circular button
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5), // Semi-transparent background
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 30, // Size of the icon
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          // Overlay for video controls
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              color: Colors.black.withOpacity(0.6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.favorite_border, color: Colors.white),
                    onPressed: () {
                      // Handle like action
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.chat_bubble_outline, color: Colors.white),
                    onPressed: () {
                      // Handle comments action
                      _showComments(context);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.share, color: Colors.white),
                    onPressed: () {
                      // Handle share action
                    },
                  ),
                ],
              ),
            ),
          ),
          // Top controls and user info
          Positioned(
            top: 40,
            left: 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                SizedBox(height: 8),
                // User info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage('lib/assets/placeholder_user.jpg'),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Yordi Diaz Gonzales ',
                          style: TextStyle(color: textColor, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'hace 2h',
                          style: TextStyle(color: textColor, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 40,
            right: 10,
            child: IconButton(
              icon: Icon(Icons.search, color: iconColor),
              onPressed: () {
                // Handle search action
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (BuildContext context, ScrollController scrollController) {
            return ListView(
              controller: scrollController,
              children: [
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Comentarios',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // List of comments
                _buildComment('Usuario 1', 'Este es un comentario.', 'Hace 1 hora'),
                _buildComment('Usuario 2', 'Este es otro comentario.', 'Hace 2 horas'),
                _buildComment('Usuario 3', '¡Gran video!', 'Hace 3 horas'),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildComment(String userName, String comment, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 3.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('lib/assets/placeholder_user.jpg'),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          userName,
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        SizedBox(width: 8),
                        Text(time, style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(comment, style: TextStyle(color: Colors.black)),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.favorite_border, size: 16, color: Colors.grey),
                          onPressed: () {
                            // Handle like comment
                          },
                        ),
                        SizedBox(width: 4),
                        Text('Me gusta', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        SizedBox(width: 16),
                        TextButton(
                          child: Text('Responder', style: TextStyle(color: Colors.grey, fontSize: 12)),
                          onPressed: () {
                            // Handle reply
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(color: Colors.grey),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
