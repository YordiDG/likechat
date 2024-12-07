import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../Globales/estadoDark-White/DarkModeProvider.dart';
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

class _PostClassState extends State<PostClass> {
  TextEditingController _searchController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  String? _imagePath;
  List<Post> _publishedPosts = [];
  bool _permissionsDeniedMessageShown = false;

  bool isLiked = false;
  int likeCount = 10;

  bool _isSearchBarVisible = true;
  double _lastScrollOffset = 0.0;

  void _toggleLike() {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1; // Incrementa o decrementa el contador
    });
  }

  @override
  void initState() {
    super.initState();
  }

  void _onScroll(double offset) {
    if (offset > _lastScrollOffset && _isSearchBarVisible) {
      // Ocultar barra de búsqueda cuando se desliza hacia arriba
      setState(() {
        _isSearchBarVisible = false;
      });
    } else if (offset < _lastScrollOffset && !_isSearchBarVisible) {
      // Mostrar barra de búsqueda cuando se desliza hacia abajo
      setState(() {
        _isSearchBarVisible = true;
      });
    }
    _lastScrollOffset = offset;
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
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
                      horizontal: 14.0, vertical: 8.0),
                  child: Container(
                    color: Colors.transparent,
                    height: 38.0,
                    child: TextField(
                      controller: _searchController,
                      cursorColor: Colors.cyan,
                      decoration: InputDecoration(
                        hintText: 'Buscar amigo',
                        hintStyle: TextStyle(
                            color: isDarkMode
                                ? Colors.grey[500]
                                : Colors.grey[700],
                            fontSize: 12.0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide:
                              BorderSide(color: Colors.white, width: 0.8),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide(
                              color:
                                  isDarkMode ? Colors.grey : Colors.grey[400]!,
                              width: 0.8),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide:
                              BorderSide(color: Colors.cyan, width: 0.8),
                        ),
                        filled: true,
                        fillColor: backgroundColor,
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                        prefixIcon: Icon(Icons.search, color: iconColor),
                      ),
                      style: TextStyle(color: textColor),
                      onChanged: (value) {
                        // Acción de búsqueda en tiempo real
                      },
                    ),
                  ),
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
            child: Container(
              width: 55.0,
              height: 55.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.cyan,
              ),
              child: FloatingActionButton(
                onPressed: () {
                  _showImageSourceSelection();
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 35.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
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
                'Seleccionar Imagen',
                style: TextStyle(
                  color: textColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 25), // Espaciado entre el título y las opciones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    icon: Icons.camera_alt,
                    label: 'Cámara',
                    source: ImageSource.camera,
                    color: Colors.cyan,
                  ),
                  _buildImageSourceOption(
                    icon: Icons.photo,
                    label: 'Galería',
                    source: ImageSource.gallery,
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

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required ImageSource source,
    required Color color,
  }) {
    // Usar listen: false para evitar problemas fuera del árbol de widgets
    final darkModeProvider =
        Provider.of<DarkModeProvider>(context, listen: false);
    final textColor = darkModeProvider.textColor;

    return GestureDetector(
      onTap: () {
        Navigator.pop(context); // Cerrar el BottomSheet
        _selectImage(source: source);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: color, // Color de fondo del círculo
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

  void _selectImage({required ImageSource source}) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _imagePath = pickedImage.path;
      });
      // Navegar a la pantalla de vista previa
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PreviewScreen(
          imagePath: _imagePath!,
          descriptionController: _descriptionController,
          onPublish: _publishPost,
        ),
      ));
    }
  }

  void _publishPost() {
    String description = _descriptionController.text;
    List<String> imagePaths = _imagePath != null
        ? [_imagePath!]
        : []; // Convierte a lista si no es nulo

    if (description.isNotEmpty || imagePaths.isNotEmpty) {
      // Crear un nuevo post
      Post newPost = Post(description: description, imagePaths: imagePaths);

      // Agregar el post publicado a la lista
      setState(() {
        _publishedPosts.add(newPost);
        _descriptionController.clear();
        _imagePath = null;
      });

      // Volver a la pantalla principal
      Navigator.of(context).pop();
    }
  }

  Widget _buildPublishedPostCards() {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final backgroundColor = darkModeProvider.backgroundColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: _publishedPosts.map((post) {
        int _currentIndex = 0; // Inicializar el índice del carrusel

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(12.0),
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
                  ? Colors.red.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.3),
              width: 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundImage: AssetImage('lib/assets/avatar.png'),
                      radius: 23.0,
                    ),
                    SizedBox(width: 10.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Yordi Gonzales',
                                  style: TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              SizedBox(width: 8.0),
                              Text(
                                '• 1 min',
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
                      onPressed: () {
                        _showPostOptionsBottomSheet(context);
                      },
                      icon: Icon(Icons.more_vert, size: 25.0, color: iconColor),
                    ),
                  ],
                ),
              ),
              if (post.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 9.0),
                  child: ExpandableText(
                    text: post.description,
                    style: TextStyle(
                      fontSize: 14.0,
                      color: textColor,
                    ),
                  ),
                ),
              if (post.imagePaths.isNotEmpty)
                Column(
                  children: [
                    // Contador en la parte superior
                    if (post.imagePaths.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '${_currentIndex + 1}/${post.imagePaths.length}',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    // Carrusel
                    ClipRRect(
                      child: post.imagePaths.length > 1
                          ? CarouselSlider(
                              options: CarouselOptions(
                                height: MediaQuery.of(context).size.width * 0.8,
                                viewportFraction: 1.0,
                                enableInfiniteScroll: false,
                                autoPlay: false,
                                onPageChanged: (index, reason) {
                                  _currentIndex = index; // Actualizar índice
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
                    ),

                    // Indicadores de puntos debajo
                    if (post.imagePaths.length > 1)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: post.imagePaths.asMap().entries.map((entry) {
                          return Container(
                            width: 8.0,
                            height: 8.0,
                            margin: EdgeInsets.symmetric(
                                vertical: 10.0, horizontal: 4.0),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentIndex == entry.key
                                  ? Colors.white
                                  : Colors.grey.withOpacity(0.5),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Likes(),
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
          ),
        );
      }).toList(),
    );
  }

  // Método para mostrar menú de opciones de la publicación
  void _showPostOptionsBottomSheet(BuildContext context) {
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
                Text('Opciones de publicación',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                ListTile(
                  leading: Icon(Icons.edit),
                  title: Text('Editar publicación'),
                  onTap: () {
                    // Lógica de edición
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.delete),
                  title: Text('Eliminar publicación'),
                  onTap: () {
                    // Lógica de eliminación
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          );
        });
  }
}

class Post {
  final String description;
  final List<String> imagePaths;

  Post({required this.description, required this.imagePaths});
}
