import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../APIS-Consumir/DaoPost/PostDatabase.dart';
import '../../../Globales/estadoDark-White/DarkModeProvider.dart';
import '../../../Globales/estadoDark-White/Fuentes/FontSizeProvider.dart';
import '../../../Globales/expandetext/ExpandableText.dart';
import 'OpenCamara/preview/PreviewScreen.dart';
import 'package:provider/provider.dart';
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
  int _currentImageIndex = 0;
  Map<int, bool> _showLikeAnimation = {};

  bool isLiked = false;
  int likeCount = 10;

  bool _isSearchBarVisible = true;
  double _lastScrollOffset = 0.0;

  final PostDatabase _postDatabase = PostDatabase.instance;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _likeAnimationController = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    _likeScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.4)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 60.0,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.4, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 40.0,
      ),
    ]).animate(_likeAnimationController);
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
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
    final darkModeProvider = Provider.of<DarkModeProvider>(context, listen: false);
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
    final XFile? photo = await ImagePicker().pickImage(source: ImageSource.camera);
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
    final darkModeProvider = Provider.of<DarkModeProvider>(context, listen: false);
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
      List<String> imagePaths = pickedImages.map((image) => image.path).toList();
      setState(() {
        _imagePaths = imagePaths; // Cambiar _imagePath por _imagePaths como Lista
      });
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PreviewScreen(
          imagePaths: _imagePaths!, // Actualizar para pasar lista de imágenes
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

  Widget _buildPublishedPostCards() {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final backgroundColor = darkModeProvider.backgroundColor;
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    print('Building published post cards');
    print('Number of posts: ${_posts.length}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(_posts.length, (postIndex) {
        final post = _posts[postIndex];

        // Log para verificar las imágenes de cada post
        print('Post $postIndex - Number of images: ${post.imagePaths.length}');
        print('Post $postIndex - Image paths: ${post.imagePaths}');

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 7.0, vertical: 1.4),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8.0),
            boxShadow: [
              BoxShadow(
                color: isDarkMode ? Colors.white.withOpacity(0.1) : Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 6,
                offset: Offset(0, 3),
              )
            ],
            border: Border.all(
              color: isDarkMode ? Colors.grey.withOpacity(0.2) : Colors.grey.withOpacity(0.3),
              width: 0.6,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              Padding(
                padding: const EdgeInsets.only(left: 12.0, top: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 38.0, // Doble del radio
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
                          fit: BoxFit.contain, // Ajusta la imagen para que encaje completamente.
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
                                    fontSize: fontSizeProvider.fontSize + 1,
                                    fontWeight: FontWeight.bold,
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
                                  fontSize: 12.0,
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
                      icon:
                      Icon(Icons.more_vert, size: 23.0, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (post.imagePaths.isNotEmpty)
                StatefulBuilder(
                  builder: (context, setState) {
                    int currentIndex = 0;
                    bool showIndicators = true;
                    Timer? hideTimer;

                    void resetHideTimer() {
                      if (hideTimer != null) {
                        hideTimer!.cancel();
                      }
                      hideTimer = Timer(Duration(seconds: 3), () {
                        setState(() {
                          showIndicators = false;
                        });
                      });
                    }

                    return GestureDetector(
                      onPanStart: (_) {
                        setState(() {
                          showIndicators = true;
                        });
                        resetHideTimer();
                      },
                      onDoubleTap: () {
                        _handleDoubleTap(postIndex);
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          post.imagePaths.length > 1
                              ? CarouselSlider(
                            options: CarouselOptions(
                              height: MediaQuery.of(context).size.width * 0.8,
                              viewportFraction: 1.0,
                              enableInfiniteScroll: false,
                              autoPlay: false,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _currentImageIndex = index;
                                });
                              },
                            ),
                            items: post.imagePaths.map((path) {
                              return Image.file(
                                File(path),
                                width: double.infinity,
                                fit: BoxFit.cover,
                              );
                            }).toList(),
                          )
                              : Image.file(
                            File(post.imagePaths.first),
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          if (showIndicators && post.imagePaths.length > 1)
                            Positioned(
                              bottom: 10.0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(post.imagePaths.length, (index) {
                                  return Container(
                                    width: 8.0,
                                    height: 8.0,
                                    margin: EdgeInsets.symmetric(horizontal: 4.0),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: index == currentIndex
                                          ? Colors.white
                                          : Colors.grey,
                                    ),
                                  );
                                }),
                              ),
                            ),
                          if (showIndicators && post.imagePaths.length > 1)
                            Positioned(
                              top: 8.0,
                              right: 8.0,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Text(
                                  '${currentIndex + 1}/${post.imagePaths.length}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.0,
                                  ),
                                ),
                              ),
                            ),
                          if (_showLikeAnimation[postIndex] ?? false)
                            ScaleTransition(
                              scale: _likeScaleAnimation,
                              child: Icon(
                                Icons.favorite,
                                color: Colors.white,
                                size: 40.0,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              Divider(
                height: 1,
                thickness: 0.3,
                color: Colors.grey,
              ),
              SizedBox(height: 2),
              if (post.description.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 9.0),
                  child: ExpandableText(
                    text: post.description,
                  ),
                ),
                SizedBox(height: 2),
                Divider(height: 1, thickness: 0.1, color: Colors.grey),
              ],
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Likes(
                          post: post,
                          onLikeUpdated: _updatePost,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        ComentariosPost(),
                        SizedBox(width: 10),
                        ShareButton(),
                        EtiquetaButton(),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
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

  void _handleDoubleTap(int postIndex) {
    // Solo dar like si no está marcado como "liked"
    if (!_posts[postIndex].isLiked) {
      _handleLike(_posts[postIndex]);
    }

    setState(() {
      _showLikeAnimation[postIndex] = true;
    });

    _likeAnimationController.forward(from: 0.0).then((_) {
      setState(() {
        _showLikeAnimation[postIndex] = false;
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
    // Agregar el parámetro Post
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
                onTap: () async {
                  print(
                      'postToEdit: $postToEdit'); // Verifica si el objeto es null
                  if (postToEdit != null && postToEdit.id != null) {
                    await PostDatabase.instance.deletePost(postToEdit.id!);
                    await _loadPosts();
                    Navigator.pop(context);
                  } else {
                    print('El objeto postToEdit o su ID es nulo');
                  }
                },
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final backgroundColor = darkModeProvider.backgroundColor;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 300),
                height: _isSearchBarVisible ? 50.0 : 0.0,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14.0,
                    vertical: 8.0,
                  ),
                  child: _buildSearchBar(isDarkMode, backgroundColor),
                ),
              ),
              Expanded(
                child: NotificationListener<ScrollNotification>(
                  onNotification: (scrollNotification) {
                    if (scrollNotification is ScrollUpdateNotification) {
                      _onScroll(scrollNotification.metrics.pixels);
                    }
                    return false;
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildPublishedPostCards(),
                      ],
                    ),
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
    );
  }

  // Continuación de la clase _PostClassState
  Widget _buildSearchBar(bool isDarkMode, Color backgroundColor) {
    return Container(
      color: Colors.transparent,
      height: 38.0,
      child: TextField(
        controller: _searchController,
        cursorColor: Colors.cyan,
        decoration: InputDecoration(
          hintText: 'Buscar amigo',
          hintStyle: TextStyle(
            color: isDarkMode ? Colors.grey[500] : Colors.grey[700],
            fontSize: 12.0,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.white, width: 0.8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: isDarkMode ? Colors.grey : Colors.grey[400]!,
              width: 0.8,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: Colors.cyan, width: 0.8),
          ),
          filled: true,
          fillColor: backgroundColor,
          contentPadding:
          EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
          prefixIcon: Icon(
            Icons.search,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
          ),
        ),
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        onChanged: (value) {
          // Implementar lógica de búsqueda aquí
        },
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
  bool isLiked; // Added back
  int likeCount; // Added back

  Post({
    this.id,
    required this.description,
    required this.imagePaths,
    DateTime? createdAt,
    this.userName = '',
    this.userAvatar = 'lib/assets/avatar.png',
    this.isLiked = false, // Default value
    this.likeCount = 0, // Default value
  }) : this.createdAt = createdAt ?? DateTime.now();

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
