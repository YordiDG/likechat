import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'dart:async';

class VideoDetailGaleria extends StatefulWidget {
  final File videoFile;
  final VoidCallback onClose;
  final VoidCallback onSelect;
  final bool isSelected;

  const VideoDetailGaleria({
    Key? key,
    required this.videoFile,
    required this.onClose,
    required this.onSelect,
    required this.isSelected,
  }) : super(key: key);

  @override
  _AdvancedVideoPlayerState createState() => _AdvancedVideoPlayerState();
}

class _AdvancedVideoPlayerState extends State<VideoDetailGaleria> {
  late VideoPlayerController _videoController;
  bool _showControls = false;
  Timer? _controlsTimer;
  Timer? _positionUpdateTimer;
  ValueNotifier<Duration> _videoPositionNotifier = ValueNotifier(Duration.zero);

  bool _isSelected = false;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.isSelected;
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    _videoController = VideoPlayerController.file(widget.videoFile)
      ..initialize().then((_) {
        setState(() {
          _videoController.setLooping(false);
          _startAutoPlay();
        });
      });
  }

  void _startAutoPlay() {
    if (_videoController.value.isInitialized) {
      _videoController.play();
      _setupControlsAutoHide();
      _startPositionUpdate();
    }
  }

  void _startPositionUpdate() {
    _positionUpdateTimer = Timer.periodic(Duration(milliseconds: 100), (_) {
      if (_videoController.value.isInitialized) {
        _videoPositionNotifier.value = _videoController.value.position;
      }
    });
  }

  void _setupControlsAutoHide() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (_videoController.value.isPlaying) {
        _videoController.pause();
      } else {
        _videoController.play();
      }
      _showControls = true;
      _setupControlsAutoHide();
    });
  }

  void _onVideoTap() {
    setState(() {
      _togglePlayPause();
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _videoController.dispose();
    _controlsTimer?.cancel();
    _positionUpdateTimer?.cancel();
    _videoPositionNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safePadding = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Video Player
          Center(
            child: GestureDetector(
              onTap: _onVideoTap,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _videoController.value.isInitialized
                      ? FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: _videoController.value.size.width,
                      height: _videoController.value.size.height,
                      child: VideoPlayer(_videoController),
                    ),
                  )
                      : CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  // Overlay controls (e.g., progress bar and play/pause button)
                  if (_showControls)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black87,
                              Colors.black26,
                            ],
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  VideoProgressIndicator(
                                    _videoController,
                                    allowScrubbing: true,
                                    colors: VideoProgressColors(
                                        playedColor: Colors.cyan,
                                        bufferedColor: Colors.grey.shade700,
                                        backgroundColor: Colors.grey[800]!),
                                  ),
                                  ValueListenableBuilder<Duration>(
                                    valueListenable: _videoPositionNotifier,
                                    builder: (context, position, child) {
                                      final width = MediaQuery.of(context).size.width - 32;
                                      final totalDuration = (_videoController.value.duration.inMilliseconds + (1e-10));
                                      final currentPosition = position.inMilliseconds;
                                      final headPosition = (currentPosition / totalDuration) * width;

                                      return Positioned(
                                        left: headPosition - 8,
                                        top: -2,
                                        child: Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.cyan,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                              child: Row(
                                children: [
                                  ValueListenableBuilder<Duration>(
                                    valueListenable: _videoPositionNotifier,
                                    builder: (context, position, child) {
                                      return Text(
                                        _formatDuration(position),
                                        style: TextStyle(color: Colors.white, fontSize: 12),
                                      );
                                    },
                                  ),
                                  Spacer(),
                                  Text(
                                    _formatDuration(_videoController.value.duration),
                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          // Selection Checkbox overlay
          Positioned(
            top: safePadding.top + 10,
            right: 20,
            child: Row(
              children: [
                Checkbox(
                  value: _isSelected,
                  onChanged: (bool? value) {
                    setState(() {
                      _isSelected = value ?? false;
                    });
                    widget.onSelect();
                  },
                  activeColor: Colors.cyan,
                ),
                Text(
                  'Seleccionar',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12),
                ),
              ],
            ),
          ),
          // Close button overlay
          Positioned(
            top: safePadding.top + 10,
            left: 20,
            child: GestureDetector(
              onTap: widget.onClose,
              child: Container(
                width: 27,
                height: 27,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white70,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
