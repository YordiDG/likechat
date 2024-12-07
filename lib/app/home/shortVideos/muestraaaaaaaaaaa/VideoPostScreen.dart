import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../APIS-Consumir/service/PexelsService.dart';

class VideoPostScreen extends StatefulWidget {
  @override
  _VideoPostScreenState createState() => _VideoPostScreenState();
}

class _VideoPostScreenState extends State<VideoPostScreen>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool _isLoading = true; // Para mostrar un indicador de carga
  String? videoUrl; // URL del video desde la API de Pexels
  int likes = 237; // Cantidad inicial de likes
  int comments = 5; // Cantidad inicial de comentarios
  int views = 7557; // Cantidad inicial de vistas
  bool isLiked = false; // Si el video ha sido likeado o no
  TextEditingController _commentController = TextEditingController();
  bool isExpanded = false; // Controlar si la descripción está expandida

  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    fetchVideoFromPexels();
    _rotationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 10),
    )..repeat();
  }

  Future<void> fetchVideoFromPexels() async {
    try {
      final pexelsService = PexelsService();
      List<dynamic> videos = await pexelsService.fetchVideos();

      if (videos.isNotEmpty) {
        setState(() {
          videoUrl =
              videos[0]['video_files'][0]['link']; // Obtener la URL del video
          _controller = VideoPlayerController.network(videoUrl!)
            ..initialize().then((_) {
              setState(() {
                _isLoading = false; // El video ya está listo
              });
              _controller.play(); // Iniciar el video automáticamente
            });
        });
      }
    } catch (e) {
      print('Error al cargar los videos: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _commentController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
      likes += isLiked ? 1 : -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Video en el fondo
          Center(
            child: _isLoading || videoUrl == null
                ? CircularProgressIndicator() // Mostrar indicador de carga si el video no está listo
                : GestureDetector(
              onTap: () {
                setState(() {
                  _controller.value.isPlaying
                      ? _controller.pause()
                      : _controller.play();
                });
              },
              child: AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              ),
            ),
          ),

          // Botón de pausa/play centrado
          if (!_isLoading && !_controller.value.isPlaying)
            Center(
              child: Icon(
                Icons.play_arrow,
                color: Colors.white.withOpacity(0.7),
                size: 80.0,
              ),
            ),

          // Descripción, foto de perfil y botones
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Descripción, foto de perfil y botones
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Foto de perfil
                      CircleAvatar(
                        radius: 20.0,
                        backgroundImage: NetworkImage(
                          'https://www.example.com/avatar.jpg', // URL de la foto de perfil
                        ),
                      ),
                      SizedBox(width: 10.0), // Espacio entre avatar y nombre

                      // Columna que incluye el nombre y la descripción
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Nombre
                            Text(
                              'Yordi Diaz',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            // Espaciado entre nombre y descripción
                            SizedBox(height: 20.0),
                            // Descripción con límite de 3 líneas y opción "Ver más"
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  isExpanded = !isExpanded;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(left: 0.0), // Sin padding a la izquierda
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.67, // 3/4 del ancho de la pantalla
                                  child: Text(
                                    'Mi mamá: hijo ve a cumplir tus sueños, yo estaré bien 😊 #mamá #sueños #parati #fyp',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14.0,
                                    ),
                                    maxLines: isExpanded ? null : 3,
                                    overflow: isExpanded
                                        ? TextOverflow.visible
                                        : TextOverflow.ellipsis, // Añade "..." si no está expandido
                                  ),
                                ),
                              ),
                            ),
                            if (!isExpanded)
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isExpanded = true;
                                  });
                                },
                                child: Text(
                                  'Ver más',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 14.0,
                                  ),
                                ),
                              ),

                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 10.0),

                  // Música con ícono giratorio y texto en movimiento
                  Row(
                    children: [
                      RotationTransition(
                        turns: _rotationController,
                        child: CircleAvatar(
                          radius: 16.0,
                          backgroundImage: NetworkImage(
                            'https://www.example.com/music-avatar.jpg', // URL de la imagen del álbum
                          ),
                        ),
                      ),
                      SizedBox(width: 5.0),
                      Expanded(
                        child: MarqueeWidget(
                          text: 'Música de fondo: Canción inspiradora',
                        ),
                      ),
                      Icon(Icons.music_note,
                          color: Colors.white, size: 16.0),
                    ],
                  ),
                  SizedBox(height: 10.0), // Espaciado entre música y campo de comentario

                  // Campo de comentarios
                  Row(
                    children: [
                      Icon(Icons.edit, color: Colors.white),
                      SizedBox(width: 10.0),
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Escribe un comentario...',
                            hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)), // Transparencia para el hint
                            filled: true,
                            fillColor: Colors.transparent, // Fondo transparente
                            contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey, width: 1.0), // Borde gris claro
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: BorderSide(color: Colors.grey, width: 1.0), // Mantiene el borde gris al enfocar
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send, color: Colors.white),
                        onPressed: () {
                          // Acción para enviar comentario
                          print('Comentario: ${_commentController.text}');
                          _commentController.clear();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Botones de acciones a la derecha
          Positioned(
            right: 16.0,
            bottom: 140.0,
            child: Column(
              children: [
                // Botón de likes
                IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.pink : Colors.white,
                    size: 35.0,
                  ),
                  onPressed: toggleLike,
                ),
                Text(
                  '$likes',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                  ),
                ),
                SizedBox(height: 10.0),
                // Botón de comentarios
                IconButton(
                  icon: Icon(
                    Icons.comment,
                    color: Colors.white,
                    size: 35.0,
                  ),
                  onPressed: () {
                    // Acción de comentar
                  },
                ),
                Text(
                  '$comments',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                  ),
                ),
                SizedBox(height: 10.0),
                // Botón de visualizaciones
                IconButton(
                  icon: Icon(
                    Icons.remove_red_eye,
                    color: Colors.white,
                    size: 35.0,
                  ),
                  onPressed: () {
                    // Acción de ver visualizaciones
                  },
                ),
                Text(
                  '$views',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                  ),
                ),
                // Menú de opciones (tres puntos)
                IconButton(
                  icon: Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {
                    // Mostrar opciones adicionales
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


}

// Clase para crear el texto de música en movimiento
class MarqueeWidget extends StatelessWidget {
  final String text;

  MarqueeWidget({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 14.0,
      ),
      overflow:
          TextOverflow.ellipsis, // Para simular movimiento si es necesario
    );
  }
}
