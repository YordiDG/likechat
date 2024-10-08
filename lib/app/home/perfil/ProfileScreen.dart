import 'dart:convert';

import 'package:LikeChat/app/home/perfil/photoPerfil/detail/ImageDetailDialog.dart';
import 'package:LikeChat/app/home/perfil/photoPerfil/detail/ImagePreviewScreen.dart';
import 'package:LikeChat/app/home/perfil/snippets/DetailSnipptes/SnippetsDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Globales/estadoDark-White/DarkModeProvider.dart';
import 'configuration/MenuConfiguration.dart';
import 'editProfile/EditProfile.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'gallery/ImageDetail/ImageDetailDialog.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _showGallery = true;
  bool _showVideo = false;
  bool _showStories = false;
  List<String> history = [];
  String? _tempProfileImage;

  List<String> _imageUrls = [];
  bool _loading = true;
  List<Map<String, dynamic>> _videoUrls = [];


  String username = 'Yordi Gonzales';
  String description = 'Añade una breve descripción';
  String socialLink = '';

  String? socialPlatform;

  @override
  void initState() {
    super.initState();
    _fetchImages();
    _fetchVideos('love, nature, travel, food, cities, travel');

  }

  void _updateProfile(
      String newUsername, String newDescription, String newLinkSocial) {
    setState(() {
      username = newUsername;
      description = newDescription;
      socialLink = newLinkSocial;
    });
  }

  IconData _getSocialIcon(String url) {
    if (url.contains("facebook.com")) {
      return FontAwesomeIcons.facebook;
    } else if (url.contains("twitter.com")) {
      return FontAwesomeIcons.twitter;
    } else if (url.contains("instagram.com")) {
      return FontAwesomeIcons.instagram;
    } else if (url.contains("linkedin.com")) {
      return FontAwesomeIcons.linkedin;
    } else if (url.contains("tiktok.com")) {
      return FontAwesomeIcons.tiktok;
    } else if (url.contains("youtube.com")) {
      return FontAwesomeIcons.youtube;
    } else if (url.contains("wa.me")) {
      return FontAwesomeIcons.whatsapp;
    } else {
      return Icons.link; // Ícono predeterminado para otros URLs
    }
  }

  Color _getSocialIconColor(String url) {
    if (url.contains("facebook.com")) {
      return Colors.blue;
    } else if (url.contains("twitter.com")) {
      return Colors.lightBlue;
    } else if (url.contains("instagram.com")) {
      return Colors.pink;
    } else if (url.contains("linkedin.com")) {
      return Colors.blueAccent;
    } else if (url.contains("tiktok.com")) {
      return Colors.black;
    } else if (url.contains("youtube.com")) {
      return Colors.red;
    } else if (url.contains("wa.me")) {
      return Colors.green;
    } else {
      return Colors.grey;
    }
  }

  Widget buildIcon(String url) {
    return Icon(
      _getSocialIcon(url),
      color: _getSocialIconColor(url),
    );
  }

  void _openLink(String url) async {
    if (url.isEmpty) {
      _showSnackbar('La URL no puede estar vacía.');
      return;
    }

    if (url.length < 5) {
      _showSnackbar('La URL parece ser demasiado corta para ser válida.');
      return;
    }

    final Uri? uri = Uri.tryParse(url);

    if (uri == null) {
      _showSnackbar('La URL proporcionada no es válida.');
      return;
    }

    if (!uri.hasScheme || (!uri.isScheme('http') && !uri.isScheme('https'))) {
      _showSnackbar('La URL debe comenzar con http:// o https://');
      return;
    }

    try {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        _showSnackbar('No se puede abrir la URL: $url');
      }
    } catch (e) {
      _showSnackbar('Ocurrió un error al intentar abrir la URL: $e');
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final backgroundColor = darkModeProvider.backgroundColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(
          'Perfil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu_sharp, color: iconColor),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MenuConfiguration()),
              );
            },
          ),
        ],
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProfileDetailScreen(
                                  imagePath: _tempProfileImage ??
                                      'lib/assets/placeholder_user.jpg',
                                ),
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              CircleAvatar(
                                radius: 52, // Ajuste del tamaño del avatar
                                backgroundColor: Colors.grey[300],
                                child: CircleAvatar(
                                  radius: 52,
                                  // Tamaño del avatar más pequeño para el borde
                                  backgroundImage: _tempProfileImage != null
                                      ? FileImage(File(_tempProfileImage!))
                                          as ImageProvider<Object>?
                                      : AssetImage(
                                          'lib/assets/placeholder_user.jpg'),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 2,
                                child: GestureDetector(
                                  onTap: () {
                                    openImagePicker(
                                        context, ImageSource.gallery);
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDarkMode
                                          ? Colors.cyan
                                          : Colors.cyan,
                                      border: Border.all(
                                          color: isDarkMode
                                              ? Colors.black
                                              : Colors.white,
                                          width: 2.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                        size: 24,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      username,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? Colors.white
                            : Colors.black, // Cambiado a blanco
                      ),
                    ),
                    SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                              '100',
                              style: TextStyle(
                                fontSize: 18,
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Seguidos',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 20),
                        Column(
                          children: [
                            Text(
                              '200',
                              style: TextStyle(
                                fontSize: 18,
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Seguidores',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(width: 20),
                        Column(
                          children: [
                            Text(
                              '500',
                              style: TextStyle(
                                fontSize: 18,
                                color: isDarkMode ? Colors.white : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Likes',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditProfileScreen(
                                  username: username,
                                  description: description,
                                  socialLink: socialLink,
                                  onSave: _updateProfile,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.cyan,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  12), // Borde más redondeado
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                          ),
                          child: Text(
                            'Editar Perfil',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: () {
                            final String shareText =
                                'Mira mi perfil en LikeChat!';
                            final String shareLink =
                                'https://www.likechat.com/yordigonzales';

                            // Usar el paquete share_plus para compartir
                            Share.share('$shareText\n$shareLink');
                          },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.cyan,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                          ),
                          child: Text(
                            'Compartir',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(5),
                      child: Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (socialLink.isNotEmpty &&
                            Uri.tryParse(socialLink)?.hasAbsolutePath == true) {
                          _openLink(socialLink);
                        } else {
                          // Manejar la URL inválida aquí, por ejemplo, mostrando un Snackbar
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('URL no válida: $socialLink'),
                            ),
                          );
                        }
                      },
                      child: socialLink.isNotEmpty
                          ? Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  Icon(
                                    _getSocialIcon(socialLink),
                                    color: _getSocialIconColor(
                                        socialLink), // Llama al método para obtener el color
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        _openLink(socialLink);
                                      },
                                      child: Text(
                                        socialLink,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                          decoration: TextDecoration.underline,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        // Muestra puntos suspensivos si el texto es muy largo
                                        maxLines:
                                            1, // Asegura que el texto no se divida en varias líneas
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : SizedBox.shrink(),
                    )
                  ],
                ),
              ),
              _buildButtonsSection(),
              _buildContentSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildButtonsSection() {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.black : Colors.white,
        // Ajustar el color del contenedor según el modo
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        children: [
          Container(
            height: 0.2,
            color: isDarkMode
                ? Colors.grey[800]
                : Colors.grey[400], // Color de la línea según el modo
          ),
          SizedBox(height: 4.0),
          // Espacio

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _buildIconButton(
                      Icons.image,
                      'Galería',
                      () {
                        setState(() {
                          _showGallery = true;
                          _showVideo = false;
                          _showStories = false;
                        });
                      },
                      _showGallery,
                      isDarkMode: isDarkMode,
                    ),
                    if (_showGallery)
                      Container(
                        height: 2.0,
                        width: 80.0,
                        color: isDarkMode
                            ? Colors.cyan
                            : Colors.black, // Línea de selección según el modo
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    _buildIconButton(
                      Icons.video_library,
                      'Snippets',
                      () {
                        setState(() {
                          _showGallery = false;
                          _showVideo = true;
                          _showStories = false;
                        });
                      },
                      _showVideo,
                      isDarkMode: isDarkMode,
                    ),
                    if (_showVideo)
                      Container(
                        height: 2.0,
                        width: 80.0,
                        color: isDarkMode
                            ? Colors.cyan
                            : Colors.black, // Línea de selección según el modo
                      ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    _buildIconButton(
                      Icons.history_outlined,
                      'Historias',
                      () {
                        setState(() {
                          _showGallery = false;
                          _showVideo = false;
                          _showStories = true;
                        });
                      },
                      _showStories,
                      isDarkMode: isDarkMode,
                    ),
                    if (_showStories)
                      Container(
                        height: 2.0, // Ajusta el grosor de la línea
                        width: 80.0,
                        color: isDarkMode
                            ? Colors.cyan
                            : Colors.black, // Línea de selección según el modo
                      ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 4.0),
          // Espacio entre la línea de los botones y el borde inferior
          Container(
            height: 0.1,
            color: isDarkMode
                ? Colors.grey[400]
                : Colors.grey[400], // Color de la línea según el modo
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(
      IconData icon, String label, VoidCallback onPressed, bool isSelected,
      {required bool isDarkMode}) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12.0),
            // Espacio interior alrededor del icono
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? Colors.cyan.withOpacity(0.3)
                  : Colors.transparent,
            ),
            child: Icon(
              icon,
              size: 26,
              color: isSelected
                  ? (isDarkMode ? Colors.cyan : Colors.cyan)
                  : (isDarkMode
                      ? Colors.white
                      : Colors.black), // Ajustar color del ícono
            ),
          ),
          SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isSelected
                  ? Colors.cyan
                  : (isDarkMode
                      ? Colors.white
                      : Colors.black), // Ajustar color del texto
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSection() {
    if (_showGallery) {
      return _buildGalleryContent();
    } else if (_showVideo) {
      return _buildVideoContent();
    } else if (_showStories) {
      return _buildStoriesContent();
    } else {
      return Container();
    }
  }

  Future<void> _fetchImages() async {
    const apiKey = 'KAEVuNf8VCwEGTHfxOhWN3gfGvKyU4e2dkE5HOcRM1M';

    // imagenes multiples
    const query = 'travel, food';
    final response = await http.get(
      Uri.parse('https://api.unsplash.com/search/photos?query=$query&client_id=$apiKey&per_page=25'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        _imageUrls = (data['results'] as List<dynamic>)
            .map((item) => item['urls']['small'] as String)
            .toList();
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
      throw Exception('Failed to load images');
    }
  }

  Widget _buildGalleryContent() {
    if (_imageUrls.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 30.0),
            Icon(
              Icons.photo,
              size: 70,
              color: Colors.grey,
            ),
            SizedBox(height: 10),
            Text(
              'No hay fotos disponibles',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 0.5,
        crossAxisSpacing: 0.5,
      ),
      itemCount: _imageUrls.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImageDetailScreen(
                  imageUrls: _imageUrls,
                  initialIndex: index,
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2.0),
              border: Border.all(color: Colors.white, width: 1.0),
              image: DecorationImage(
                image: NetworkImage(_imageUrls[index])
                  ..resolve(ImageConfiguration())
                      .addListener(
                    ImageStreamListener(
                          (ImageInfo image, bool synchronousCall) {},
                      onError: (error, stackTrace) {
                        // Manejar el error aquí
                        setState(() {
                          _imageUrls[index] = 'assets/logo.png'; // Ruta del placeholder
                        });
                      },
                    ),
                  ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _fetchVideos(String query) async {
    const apiKey = 'jUOv1hg2RxnB7vQcFZzbYdQB9bhYCAyS7wjvZVVpFoDQTqtj2QzoStbB';  // clave API

    final response = await http.get(
      Uri.parse('https://api.pexels.com/videos/search?query=$query&per_page=45'),
      headers: {
        'Authorization': apiKey,
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      setState(() {
        _videoUrls = (data['videos'] as List<dynamic>)
            .map((item) => {
          'videoUrl': item['video_files'][0]['link'],
          'thumbnailUrl': item['image'],  // Aquí extraemos la miniatura del video
        })
            .toList();
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
      });
      throw Exception('Failed to load videos');
    }
  }


  Widget _buildVideoContent() {
    if (_videoUrls.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 30.0),
            Icon(Icons.videocam_off_rounded, size: 70, color: Colors.black),
            SizedBox(height: 10),
            Text('No hay videos disponibles', style: TextStyle(fontSize: 14, color: Colors.grey[500])),
          ],
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 1.0,
        crossAxisSpacing: 1.0,
      ),
      itemCount: _videoUrls.length,
      itemBuilder: (context, index) {
        final video = _videoUrls[index];
        return GestureDetector(
          onTap: () {
            _playVideo(context, video['videoUrl']);
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                video['thumbnailUrl'],  // Usamos la miniatura real
                fit: BoxFit.cover,
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 40,  // Tamaño del círculo
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),  // Fondo blanco translúcido
                    shape: BoxShape.circle,  // Forma circular
                  ),
                  child: Icon(
                    Icons.play_arrow,  // Ícono de reproducción
                    size: 25,  // Tamaño más grande para hacerlo más prominente
                    color: Colors.white.withOpacity(0.9),  // Color blanco con opacidad para mejor contraste
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,  // Posiciona el Row en la parte inferior central
                child: Padding(
                  padding: const EdgeInsets.all(8.0),  // Un poco de espacio
                  child: Row(
                    mainAxisSize: MainAxisSize.min, // Ajusta el tamaño del Row al contenido
                    mainAxisAlignment: MainAxisAlignment.center, // Centra los hijos del Row horizontalmente
                    children: [
                      Icon(Icons.play_arrow, size: 16, color: Colors.white),  // Ícono de reproducción pequeño
                      SizedBox(width: 4),
                      Text(
                        '100 mil',  // Simulación de 100 mil vistas
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }


  void _playVideo(BuildContext context, String videoUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoDetailScreen(
          videoUrls: _videoUrls.map((item) => item['videoUrl'] as String).toList(),
          initialIndex: _videoUrls.indexWhere((item) => item['videoUrl'] == videoUrl),
        ),
      ),
    );
  }

  Widget _buildStoriesContent() {
    return Container(
      child: history.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 30.0),
                  Icon(
                    Icons.timer_off_outlined,
                    size: 70,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'No hay Historias disponibles',
                    style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          : GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 1.0, // Espacio vertical entre los elementos
                crossAxisSpacing: 1.0, // Espacio horizontal entre los elementos
              ),
              itemCount: history.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageDetailScreen(
                          imageUrls: history,
                          initialIndex: index,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5.0),
                      border: Border.all(color: Colors.white, width: 1.0),
                      image: DecorationImage(
                        image: AssetImage(history[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> openImagePicker(BuildContext context, ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _tempProfileImage = pickedFile.path;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePreviewScreen(
            imagePath: pickedFile.path,
            onUpdateProfileImage: updateProfileImage,
          ),
        ),
      );
    }
  }

  void updateProfileImage(String newImagePath) {
    setState(() {
      _tempProfileImage = newImagePath;
    });
  }
}
