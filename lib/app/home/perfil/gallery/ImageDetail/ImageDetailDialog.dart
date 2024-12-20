import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:blur/blur.dart';
import 'package:device_apps/device_apps.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../../../Globales/estadoDark-White/DarkModeProvider.dart';
import 'package:http/http.dart' as http;

import '../../../shortVideos/Posts/eventos/ComentariosPost.dart';
import '../../../shortVideos/Posts/eventos/EtiquetaButton.dart';
import '../../../shortVideos/Posts/eventos/ShareButton.dart';

class ImageDetailScreen extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImageDetailScreen({
    Key? key,
    required this.imageUrls,
    required this.initialIndex,
  }) : super(key: key);

  @override
  _ImageDetailScreenState createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends State<ImageDetailScreen> with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;
  List<int> _likeCounts = []; // Nuevo: contador de likes para cada imagen
  List<bool> _likedImages = [];
  List<Map<String, String>> friends = [];
  List<ApplicationWithIcon> installedApps = [];
  bool isLoading = true;

  bool _showHeart = false;
  late AnimationController _heartAnimationController;
  late Animation<double> _heartAnimation;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Inicializar contadores y estados de like
    _likeCounts = List.filled(widget.imageUrls.length, 0);
    _likedImages = List.filled(widget.imageUrls.length, false);

    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _heartAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _heartAnimationController,
        curve: Curves.easeOutCubic,
      ),
    );

    fetchFriends();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _heartAnimationController.dispose();
    super.dispose();
  }

  void _handleDoubleTap() {
    setState(() {
      if (!_likedImages[_currentIndex]) {
        _likeCounts[_currentIndex]++;
        _likedImages[_currentIndex] = true;
      }
      _showHeart = true;
    });

    _heartAnimationController.forward(from: 0).then((_) {
      setState(() {
        _showHeart = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final backgroundColor = darkModeProvider.backgroundColor;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
    ));

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemCount: widget.imageUrls.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          return LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onDoubleTap: _handleDoubleTap,
                child: Stack(
                  children: [
                    // Blurred background for small images
                    _buildImageWithBlur(index),

                    // Imagen principal
                    _buildImageContent(index, isDarkMode, textColor, iconColor),

                    // Animación del corazón central
                    if (_showHeart && index == _currentIndex)
                      Center(
                        child: AnimatedBuilder(
                          animation: _heartAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: 1.0 + (_heartAnimation.value * 0.3),
                              child: Opacity(
                                opacity: 1.0 - _heartAnimation.value,
                                child: SizedBox(
                                  width: 180,
                                  height: 180,
                                  child: Lottie.asset(
                                    'lib/assets/heart.json',
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  //formato de tamaño
  Future<Size> _getImageSize(String imageUrl) async {
    final Completer<Size> completer = Completer();
    final image = NetworkImage(imageUrl);
    image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener(
            (ImageInfo info, bool _) {
          completer.complete(Size(
            info.image.width.toDouble(),
            info.image.height.toDouble(),
          ));
        },
      ),
    );
    return completer.future;
  }

  //Header
  Widget _buildCustomAppBar(BuildContext context, bool isDarkMode, Color textColor, Color iconColor) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back_ios, size: 20, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('lib/assets/placeholder_user.jpg'),
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
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(width: 6),
                  Text(
                    '•',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    '2h',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.more_vert, size: 22, color: Colors.white),
              onPressed: () => mostrarOpcionesModal(
                context,
                isDarkMode,
                textColor,
                iconColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //imagens
  FutureBuilder<Size> _buildImageWithBlur(int index) {
    return FutureBuilder<Size>(
      future: _getImageSize(widget.imageUrls[index]),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Container();

        final imageRatio = snapshot.data!.width / snapshot.data!.height;
        final isSmallImage = imageRatio <= 16 / 9;

        if (isSmallImage) {
          return Positioned.fill(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Image.network(
                widget.imageUrls[index],
                fit: BoxFit.cover,
                opacity: AlwaysStoppedAnimation(0.3),
              ),
            ),
          );
        }
        return Container();
      },
    );
  }

  //seccion de comentarios like
  Widget _buildImageContent(int index, bool isDarkMode, Color textColor, Color iconColor) {
    return Column(
      children: [
        _buildCustomAppBar(context, isDarkMode, textColor, iconColor),
        Expanded(
          child: Center(
            child: Image.network(
              widget.imageUrls[index],
              fit: BoxFit.contain,
            ),
          ),
        ),
        _buildLikeCommentShareSection(index),
        _buildCommentInputSection(),
      ],
    );
  }

  Widget _buildLikeCommentShareSection(int index) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  // Botón de like modificado
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        if (_likedImages[index]) {
                          _likeCounts[index]--;
                        } else {
                          _likeCounts[index]++;
                        }
                        _likedImages[index] = !_likedImages[index];
                      });
                    },
                    child: Row(
                      children: [
                        Icon(
                          _likedImages[index]
                              ? FontAwesomeIcons.solidHeart
                              : FontAwesomeIcons.heart ,
                          color: _likedImages[index]
                              ? Color(0xFFFF0000)
                              : Colors.white,
                          size: 30,
                        ),
                        SizedBox(width: 8),
                        Text(
                          '${_likeCounts[index]}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  ComentariosPost(),
                  ShareButton(),
                  EtiquetaButton(),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommentInputSection() {
    return Container(
      color: Colors.black.withOpacity(0.6),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 30.0,
          vertical: 15,
        ),
        child: Row(
          children: [
            Icon(
              FontAwesomeIcons.userPen,
              size: 20,
              color: Colors.grey,
            ),
            SizedBox(width: 20),
            Text(
              'Añade un comentario...',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

// Método para obtener los amigos desde la API
  Future<void> fetchFriends() async {
    try {
      final response =
          await http.get(Uri.parse('https://randomuser.me/api/?results=50'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          friends = (data['results'] as List).map<Map<String, String>>((user) {
            return {
              "name": "${user['name']['first']} ${user['name']['last']}",
              "image": user['picture']['medium'],
            };
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load friends');
      }
    } catch (error) {
      print('Error: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

// Método para mostrar las opciones en el modal
  void mostrarOpcionesModal(
      BuildContext context, bool isDarkMode, Color textColor, Color iconColor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      backgroundColor:
          isDarkMode ? Colors.grey.shade900.withOpacity(0.8) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height *
              0.6, // Menos de media pantalla
          child: Column(
            children: [
              // Encabezado del modal
              Container(
                decoration: BoxDecoration(
                  color:
                      isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(13)),
                ),
                child: Row(
                  children: [
                    // Espacio expandible que centra el texto
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Compartir con",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          SizedBox(width: 3), // Espacio entre el texto y el icono
                          Icon(
                            Icons.arrow_drop_down,
                            size: 20,
                            color: textColor,
                          ),
                        ],
                      ),
                    ),
                    // Ícono de cerrar alineado a la derecha
                    IconButton(
                      icon: Container(
                        width: 23, // Ajusta el tamaño del círculo
                        height: 23,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.3), // Color opaco
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          size: 17,
                          color: iconColor,
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    )
                  ],
                ),
              ),

              // Lista de amigos desplazable en un GridView
              Expanded(
                child: isLoading
                    ? Center(
                        child: Lottie.asset(
                          'lib/assets/loading/infinity_cyan.json',
                          width: 60,
                          height: 60,
                        ),
                      ) // Muestra un indicador de carga mientras se obtienen los amigos
                    : GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4, // Muestra 4 elementos por fila
                          crossAxisSpacing: 8.0, // Espacio entre columnas
                          mainAxisSpacing: 2.0, // Espacio entre filas
                          childAspectRatio:
                              0.8, // Ajusta el tamaño de cada ítem
                        ),
                        itemCount: friends.length,
                        itemBuilder: (context, index) {
                          final friend =
                              friends[index]; // Obtén los datos de cada amigo
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage:
                                      NetworkImage(friend['image'] ?? ''),
                                  backgroundColor: isDarkMode
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade300,
                                ),
                                SizedBox(height: 8),
                                // Nombre con texto grande, en dos líneas y elipses si es largo
                                Expanded(
                                  // Esto asegura que el texto se ajuste sin desbordamiento
                                  child: Text(
                                    friend['name'] ?? 'Nombre no disponible',
                                    style: TextStyle(
                                      fontSize: 12, // Tamaño grande
                                      color: textColor,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2, // Permitir 2 líneas
                                    overflow: TextOverflow
                                        .ellipsis, // Elipses si excede
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              Container(
                color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
                padding: const EdgeInsets.symmetric(vertical: 9.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(width: 4),
                      _crearOpcionModal(Icons.link, 'Copiar\nenlace'),
                      _crearOpcionModal(Icons.reply, 'Compartir\n'),
                      _crearOpcionModal(Icons.crop, 'Crear un\nsticker'),
                      _crearOpcionModal(Icons.campaign, 'Promocionar'),
                      _crearOpcionModal(
                          Icons.visibility_off, 'Ocultar\npublicación'),
                      _crearOpcionModal(Icons.archive, 'Archivar'),
                      _crearOpcionModal(Icons.video_collection,
                          'Añadir a la\n lista de reproducción'),
                      _crearOpcionModal(Icons.bookmark, 'Guardar'),
                      _crearOpcionModal(Icons.history, 'Añadir a\nhistoria'),
                      _crearOpcionModal(
                          FontAwesomeIcons.comment, 'Desactivar\ncomentarios'),
                      _crearOpcionModal(Icons.edit, 'Editar'),
                      _crearOpcionModal(Icons.bar_chart, 'Ver\nestadísticas'),
                      _crearOpcionModal(Icons.push_pin, 'Fijar en\nperfil'),
                      _crearOpcionModal(Icons.delete, 'Eliminar'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// Widget para opciones con íconos y texto en dos líneas
  Widget _crearOpcionModal(IconData icon, String texto) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1.0),
      child: SizedBox(
        width: 60, // Tamaño fijo para cada ítem
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 23,
              backgroundColor:
                  isDarkMode ? Colors.grey.withOpacity(0.2) : Colors.white,
              child: Icon(icon,
                  size: 23,
                  color: isDarkMode ? Colors.white70 : Colors.black87),
            ),
            SizedBox(height: 4),
            SizedBox(
              height: 36, // Espacio fijo para el texto
              child: Text(
                texto,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 2, // Limitar a dos líneas
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
