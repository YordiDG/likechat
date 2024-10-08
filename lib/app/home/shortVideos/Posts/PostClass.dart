import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import '../../../Deezer-API-Musica/MusicModal.dart';
import '../../../Globales/estadoDark-White/DarkModeProvider.dart';
import '../../../Globales/expandetext/ExpandableText.dart';
import 'OpenCamara/preview/PreviewScreen.dart';
import 'package:provider/provider.dart';

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
  int likeCount = 123;

  void _toggleLike() {
    setState(() {
      isLiked = !isLiked;
      likeCount += isLiked ? 1 : -1; // Incrementa o decrementa el contador
    });
  }

  @override
  void initState() {
    super.initState();
    // Solicitar permisos de cámara y abrir la cámara automáticamente cuando se carga la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestCameraPermission().then((granted) {
        if (granted) {
          _selectImage(source: ImageSource.camera);
        } else if (!_permissionsDeniedMessageShown) {
          _showPermissionDeniedMessage();
          _permissionsDeniedMessageShown = true;
        }
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

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14.0, vertical: 8.0),
                child: Container(
                  color: Colors.transparent,
                  height: 38.0,
                  child: TextField(
                    controller: _searchController,
                    cursorColor: Colors.cyan,
                    decoration: InputDecoration(
                      hintText: 'Buscar amigo',
                      hintStyle:
                          TextStyle(color: Colors.grey[500], fontSize: 14.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.white, width: 0.8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.grey, width: 0.8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.grey, width: 0.8),
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 10.0),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey[500],
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(vertical: 5),
                            child: VerticalDivider(
                              color: Colors.grey,
                              thickness: 1,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // Lógica para el botón de búsqueda
                            },
                            child: Text(
                              'Buscar',
                              style: TextStyle(
                                color: Colors.cyan,
                                fontSize: 12,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 2),
                            ),
                          ),
                        ],
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                    onChanged: (value) {
                      // Acción de búsqueda en tiempo real
                    },
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: 20.0),
                      _buildPublishedPostCards(),
                    ],
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

  Future<bool> _requestCameraPermission() async {
    // Solicitar permisos de cámara
    PermissionStatus cameraPermission = await Permission.camera.request();
    return cameraPermission.isGranted;
  }


  void _showImageSourceSelection() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.black87, // Fondo más oscuro y profesional
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Seleccionar Imagen',
                style: TextStyle(
                  color: Colors.white70,
                  // Tono de blanco más oscuro y profesional
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
    required Color color, // Cambiado a Color
  }) {
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
              color: Colors.white, // Color del icono
              size: 30.0, // Tamaño reducido para hacerlo más profesional
            ),
          ),
          SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14, // Tamaño de texto reducido
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

  void _showPermissionDeniedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Permiso de cámara denegado. Por favor, habilite los permisos en la configuración.'),
      ),
    );
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
        return Column(
          children: [
            Card(
              color: backgroundColor,
              margin: EdgeInsets.only(bottom: 5.0),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage:
                                  AssetImage('lib/assets/avatar.png'),
                              radius: 21.0,
                            ),
                            SizedBox(width: 10.0),
                            Expanded(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Yordi Gonzales',
                                    style: TextStyle(
                                      fontSize: 15.0,
                                      fontWeight: FontWeight.bold,
                                      color: textColor,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      // Acción del botón para opciones adicionales
                                    },
                                    icon: Icon(Icons.more_vert,
                                        size: 26.0, color: iconColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 5.0),
                        // Ajuste del espacio entre el avatar y la hora
                        Row(
                          children: [
                            Icon(Icons.access_time,
                                size: 11.0, color: Colors.grey[600]),
                            SizedBox(width: 6.0),
                            Text(
                              'Hace 1 hora',
                              style: TextStyle(
                                  fontSize: 11.0, color: Colors.grey[600]),
                            ),
                            SizedBox(width: 20.0),
                            Icon(Icons.public,
                                size: 15.0, color: Colors.grey[600]),
                          ],
                        ),
                        SizedBox(height: 8.0),
                        // Ajuste del espacio entre la hora y la descripción
                        if (post.description.isNotEmpty)
                          Container(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 3.0),
                            // Asegura espaciado uniforme en los laterales
                            child: ExpandableText(
                              text: post.description,
                              style: TextStyle(
                                fontSize: 14.0,
                                // Ajusta el tamaño del texto si es necesario
                                color: textColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    child: post.imagePaths.isNotEmpty
                        ? post.imagePaths.length > 1
                        ? CarouselSlider(
                      options: CarouselOptions(
                        height: MediaQuery.of(context).size.width * 1.5,
                        viewportFraction: 1.0,
                        enableInfiniteScroll: false,
                        autoPlay: false,
                      ),
                      items: post.imagePaths.map((path) {
                        return GestureDetector(
                          onDoubleTap: () {
                            setState(() {
                              isLiked = !isLiked;
                              if (isLiked) {
                                likeCount++;
                              } else {
                                likeCount--;
                              }
                            });
                          },
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final imageWidth = constraints.maxWidth;
                              final imageHeight = MediaQuery.of(context).size.width * 1.5;
                              return FittedBox(
                                fit: BoxFit.cover,
                                child: Image.file(
                                  File(path),
                                  width: imageWidth,
                                  height: imageHeight,
                                ),
                              );
                            },
                          ),
                        );
                      }).toList(),
                    )
                        : LayoutBuilder(
                      builder: (context, constraints) {
                        final imageWidth = constraints.maxWidth;
                        return FittedBox(
                          fit: BoxFit.cover,
                          child: Image.file(
                            File(post.imagePaths.first),
                            width: imageWidth,
                          ),
                        );
                      },
                    )
                        : SizedBox.shrink(),
                  ),
                  SizedBox(height: 5.0),
                  Container(
                    height: 47.0,
                    // Establece una altura fija para el contenedor
                    margin: EdgeInsets.symmetric(horizontal: 70.0),
                    // Ajusta el margen horizontal
                    decoration: BoxDecoration(
                      color: backgroundColor == Colors.white
                          ? Colors.black.withOpacity(0.4)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed: _toggleLike,
                          icon: Icon(
                            Icons.favorite,
                            size: 26.0,
                            color: isLiked ? Colors.red : Colors.white,
                          ),
                        ),
                        Text(
                          '$likeCount',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 16.0),
                        IconButton(
                          onPressed: () {
                            // Acción del botón para comentar
                          },
                          icon: SvgPicture.asset(
                            'lib/assets/mesage.svg',
                            width: 28.0,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 16.0),
                        IconButton(
                          onPressed: () {
                            // Acción del botón para compartir
                          },
                          icon: SvgPicture.asset(
                            'lib/assets/shared.svg',
                            width: 28.0,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Divider(
                height: 0.1,
                color: isDarkMode ? Colors.grey[850] : Colors.grey[100]),
          ],
        );
      }).toList(),
    );
  }
}

class Post {
  final String description;
  final List<String> imagePaths;

  Post({required this.description, required this.imagePaths});
}
