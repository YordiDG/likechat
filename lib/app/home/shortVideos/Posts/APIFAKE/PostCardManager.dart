import 'dart:async';
import 'package:LikeChat/app/home/shortVideos/Posts/APIFAKE/service/MockPostApi.dart';
import 'package:LikeChat/app/home/shortVideos/Posts/APIFAKE/service/MockPostService.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../../../Globales/estadoDark-White/DarkModeProvider.dart';
import '../../../../Globales/skeleton loading/SkeletonLoading.dart';
import '../../../../Globales/skeleton loading/SkeletonService.dart';
import '../eventos/ComentariosPost.dart';
import '../eventos/EtiquetaButton.dart';
import '../eventos/ShareButton.dart';

class PostCardManager extends StatefulWidget {
  @override
  PostCardManagerState createState() => PostCardManagerState();
}

class PostCardManagerState extends State<PostCardManager>
    with SingleTickerProviderStateMixin {
  // Variables de estado
  List<MockPostApi> _posts = [];
  bool _isLoading = true;
  late AnimationController _likeAnimationController;
  late Animation<double> _likeScaleAnimation;
  Map<int, bool> _showLikeAnimation = {};

  // posición del tap
  Map<int, Offset> _doubleTapPositions = {};

  late List<bool> _isReloading;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadPosts();
  }

  // Configuración de animaciones para el efecto de like
  void _setupAnimations() {
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 700),
      // Duración ajustada para más impacto
      vsync: this,
    );

    _likeScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 0.9)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.9, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 20,
      ),
    ]).animate(_likeAnimationController);

    _likeAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _likeAnimationController.reverse();
      }
    });
  }

  // Carga inicial de posts
  Future<void> _loadPosts() async {
    setState(() => _isLoading = true);
    try {
      final posts = await MockPostService.fetchMockPosts();
      setState(() {
        _posts = posts;
        // Initialize _isReloading based on the first post's images
        // or with a default value if there are no posts
        _isReloading = posts.isNotEmpty
            ? List.filled(posts[0].imagePaths.length, false)
            : [];
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading posts: $e');
      setState(() => _isLoading = false);
    }
  }

  // Manejo del doble tap para like
  void _handleDoubleTap(int postIndex, TapDownDetails details) {
    setState(() {
      _showLikeAnimation[postIndex] = true;
      _doubleTapPositions[postIndex] = details.localPosition;
      final post = _posts[postIndex];
      if (!post.isLiked) {
        post.isLiked = true;
        post.likeCount++;
      }
    });
    _likeAnimationController.forward(from: 0.0);
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _showLikeAnimation[postIndex] = false;
        _doubleTapPositions.remove(postIndex);
      });
    });
  }

  // Actualización de un post específico
  void _updatePost(MockPostApi updatedPost) {
    setState(() {
      final index = _posts.indexWhere((post) => post.id == updatedPost.id);
      if (index != -1) {
        _posts[index] = updatedPost;
      }
    });
  }

  //hace la crga cuando hay error
  void _retryLoadingImage(int index) {
    setState(() {
      _isReloading[index] = true; // Marca como en proceso de recarga.
    });

    Future.delayed(const Duration(seconds: 1), () {
      // Simula el tiempo de recarga. En producción, dependerá del comportamiento de `Image.network`.
      setState(() {
        _isReloading[index] = false; // Resetea el estado.
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildPostCardsApi();
  }

  // Construcción de las tarjetas de posts
  Widget _buildPostCardsApi() {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final backgroundColor = darkModeProvider.backgroundColor;

    return SkeletonService.wrap(
      isLoading: _isLoading || _posts.isEmpty,
      skeleton: Column(
        children: List.generate(
          3,
          (index) => _buildPostSkeleton(isDarkMode, backgroundColor),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(_posts.length, (postIndex) {
          final post = _posts[postIndex];
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 5.0, vertical: 2),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: isDarkMode
                      ? Colors.white.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ],
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.4)
                    : Colors.grey.withOpacity(0.3),
                width: 0.2,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header con avatar y nombre de usuario
                Padding(
                  padding:
                      const EdgeInsets.only(left: 12.0, top: 8.0, right: 12.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 19,
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/150?u=${post.id}',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          post.userName,
                          style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: textColor,
                              fontSize: 12),
                        ),
                      ),
                      Text(
                        '• ${post.timeAgo}',
                        style: TextStyle(
                          fontSize: 11.0,
                          color: Colors.grey[600],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, size: 20,),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ),

                // Carrusel de imágenes
                GestureDetector(
                  onDoubleTapDown: (details) {
                    // Maneja el double tap.
                    _handleDoubleTap(post.currentIndex, details);
                  },
                  onDoubleTap: () {},
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
                        color: Colors.black.withOpacity(0.02),
                        child: Stack(
                          alignment: Alignment.center,
                          // Centra los elementos en el stack.
                          children: [
                            if (post.imagePaths.length > 1)
                              CarouselSlider.builder(
                                options: CarouselOptions(
                                  height: constraints.maxWidth * 1.3,
                                  viewportFraction: 1.0,
                                  enableInfiniteScroll: false,
                                  autoPlay: false,
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      post.currentIndex = index;
                                    });
                                  },
                                ),
                                itemCount: post.imagePaths.length,
                                itemBuilder: (context, index, realIndex) {
                                  return _buildImage(constraints,
                                      post.imagePaths[index], index);
                                },
                              )
                            else
                              _buildImage(
                                  constraints, post.imagePaths.first, 0),
                            // Animación de "me gusta" al hacer doble tap.
                            if (_showLikeAnimation[post.currentIndex] == true &&
                                _doubleTapPositions
                                    .containsKey(post.currentIndex))
                              Positioned(
                                left:
                                    _doubleTapPositions[post.currentIndex]!.dx -
                                        30,
                                top:
                                    _doubleTapPositions[post.currentIndex]!.dy -
                                        30,
                                child: ScaleTransition(
                                  scale: _likeScaleAnimation,
                                  child: const Icon(
                                    Icons.favorite,
                                    color: Colors.pinkAccent,
                                    size: 60,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Indicadores de página del carrusel
                if (post.imagePaths.length > 1)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: post.imagePaths.asMap().entries.map((entry) {
                        return Container(
                          width: 5.0,
                          height: 5.0,
                          margin: const EdgeInsets.symmetric(horizontal: 3.0),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: post.currentIndex == entry.key
                                ? Colors.cyan
                                : Colors.grey,
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                // Descripción del post
                if (post.description.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      post.description,
                      style: TextStyle(color: textColor),
                    ),
                  ),
                Divider(height: 1, thickness: 0.1, color: Colors.grey),
                // Barra de acciones (likes y guardados)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    post.isLiked
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color:
                                        post.isLiked ? Colors.red : Colors.grey,
                                  ),
                                  onPressed: () => _updatePost(
                                      post..isLiked = !post.isLiked),
                                ),
                                Text(
                                  '${post.likeCount}',
                                  style: TextStyle(color: textColor),
                                ),
                              ],
                            ),
                            _buildVerticalDivider(),
                            DislikeButtons(
                              onDislikeUpdated: (isDisliked) {
                                print('Dislike button status: $isDisliked');
                              },
                            ),
                            _buildVerticalDivider(),
                            ComentariosPost(),
                            _buildVerticalDivider(),
                            ShareButton(),
                          ],
                        ),
                      ),
                      _buildVerticalDivider(),
                      Padding(
                        padding: const EdgeInsets.only(left: 2.0),
                        child: EtiquetaButton(), // Este se alinea al final.
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  //carag de imagenes
  Widget _buildImage(BoxConstraints constraints, String imagePath, int index) {
    return SizedBox(
      width: constraints.maxWidth,
      height: constraints.maxWidth * 1.3,
      child: Image.network(
        imagePath,
        width: constraints.maxWidth,
        height: constraints.maxWidth * 1.3,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: Lottie.asset(
              'lib/assets/loading/loading_infinity.json',
              width: 40,
              height: 40,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return GestureDetector(
            onTap: () {
              if (!_isReloading[index]) {
                _retryLoadingImage(index); // Intenta recargar la imagen.
              }
            },
            child: Container(
              width: constraints.maxWidth,
              height: constraints.maxWidth * 1.3,
              color: Colors.grey[200],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _isReloading[index]
                        ? CircularProgressIndicator(color: Colors.blueAccent)
                        : Icon(
                            Icons.refresh,
                            size: 40,
                            color: Colors.blueAccent,
                          ),
                    const SizedBox(height: 8),
                    Text(
                      _isReloading[index]
                          ? 'Reintentando...'
                          : 'Error al cargar la imagen.\nToca para intentar de nuevo.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  //linea separadora de los iconos de likes, comentarios, etc
  Widget _buildVerticalDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1.0), // E
      height: 20,
      alignment: Alignment.center,
      child: VerticalDivider(
        thickness: 0.2,
        width: 1,
        color: Colors.grey.shade400,
      ),
    );
  }

  // Construcción del skeleton loading
  Widget _buildPostSkeleton(bool isDarkMode, Color backgroundColor) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 7.0, vertical: 1.4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: isDarkMode
                ? Colors.white.withOpacity(0.1)
                : Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar y nombre
          Padding(
            padding: EdgeInsets.all(12.0),
            child: Row(
              children: [
                const SkeletonLoading(width: 38, height: 38, borderRadius: 19),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonLoading(width: 150, height: 16),
                      SizedBox(height: 4),
                      SkeletonLoading(width: 100, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Imagen
          SkeletonLoading(
            height: MediaQuery.of(context).size.width * 0.8,
            borderRadius: 0,
          ),
          // Botones
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonLoading(width: 80, height: 20),
                Row(
                  children: [
                    SkeletonLoading(width: 60, height: 20),
                    SizedBox(width: 8),
                    SkeletonLoading(width: 60, height: 20),
                    SizedBox(width: 8),
                    SkeletonLoading(width: 60, height: 20),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
  }
}
