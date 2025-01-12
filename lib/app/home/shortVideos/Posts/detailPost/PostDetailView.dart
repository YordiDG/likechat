import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../../../../APIS-Consumir/DaoPost/PostDatabase.dart';
import '../../../../Globales/estadoDark-White/DarkModeProvider.dart';
import '../../../../Globales/expandetext/ExpandableText.dart';
import '../PostClass.dart';
import '../eventos/ComentariosPost.dart';
import '../eventos/EtiquetaButton.dart';
import '../eventos/Likes.dart';
import '../eventos/ShareButton.dart';

class PostDetailView extends StatefulWidget {
  final Post post;
  final Function(Post) onLikeUpdated;

  const PostDetailView({
    Key? key,
    required this.post,
    required this.onLikeUpdated,
  }) : super(key: key);

  @override
  _PostDetailViewState createState() => _PostDetailViewState();
}

class _PostDetailViewState extends State<PostDetailView> with SingleTickerProviderStateMixin {
  late AnimationController _likeAnimationController;
  bool _showLikeAnimation = false;
  List<Post> _posts = [];
  final PostDatabase _postDatabase = PostDatabase.instance;
  int currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _likeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    super.dispose();
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

  void _handleDoubleTap() {
    setState(() {
      _showLikeAnimation = true;
    });
    _likeAnimationController.forward(from: 0.0).then((_) {
      setState(() {
        _showLikeAnimation = false;
      });
    });
    widget.onLikeUpdated(widget.post);
  }

  Widget _buildVerticalDivider() {
    return Container(
      height: 15,
      width: 1,
      color: Colors.white.withOpacity(0.3),
    );
  }

  void _showPostOptionsBottomSheet(BuildContext context, Post postToEdit) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
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
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Icon(Icons.edit, color: Colors.white),
                title: Text(
                  'Editar publicación',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Implementar lógica de edición
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.white),
                title: Text(
                  'Eliminar publicación',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
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
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            '¿Eliminar publicación?',
            style: TextStyle(
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
                style: TextStyle(
                  color: Colors.white,
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
                        backgroundColor: Colors.grey[800],
                        foregroundColor: Colors.white,
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
                            await PostDatabase.instance.deletePost(postToEdit.id!);
                            await _loadPosts();
                            Navigator.pop(context); // Regresar a la pantalla anterior

                            Fluttertoast.showToast(
                              msg: "Publicación eliminada exitosamente",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.grey.shade900,
                              textColor: Colors.white,
                              fontSize: 14.0,
                            );
                          } catch (e) {
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

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final backgroundColor = darkModeProvider.backgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: iconColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: iconColor),
            onPressed: () => _showPostOptionsBottomSheet(context, widget.post),
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with avatar and username
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Container(
                  width: 40.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey, width: 0.5),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'lib/assets/avatar/avatar.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 12.0),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.post.userName.isEmpty ? 'Yordi Gonzales' : widget.post.userName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: textColor,
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '• ${widget.post.timeAgo}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),

              ],
            ),
          ),

          // Image Carousel
          Expanded(
            child: GestureDetector(
              onDoubleTap: _handleDoubleTap,
              child: Stack(
                children: [
                  if (widget.post.imagePaths.length > 1)
                    CarouselSlider.builder(
                      options: CarouselOptions(
                        height: double.infinity,
                        viewportFraction: 1.0,
                        enableInfiniteScroll: false,
                        autoPlay: false,
                        onPageChanged: (index, reason) {
                          setState(() {
                            currentImageIndex = index;
                          });
                        },
                      ),
                      itemCount: widget.post.imagePaths.length,
                      itemBuilder: (context, index, realIndex) {
                        return InteractiveViewer(
                          minScale: 1.0,
                          maxScale: 3.0,
                          child: Image.file(
                            File(widget.post.imagePaths[index]),
                            fit: BoxFit.contain,
                          ),
                        );
                      },
                    )
                  else
                    InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 3.0,
                      child: Image.file(
                        File(widget.post.imagePaths.first),
                        fit: BoxFit.contain,
                      ),
                    ),
                  if (_showLikeAnimation)
                    Positioned.fill(
                      child: ScaleTransition(
                        scale: _likeAnimationController,
                        child: Icon(
                          Icons.favorite,
                          color: Colors.white,
                          size: 80.0,
                        ),
                      ),
                    ),
                  // Indicador de número de imagen
                  if (widget.post.imagePaths.length > 1)
                    Positioned(
                      top: 16.0,
                      right: 16.0,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          '${currentImageIndex + 1}/${widget.post.imagePaths.length}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8),
          // Description
          if (widget.post.description.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3.0),
              child: ExpandableText(
                text: widget.post.description,
              ),
            ),

          // Interaction buttons
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Likes(post: widget.post, onLikeUpdated: widget.onLikeUpdated),
                      _buildVerticalDivider(),
                      DislikeButtons(
                        onDislikeUpdated: (isDisliked) {
                          print('Dislike updated: $isDisliked');
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
                EtiquetaButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}