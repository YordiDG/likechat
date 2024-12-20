import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';
import 'package:provider/provider.dart';
import '../../../../Globales/estadoDark-White/DarkModeProvider.dart';
import '../../../shortVideos/Posts/eventos/ComentariosPost.dart';

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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  Timer? _timer;
  bool _isPlaying = true;
  bool _isLiked = false;
  bool _isSaved = false;
  bool _isSmallVideo = false;
  Duration _currentPosition = Duration.zero;
  Duration _videoLength = Duration.zero;

  bool _showHeart = false;
  late AnimationController _heartAnimationController;
  late Animation<double> _heartAnimation;
  late Animation<Offset> _heartPositionAnimation;

  bool _showPlayIcon = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();

    _heartAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 350),
    );
    _heartAnimation = Tween<double>(begin: 1.2, end: 0.8).animate(
      CurvedAnimation(
        parent: _heartAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Animación de desplazamiento
    _heartPositionAnimation = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(0, -0.1), // Desplazamiento hacia arriba
    ).animate(CurvedAnimation(
      parent: _heartAnimationController,
      curve: Curves.easeInOut,
    ));

    // Listener para reiniciar la animación
    _heartAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _heartAnimationController.reset();
      }
    });
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.network(widget.videoUrl);
    await _controller.initialize();
    _videoLength = _controller.value.duration;
    _checkVideoSize();
    setState(() {});
    _controller.play();
    _controller.setLooping(true);

    // Iniciar el timer para actualizar la posición del video
    _timer = Timer.periodic(Duration(milliseconds: 200), (timer) {
      if (mounted) {
        setState(() {
          _currentPosition = _controller.value.position;
        });
      }
    });
  }

  void _checkVideoSize() {
    if (_controller.value.isInitialized) {
      final videoRatio =
          _controller.value.size.width / _controller.value.size.height;
      setState(() {
        _isSmallVideo = videoRatio <= 16 / 9;
      });
    }
  }

  Widget _buildBlurredBackground() {
    if (!_isSmallVideo || !_controller.value.isInitialized) {
      return Container();
    }

    return Positioned.fill(
      child: Stack(
        children: [
          Transform.scale(
            scale: 1.5,
            child: VideoPlayer(_controller),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
            child: Container(
              color: Colors.black.withOpacity(0.3),
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ],
      ),
    );
  }

  //intecaccion de like y comentarios
  Widget _buildInteractionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          SizedBox(
            width: 45,
            height: 45,
            child: Icon(
              icon,
              color: isActive ? Color(0xFFFF0000) : Colors.white,
              size: 30,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 1,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //boton de favoritos
  Widget _buildInteractionButtonFavorite({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          SizedBox(
            width: 45,
            height: 45,
            child: Icon(
              icon,
              color: isActive ? Color(0xFFFFA500) : Colors.white,
              size: 28,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 1,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //boton de share:
  Widget _buildInteractionButtonShare({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          SizedBox(
            width: 45,
            height: 45,
            child: Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 1,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleDoubleTap() {
    setState(() {
      _showHeart = true;
      _isLiked = true; // Actualizar el estado del corazón al dar doble tap
    });
    _heartAnimationController.forward(from: 0).then((_) {
      _heartAnimationController.reverse().then((_) {
        setState(() {
          _showHeart = false;
        });
      });
    });
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _handleDoubleTap(); // Trigger heart animation when liking
      }
    });
  }


  Widget _buildVideoControls() {
    return Positioned(
      right: 10,
      bottom: 65,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: _toggleLike,
            child: Column(
              children: [
                ScaleTransition(
                  scale: _heartAnimation,
                  child: Icon(
                    _isLiked
                        ? FontAwesomeIcons.solidHeart
                        : FontAwesomeIcons.heart,
                    color: _isLiked ? Color(0xFFFF0000) : Colors.white,
                    size: 27,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '2 mill.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 1,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 10),
          _buildInteractionButton(
            icon: FontAwesomeIcons.comment,
            label: '120 mil',
            onTap: () => _showComments(context),
          ),
          SizedBox(height: 10),
          _buildInteractionButtonShare(
            icon: FontAwesomeIcons.paperPlane,
            label: '20 mil',
            onTap: () {},
          ),
          SizedBox(height: 10),
          _buildInteractionButtonFavorite(
            icon: _isSaved
                ? FontAwesomeIcons.solidBookmark
                : FontAwesomeIcons.bookmark,
            label: '12 mil',
            isActive: _isSaved,
            onTap: () => setState(() => _isSaved = !_isSaved),
          ),
        ],
      ),
    );
  }

  void _showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.9),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 10),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    _buildComment('Usuario 1', 'Comentario 1', '1h'),
                    _buildComment('Usuario 2', 'Comentario 2', '2h'),
                    _buildComment('Usuario 3', 'Comentario 3', '3h'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComment(String userName, String comment, String time) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      time,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  comment,
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  //barrad eprogreso y comentario final
  Widget _buildProgressBarAndComments() {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: Container(
        color: Colors.black,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Primera fila: Barra de progreso y "Add comentario"
            Row(
              children: [
                // Barra de progreso
                Expanded(
                  child: Column(
                    children: [
                      // Reducir el SizedBox de altura para hacer la barra más compacta
                      SizedBox(
                        height: 5, // Reducir el espacio de la barra de progreso
                        child: Stack(
                          children: [
                            // Fondo de la barra de progreso
                            Container(
                              width: double.infinity,
                              height: 2, // Reducir la altura de la barra
                              color: Colors.grey,
                            ),
                            // Barra de progreso actual
                            LayoutBuilder(
                              builder: (context, constraints) {
                                double progress = _controller.value.isInitialized
                                    ? _currentPosition.inMilliseconds / _videoLength.inMilliseconds
                                    : 0.0;
                                return Container(
                                  width: constraints.maxWidth * progress,
                                  height: 2, // Reducir la altura de la barra
                                  color: Colors.cyan,
                                );
                              },
                            ),
                            // Cabeza redonda
                            LayoutBuilder(
                              builder: (context, constraints) {
                                double progress = _controller.value.isInitialized
                                    ? _currentPosition.inMilliseconds / _videoLength.inMilliseconds
                                    : 0.0;
                                return Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    margin: EdgeInsets.only(
                                      left: (constraints.maxWidth * progress),
                                    ),
                                    child: Container(
                                      width: 12, // Reducir el tamaño de la cabeza
                                      height: 12, // Reducir el tamaño de la cabeza
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Texto "Add comentario"
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: [
                      Icon(
                        Icons.play_arrow,
                        size: 16,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '23mil',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // boton  comentario y botón de estadísticas
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  // Icono de comentario
                  Icon(
                    FontAwesomeIcons.userPen,
                    size: 20,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 8),
                  // Input de comentario
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Aquí llamas al modal ComentariosPost()
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return ComentariosPost();
                          },
                          isScrollControlled: true,
                        );
                      },
                      child: Container(
                        height: 36,
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(17),
                        ),
                        child: Center(
                          child: Text(
                            'Abrir Comentarios',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  // Botón de estadísticas
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size(0, 32),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min, // Para ajustar el tamaño al contenido
                      children: [
                        Icon(
                          Icons.bar_chart,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 2),
                        Text(
                          'Ver estadísticas',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //encabezado o header
  Widget _buildCustomAppBar(
      BuildContext context, bool isDarkMode, Color textColor, Color iconColor) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Row(
          children: [
            IconButton(
              icon: Stack(
                alignment: Alignment.center,
                children: [
                  // Sombra detrás del ícono
                  Icon(
                    Icons.arrow_back_ios,
                    size: 25,
                    color: Colors.grey,  // Sombra negra
                  ),
                  // Ícono principal con color blanco
                  Icon(
                    Icons.arrow_back_ios,
                    size: 23,
                    color: Colors.white,
                  ),
                ],
              ),
              onPressed: () => Navigator.pop(context),
            ),
            Container(
              width: 44, // Doble del radio para mantener el tamaño
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey, // Color del borde
                  width: 0.3, // Ancho del borde
                ),
              ),
              child: CircleAvatar(
                radius: 21.5, // Ajustar el radio para que se acomode dentro del borde
                backgroundImage: AssetImage('lib/assets/placeholder_user.jpg'),
                backgroundColor: Colors.transparent, // Fondo transparente
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Row(
                children: [
                  Text(
                    'Yordi Diaz Gonzales',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 1,
                          color: Colors.black,
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(width: 6),
                  Text(
                    '•',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 1,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    '2h',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 1,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            IconButton(
              icon: Container(
                padding: EdgeInsets.all(8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Sombra detrás del ícono
                    Icon(
                      Icons.search,
                      size: 28,
                      color: Colors.grey,  // Sombra negra
                    ),
                    // Ícono principal con color blanco
                    Icon(
                      Icons.search,
                      size: 26,
                      color: Colors.white,  // Ícono blanco
                    ),
                  ],
                ),
              ),
              onPressed: () => () {},
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap() {
    setState(() {
      if (_isPlaying) {
        _controller.pause();
        _showPlayIcon = true;
      } else {
        _controller.play();
        _showPlayIcon = true;
      }
      _isPlaying = !_isPlaying;

      // Ocultar el ícono después de 1 segundo
      Future.delayed(Duration(seconds: 1), () {
        setState(() {
          _showPlayIcon = false;
        });
      });
    });
  }

  final String natureDescription =
      "LikeChat es una red social diseñada para conectar personas de todo el mundo, "
      "donde puedes compartir tus momentos más especiales a través de fotos, videos y mensajes. "
      "Nuestra plataforma permite una interacción dinámica, con herramientas para crear contenido creativo, "
      "seguir a tus amigos y descubrir nuevas conexiones. Con LikeChat, cada usuario tiene la oportunidad "
      "de ser parte de una comunidad global, expresar sus intereses y explorar contenido en tiempo real, "
      "todo en un entorno divertido y seguro.";

  bool _isExpanded = false;

  /// Método que construye el widget de descripción
  Widget _buildDescription() {
    // Descripción acortada
    String shortDescription = natureDescription.length > 80
        ? natureDescription.substring(0, 80) + "..."
        : natureDescription;

    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.transparent,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Ajusta el tamaño al contenido
        children: [
          // Texto con la descripción
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8, // Limita el ancho al 80% de la pantalla
                maxHeight: _isExpanded
                    ? MediaQuery.of(context).size.height * 0.75 // Expande hasta el 75% de la altura
                    : double.infinity, // Usa double.infinity para expansión total cuando no está expandido
              ),
              child: SingleChildScrollView( // Hacemos que el contenido sea desplazable
                child: Align( // Alineamos el contenido hacia arriba
                  alignment: Alignment.topLeft,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Texto con la descripción
                      Text(
                        _isExpanded ? natureDescription : shortDescription,
                        style: const TextStyle(
                            fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500),
                        maxLines: _isExpanded ? null : 2, // Por defecto 2 líneas
                        overflow: TextOverflow.visible, // Evita el truncamiento con elipsis
                      ),
                      const SizedBox(height: 2),
                      // Botón de "Ver más" o "Ver menos"
                      if (natureDescription.length > 80)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isExpanded = !_isExpanded;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              _isExpanded ? "Ver menos" : "Ver más",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black.withOpacity(0.8),
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _handleTap,
        onDoubleTap: _handleDoubleTap,
        child: Column(
          children: [
            // Sección de reproducción de video
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Fondo borroso solo para las secciones que deben estar desenfocadas
                  _buildBlurredBackground(),

                  // Video principal nítido
                  Center(
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),

                  // Barra personalizada sobre el video
                  Positioned(
                    top: 0, // Asegúrate de que esté en la parte superior
                    left: 0,
                    right: 0,
                    child: _buildCustomAppBar(
                        context, isDarkMode, textColor, iconColor),
                  ),
                  Positioned(
                    bottom: 0, // Asegúrate de que esté en la parte inferior
                    left: 0,
                    right: 0,
                    child: _buildDescription(),
                  ),

                  // Controles de interacción (like, comentarios, etc.)
                  _buildVideoControls(),

                  // Animación del corazón al doble tap
                  if (_showHeart)
                    Center(
                      child: AnimatedBuilder(
                        animation: _heartAnimationController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _heartAnimation.value,
                            child: Transform.translate(
                              offset: _heartPositionAnimation.value,
                              child: Icon(
                                Icons.favorite,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                  // Ícono de reproducción o pausa
                  if (!_isPlaying)
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 60, // Tamaño del círculo
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.4),
                          shape: BoxShape.circle, // Forma circular
                        ),
                        child: Icon(
                          Icons.play_arrow,
                          size: 36,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Sección de comentarios
            _buildProgressBarAndComments(),
          ],
        ),
      ),
    );
  }


  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    _heartAnimationController.dispose();
    super.dispose();
  }
}
