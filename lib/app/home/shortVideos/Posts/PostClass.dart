import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import '../../../APIS-Consumir/DaoPost/PostDatabase.dart';
import '../../../Globales/Connections/NetworkProvider.dart';
import '../../../Globales/estadoDark-White/DarkModeProvider.dart';
import '../../../Globales/estadoDark-White/Fuentes/FontSizeProvider.dart';
import '../../../Globales/expandetext/ExpandableText.dart';
import '../../../Globales/skeleton loading/SkeletonLoading.dart';
import '../../../Globales/skeleton loading/SkeletonService.dart';
import 'APIFAKE/PostCardManager.dart';
import 'OpenCamara/preview/PreviewScreen.dart';
import 'package:provider/provider.dart';
import 'detailPost/PostDetailView.dart';
import 'eventos/ComentariosPost.dart';
import 'eventos/EtiquetaButton.dart';
import 'eventos/Likes.dart';
import 'eventos/ShareButton.dart';

class PostClass extends StatefulWidget {
  @override
  _PostClassState createState() => _PostClassState();
}

class _PostClassState extends State<PostClass>
    with SingleTickerProviderStateMixin {
  TextEditingController _searchController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  List<String>? _imagePaths; // Cambiar de String? a List<String>?
  List<Post> _posts = [];

  bool _permissionsDeniedMessageShown = false;
  late AnimationController _likeAnimationController;
  late Animation<double> _likeScaleAnimation;
  Map<int, bool> _showLikeAnimation = {};

  bool isLiked = false;
  int likeCount = 10;

  bool _isSearchBarVisible = true;
  double _lastScrollOffset = 0.0;

  bool _isLoading = true; //variable que regua el skeleton o contenido

  final PostDatabase _postDatabase = PostDatabase.instance;

  // posición del tap
  Map<int, Offset> _doubleTapPositions = {};

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _loadInitialPosts();
    fetchPosts();
    _setupAnimations();

  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  void _onScroll(double offset) {
    if (offset > _lastScrollOffset && _isSearchBarVisible) {
      setState(() {
        _isSearchBarVisible = false;
      });
    } else if (offset < _lastScrollOffset && !_isSearchBarVisible) {
      setState(() {
        _isSearchBarVisible = true;
      });
    }
    _lastScrollOffset = offset;
  }

  void _showImageSourceSelection() {
    final darkModeProvider =
        Provider.of<DarkModeProvider>(context, listen: false);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Seleccionar Imágenes',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    icon: Icons.camera_alt,
                    label: 'Cámara',
                    onTap: () {
                      Navigator.pop(context);
                      _takePicture();
                    },
                    color: Colors.cyan,
                  ),
                  _buildImageSourceOption(
                    icon: Icons.photo_library,
                    label: 'Galería',
                    onTap: () {
                      Navigator.pop(context);
                      _selectImages();
                    },
                    color: Colors.red,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // Método para tomar foto con la cámara
  void _takePicture() async {
    final XFile? photo =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _imagePaths = [photo.path];
      });
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PreviewScreen(
          imagePaths: _imagePaths!,
          descriptionController: _descriptionController,
          onPublish: _publishPost,
        ),
      ));
    }
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    final darkModeProvider =
        Provider.of<DarkModeProvider>(context, listen: false);
    final textColor = darkModeProvider.textColor;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 30.0,
            ),
          ),
          SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _selectImages() async {
    final List<XFile>? pickedImages = await ImagePicker().pickMultiImage();
    if (pickedImages != null && pickedImages.isNotEmpty) {
      List<String> imagePaths =
          pickedImages.map((image) => image.path).toList();
      setState(() {
        _imagePaths =
            imagePaths; // Cambiar _imagePath por _imagePaths como Lista
      });
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PreviewScreen(
          imagePaths: _imagePaths!,
          // Actualizar para pasar lista de imágenes
          descriptionController: _descriptionController,
          onPublish: _publishPost,
        ),
      ));
    }
  }

  // Modificar el método _publishPost
  void _publishPost() async {
    String description = _descriptionController.text;
    List<String> imagePaths = _imagePaths ?? [];

    if (description.isNotEmpty || imagePaths.isNotEmpty) {
      Post newPost = Post(
        description: description,
        imagePaths: imagePaths,
      );

      await PostDatabase.instance.createPost(newPost);
      await _loadPosts();

      _descriptionController.clear();
      _imagePaths = null;
      Navigator.pop(context);
    }
  }

  //card de podt
  Widget _buildPublishedPostCards() {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final backgroundColor = darkModeProvider.backgroundColor;
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return SkeletonService.wrap(
      isLoading: _isLoading || _posts.isEmpty,
      skeleton: Column(
        children: List.generate(
            3, (index) => _buildPostSkeleton(isDarkMode, backgroundColor)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: List.generate(_posts.length, (postIndex) {
          final post = _posts[postIndex];

          return Container(
            margin: EdgeInsets.symmetric(horizontal: 5.0, vertical: 2),
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
              border: Border.all(
                color: isDarkMode
                    ? Colors.white.withOpacity(0.4)
                    : Colors.grey.withOpacity(0.3),
                width: 0.1,
              ),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 12.0, top: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 38.0,
                            height: 38.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey,
                                width: 0.5,
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'lib/assets/avatar/avatar.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.0),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        post.userName.isEmpty
                                            ? 'Yordi Gonzales'
                                            : post.userName,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: textColor,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    SizedBox(width: 8.0),
                                    Text(
                                      '• ${post.timeAgo}',
                                      style: TextStyle(
                                        fontSize: 13.0,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                _showPostOptionsBottomSheet(context, post),
                            icon: Icon(Icons.more_vert,
                                size: 23.0, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    if (post.imagePaths.isNotEmpty)
                      StatefulBuilder(
                        builder: (context, setCarouselState) {
                          return Consumer<NetworkProvider>(
                              builder: (context, network, child) {
                            return GestureDetector(
                              onDoubleTapDown: (details) =>
                                  _handleDoubleTap(postIndex, details),
                              onDoubleTap: () {},
                              child: LayoutBuilder(
                                builder: (context, constraints) {
                                  return Container(
                                    color: Colors.black.withOpacity(0.02),
                                    child: Column(
                                      children: [
                                        Stack(
                                          children: [
                                            if (post.imagePaths.length > 1)
                                              CarouselSlider.builder(
                                                options: CarouselOptions(
                                                  height: constraints.maxWidth *
                                                      1.3,
                                                  viewportFraction: 1.0,
                                                  enableInfiniteScroll: false,
                                                  autoPlay: false,
                                                  onPageChanged:
                                                      (index, reason) {
                                                    setCarouselState(() {
                                                      post.currentIndex = index;
                                                      post.showControls = true;
                                                      post.controlsTimer
                                                          ?.cancel();
                                                      post.controlsTimer =
                                                          Timer(
                                                        const Duration(
                                                            seconds: 1),
                                                        () {
                                                          setCarouselState(() {
                                                            post.showControls =
                                                                false;
                                                          });
                                                        },
                                                      );
                                                    });
                                                  },
                                                ),
                                                itemCount:
                                                    post.imagePaths.length,
                                                itemBuilder: (context, index,
                                                    realIndex) {
                                                  return SizedBox(
                                                    width: constraints.maxWidth,
                                                    height:
                                                        constraints.maxWidth *
                                                            1.3,
                                                    child: Stack(
                                                      children: [
                                                        // Imagen de baja resolución con desenfoque
                                                        Image.file(
                                                          File(post.imagePaths[
                                                              index]),
                                                          width: constraints
                                                              .maxWidth,
                                                          height: constraints
                                                                  .maxWidth *
                                                              1.3,
                                                          fit: BoxFit.cover,
                                                          cacheWidth: 32,
                                                          frameBuilder: (context,
                                                              child,
                                                              frame,
                                                              wasSynchronouslyLoaded) {
                                                            return ClipRect(
                                                              child:
                                                                  ImageFiltered(
                                                                imageFilter:
                                                                    ImageFilter
                                                                        .blur(
                                                                  sigmaX: frame ==
                                                                          null
                                                                      ? 15
                                                                      : 0,
                                                                  sigmaY: frame ==
                                                                          null
                                                                      ? 15
                                                                      : 0,
                                                                ),
                                                                child: child,
                                                              ),
                                                            );
                                                          },
                                                        ),
                                                        // Imagen principal con fade in
                                                        Image.file(
                                                          File(post.imagePaths[
                                                              index]),
                                                          width: constraints
                                                              .maxWidth,
                                                          height: constraints
                                                                  .maxWidth *
                                                              1.3,
                                                          fit: BoxFit.cover,
                                                          frameBuilder: (context,
                                                              child,
                                                              frame,
                                                              wasSynchronouslyLoaded) {
                                                            if (wasSynchronouslyLoaded)
                                                              return child;

                                                            return Stack(
                                                              children: [
                                                                AnimatedOpacity(
                                                                  opacity:
                                                                      frame !=
                                                                              null
                                                                          ? 1.0
                                                                          : 0.0,
                                                                  duration: const Duration(
                                                                      milliseconds:
                                                                          500),
                                                                  curve: Curves
                                                                      .easeOut,
                                                                  child: child,
                                                                ),
                                                                if (frame ==
                                                                    null)
                                                                  Center(
                                                                    child:
                                                                        SizedBox(
                                                                      width: 50,
                                                                      height:
                                                                          50,
                                                                      child:
                                                                          CircularProgressIndicator(
                                                                        strokeWidth:
                                                                            2.5,
                                                                        backgroundColor:
                                                                            Colors.grey[400],
                                                                        valueColor:
                                                                            const AlwaysStoppedAnimation(Colors.white),
                                                                      ),
                                                                    ),
                                                                  ),
                                                              ],
                                                            );
                                                          },
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              )
                                            else
                                              SizedBox(
                                                width: constraints.maxWidth,
                                                child: Image.file(
                                                  File(post.imagePaths.first),
                                                  width: constraints.maxWidth,
                                                  fit: BoxFit.contain,
                                                ),
                                              ),

                                            // Contador con animación mejorada
                                            if (post.imagePaths.length > 1)
                                              Positioned(
                                                top: 16.0,
                                                right: 16.0,
                                                child: AnimatedOpacity(
                                                  opacity: post.showControls
                                                      ? 1.0
                                                      : 0.0,
                                                  duration: Duration(
                                                      milliseconds: 200),
                                                  child: Container(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 10.0,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.black
                                                          .withOpacity(0.4),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12.0),
                                                    ),
                                                    child: Text(
                                                      '${post.currentIndex + 1}/${post.imagePaths.length}',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 13.0,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            // Icono de detalle en la parte inferior derecha
                                            Positioned(
                                              bottom: 16.0,
                                              right: 16.0,
                                              child: Container(
                                                width: 30.0,
                                                height: 30.0,
                                                decoration: BoxDecoration(
                                                  color: Colors.black.withOpacity(0.3),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: IconButton(
                                                  icon: Icon(
                                                    Icons.fullscreen,
                                                    color: Colors.white,
                                                    size: 25.0,
                                                  ),
                                                  padding: EdgeInsets.zero, // Elimina el padding interno del IconButton
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) => PostDetailView(
                                                          post: post,
                                                          onLikeUpdated: _updatePost,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),

                                          ],
                                        ),

                                        // Dots actualizados y movidos fuera del Stack
                                        if (post.imagePaths.length > 1)
                                          Container(
                                            padding: EdgeInsets.only(top: 4.0, bottom: 4.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: List.generate(
                                                    post.imagePaths.length,
                                                        (index) {
                                                      bool isActive = index == post.currentIndex;
                                                      bool shouldShow = true;

                                                      // Lógica para mostrar un rango dinámico de 5 dots
                                                      if (post.imagePaths.length > 5) {
                                                        int visibleRangeStart;

                                                        // Calculamos el inicio del rango dinámico
                                                        if (post.currentIndex < 2) {
                                                          // Al inicio del carrusel (primeras 2 imágenes)
                                                          visibleRangeStart = 0;
                                                        } else if (post.currentIndex > post.imagePaths.length - 3) {
                                                          // Al final del carrusel (últimas 2 imágenes)
                                                          visibleRangeStart = post.imagePaths.length - 5;
                                                        } else {
                                                          // En el medio del carrusel
                                                          visibleRangeStart = post.currentIndex - 2;
                                                        }

                                                        // Verificamos si el índice actual está dentro del rango visible
                                                        shouldShow = index >= visibleRangeStart && index < visibleRangeStart + 5;
                                                      }

                                                      if (!shouldShow) return SizedBox.shrink();

                                                      return AnimatedOpacity(
                                                        duration: Duration(milliseconds: 200),
                                                        opacity: 1.0,
                                                        child: AnimatedContainer(
                                                          duration: Duration(milliseconds: 200),
                                                          width: isActive ? 5.0 : 4.0,
                                                          height: isActive ? 5.0 : 4.0,
                                                          margin: EdgeInsets.symmetric(horizontal: 3.0),
                                                          decoration: BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            color: isActive
                                                                ? Colors.cyan
                                                                : Colors.grey.withOpacity(0.5),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          });
                        },
                      ),
                    if (post.description.isNotEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3.0),
                        child: ExpandableText(text: post.description),
                      ),
                      SizedBox(height: 2),
                      Divider(height: 1, thickness: 0.1, color: Colors.grey),
                    ],
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Likes(post: post, onLikeUpdated: _updatePost),
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
                            child: EtiquetaButton(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
        }),
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

  //llama al skeleton
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

  //carga los dtos de la api
  void fetchPosts() async {
    setState(() => _isLoading = true);

    try {
      // Simulate network delay
      await Future.delayed(Duration(seconds: 2));

      // Fetch your posts here
      final posts = await SkeletonService.getPosts();

      setState(() {
        _posts = posts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Handle error appropriately
    }
  }

  Future<void> _loadPosts() async {
    try {
      final posts = await _postDatabase.getAllPosts();
      setState(() {
        _posts = posts;
      });
    } catch (e) {
      print('Error loading posts: $e');
    }
  }

  void _updatePost(Post updatedPost) {
    setState(() {
      final index = _posts.indexWhere((post) => post.id == updatedPost.id);
      if (index != -1) {
        _posts[index] = updatedPost;
      }
    });
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

  void _handleLike(Post post) {
    setState(() {
      if (!post.isLiked) {
        post.isLiked = true;
        post.likeCount += 1;
      }
    });

    // Optional: Update the post in the database
    PostDatabase.instance.updatePost(post);
  }

  void _showPostOptionsBottomSheet(BuildContext context, Post postToEdit) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(17)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Opciones de publicación',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.edit),
                title: Text('Editar publicación'),
                onTap: () {
                  Navigator.pop(context);
                  // Aquí puedes agregar la lógica para editar
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Eliminar publicación'),
                onTap: () {
                  Navigator.pop(context); // Cierra el BottomSheet
                  _showDeleteConfirmationDialog(context, postToEdit);
                },
              )
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, Post postToEdit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          // Fondo blanco
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            '¿Eliminar publicación?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
            textAlign: TextAlign.center,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Si eliminas esta publicación, no podrás recuperarla. ¿Estás seguro de que deseas continuar?',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black87,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        if (postToEdit.id != null) {
                          try {
                            await PostDatabase.instance
                                .deletePost(postToEdit.id!);
                            await _loadPosts();

                            // Mostrar un Fluttertoast al eliminar exitosamente
                            Fluttertoast.showToast(
                              msg: "Publicación eliminada exitosamente",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.grey.shade900,
                              textColor: Colors.white,
                              fontSize: 14.0,
                            );
                          } catch (e) {
                            // Mostrar un Fluttertoast en caso de error
                            Fluttertoast.showToast(
                              msg: "Error al eliminar la publicación",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.red.shade600,
                              textColor: Colors.white,
                              fontSize: 14.0,
                            );
                          }
                        }
                      },
                      child: const Text(
                        'Eliminar',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          actionsPadding: EdgeInsets.zero,
        );
      },
    );
  }

  Future<void> _loadInitialPosts() async {
    setState(() => _isLoading = true);
    await Future.delayed(
        const Duration(milliseconds: 500)); // Simular carga inicial
    setState(() => _isLoading = false);
  }

  Future<void> _refreshPosts() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500)); // Simular refresh
    setState(() => _isLoading = false);
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final backgroundColor = darkModeProvider.backgroundColor;

    return RefreshIndicator(
      onRefresh: _refreshPosts,
      color: Colors.cyan, // Cambia el color del indicador de progreso
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scrollNotification) {
                      if (scrollNotification is ScrollUpdateNotification) {
                        _onScroll(scrollNotification.metrics.pixels);
                      }
                      return false;
                    },
                    child: RefreshIndicator(
                      onRefresh: _refreshPosts,
                      color: Colors.cyan, // Color del RefreshIndicator
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildPublishedPostCards(),
                            PostCardManager(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                if (_isLoading)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Lottie.asset(
                        'lib/assets/loading/loading_infinity.json',
                        width: 40,
                        height: 40,
                      ),
                    ),
                  ),
              ],
            ),
            Positioned(
              bottom: 38.0,
              right: 18.0,
              child: _buildCameraButton(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraButton() {
    return Container(
      width: 55.0,
      height: 55.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.cyan,
      ),
      child: FloatingActionButton(
        onPressed: _showImageSourceSelection,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Icon(
          Icons.camera_alt,
          color: Colors.white,
          size: 35.0,
        ),
      ),
    );
  }
}

// Clase Post actualizada con todos los campos necesarios
class Post {
  final int? id;
  final String description;
  final List<String> imagePaths;
  final DateTime createdAt;
  final String userName;
  final String userAvatar;
  bool isLiked;
  int likeCount;

  // Estado del carrusel
  int currentIndex = 0;
  int currentPostIndex = 0;
  bool showControls = false;
  bool hasInteracted = false;
  Timer? controlsTimer;

  Post({
    this.id,
    required this.description,
    required this.imagePaths,
    DateTime? createdAt,
    this.userName = '',
    this.userAvatar = 'lib/assets/avatar.png',
    this.isLiked = false,
    this.likeCount = 0,
  }) : this.createdAt = createdAt ?? DateTime.now();

  void resetControlsTimer() {
    controlsTimer?.cancel();
    showControls = true;
    controlsTimer = Timer(const Duration(seconds: 1), () {
      showControls = false;
    });
  }

  void startControlsTimer() {
    controlsTimer?.cancel();
    controlsTimer = Timer(const Duration(seconds: 1), () {
      showControls = false;
    });
  }

  // Método para actualizar el índice actual
  void updateCurrentIndex(int newIndex) {
    if (newIndex >= 0 && newIndex < imagePaths.length) {
      currentIndex = newIndex;
    }
  }

  void dispose() {
    controlsTimer?.cancel();
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Ahora';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}sem';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}m';
    } else {
      return '${(difference.inDays / 365).floor()}a';
    }
  }
}
