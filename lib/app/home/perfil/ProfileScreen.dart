import 'dart:convert';
import 'package:LikeChat/app/home/perfil/photoPerfil/detail/ImageDetailDialog.dart';
import 'package:LikeChat/app/home/perfil/snippets/DetailSnipptes/SnippetsDetailScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Globales/estadoDark-White/DarkModeProvider.dart';
import 'Services/ImageDatabaseHelper.dart';
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
  bool _showFavorite = false;
  List<String> history = [];
  List<String> favorite = [];
  String? _tempProfileImage;

  List<String> _imageUrls = [];
  bool _loading = true;
  List<Map<String, dynamic>> _videoUrls = [];

  String fullname = 'Yordi Diaz Gonzales';
  String usernameid = 'yordi12345';
  String description = '';
  late List<String> socialLinks = [];

  String? socialPlatform;

  final ImageDatabaseHelper _dbHelper = ImageDatabaseHelper();

  @override
  void initState() {
    super.initState();
    _fetchImages();
    _fetchVideos('movies, nature, travel, food, cities, travel');
    _loadProfileImage();
    socialLinks = [];
  }

  void _updateProfile(String newFullname, String newUsername,
      String newDescription, List<String> newSocialLinks) {
    setState(() {
      fullname = newFullname;
      usernameid = newUsername;
      description = newDescription;
      // Asignar la nueva lista de enlaces sociales
      socialLinks = newSocialLinks;
    });
  }

  Future<void> _loadProfileImage() async {
    String? imagePath = await _dbHelper.getProfileImage();
    setState(() {
      _tempProfileImage = imagePath;
    });
  }

  // Método para seleccionar una imagen desde la galería
  Future<void> openImagePicker(BuildContext context, ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _tempProfileImage = pickedImage.path;
      });

      // Guardar la imagen en la base de datos
      await _dbHelper.saveImage(pickedImage.path);

      // Mostrar un mensaje de confirmación
      Fluttertoast.showToast(
        msg: "Imagen de perfil actualizada",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey.shade800,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
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

  String _getSocialPlatformName(String link) {
    if (link.contains('facebook')) return 'Facebook';
    if (link.contains('tiktok')) return 'TikTok';
    if (link.contains('youtube')) return 'YouTube';
    if (link.contains('instagram')) return 'Instagram';
    if (link.contains('whatsapp')) return 'WhatsApp';
    if (link.contains('linkedin')) return 'LinkedIn';
    return 'Enlace';
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
        elevation: 0,
        // Estilo más limpio
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // Ajusta el Row al contenido
          children: [
            SizedBox(
              width: 150.0,
              child: Text(
                fullname,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 17,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1, // Limita a una línea
              ),
            ),
            SizedBox(width: 4),
            Transform.translate(
              offset: Offset(0, -4), // Mueve el punto ligeramente hacia arriba
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.pink,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        centerTitle: true,
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final screenWidth = constraints.maxWidth;
                      final avatarRadius =
                          screenWidth > 600 ? 50.0 : screenWidth * 0.125;
                      final fontSize = screenWidth < 350 ? 12.0 : 14.0;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        // Alineación al inicio
                        children: [
                          // Avatar con ícono de cámara
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    EdgeInsets.only(right: screenWidth * 0.04),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Stack(
                                          alignment: Alignment.bottomRight,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        ProfileDetailScreen(
                                                      imagePath:
                                                          _tempProfileImage ??
                                                              'lib/assets/placeholder_user.jpg',
                                                    ),
                                                  ),
                                                );
                                              },
                                              child: CircleAvatar(
                                                radius: avatarRadius,
                                                backgroundColor:
                                                    Colors.grey[300],
                                                backgroundImage:
                                                    _tempProfileImage != null
                                                        ? FileImage(File(
                                                            _tempProfileImage!))
                                                        : const AssetImage(
                                                                'lib/assets/placeholder_user.jpg')
                                                            as ImageProvider,
                                              ),
                                            ),
                                            Positioned(
                                              bottom: 2,
                                              right: -2,
                                              child: GestureDetector(
                                                onTap: () => openImagePicker(
                                                    context,
                                                    ImageSource.gallery),
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.cyan,
                                                    border: Border.all(
                                                      color: isDarkMode
                                                          ? Colors.black
                                                          : Colors.white,
                                                      width: 1.8,
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    child: Icon(
                                                      Icons.camera_alt,
                                                      color: Colors.white,
                                                      size: 18,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.center,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 15),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        _buildStatColumn('Seguidos',
                                            '143 mill.', screenWidth),
                                        Container(
                                          height: 25,
                                          alignment: Alignment.center,
                                          child: VerticalDivider(
                                            thickness: 0.2,
                                            width: 20,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        _buildStatColumn('Seguidores',
                                            '10 mil.', screenWidth),
                                        Container(
                                          height: 25,
                                          alignment: Alignment.center,
                                          child: VerticalDivider(
                                            thickness: 0.2,
                                            width: 20,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        _buildStatColumn(
                                            'Likes', '100 mil', screenWidth),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: screenWidth,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              // Alineado al inicio
                              children: [
                                Text(
                                  '@$usernameid',
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  textAlign: TextAlign.start,
                                ),
                                SizedBox(width: 10),
                                GestureDetector(
                                  onTap: () {
                                    Clipboard.setData(
                                        ClipboardData(text: usernameid));
                                    Fluttertoast.showToast(
                                      msg: "Usuario copiado al portapapeles",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.BOTTOM,
                                      backgroundColor: Colors.grey.shade800,
                                      textColor: Colors.white,
                                      fontSize: 14.0,
                                    );
                                  },
                                  child: Icon(
                                    Icons.copy,
                                    color: Colors.grey,
                                    size: screenWidth < 350 ? 16 : 18,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  SizedBox(height: 7),
                  // Sección de botones (Editar Perfil y Compartir)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 37, // Altura fija del botón
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfileScreen(
                                      fullname: fullname,
                                      usernameid: usernameid,
                                      description: description,
                                      socialLinks: [],
                                      onSave: _updateProfile,
                                    ),
                                  ),
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.cyan,
                                foregroundColor: Colors.cyan,
                                side: BorderSide(color: Colors.cyan, width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(7),
                                ),
                                padding: EdgeInsets.zero, // Sin padding adicional
                              ),
                              child: Text(
                                'Editar Perfil',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14, // Tamaño de fuente normal
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: SizedBox(
                            height: 37, // Altura fija del botón
                            child: OutlinedButton(
                              onPressed: () {
                                const String shareText = 'Mira mi perfil en LikeChat!';
                                const String shareLink = 'https://www.likechat.com/yordigonzales';

                                Share.share('$shareText\n$shareLink');
                              },
                              style: OutlinedButton.styleFrom(
                                backgroundColor: Colors.cyan,
                                foregroundColor: Colors.cyan,
                                side: BorderSide(color: Colors.cyan, width: 1.5),
                                shape:
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                                padding:
                                EdgeInsets.zero, // Sin padding adicional
                              ),
                              child:
                              Text('Compartir', style:
                              TextStyle(color:
                              Colors.white, fontWeight:
                              FontWeight.bold, fontSize:
                              14)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 4),
                  // Descripción
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: description.isEmpty
                          ? (isDarkMode ? Colors.grey[900] : Colors.grey[100])
                          : Colors.transparent,
                      // Fondo gris oscuro en modo oscuro y gris claro en modo claro si está vacío
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: description.isEmpty
                            ? (isDarkMode
                                ? Colors.grey[900]!
                                : Colors.grey[100]!)
                            : Colors.transparent,
                      ),
                    ),
                    child: Text(
                      description.isEmpty
                          ? 'Escribe una breve descripción...'
                          : description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                  // Link a redes sociales
                  GestureDetector(
                    onTap: () {
                      if (socialLinks.isNotEmpty) {
                        // Verificar si hay al menos un enlace válido
                        String validLink = socialLinks.firstWhere(
                              (link) => Uri.tryParse(link)?.hasAbsolutePath == true,
                          orElse: () => '',
                        );

                        if (validLink.isNotEmpty) {
                          _openLink(validLink); // Abre el primer enlace válido
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('No hay URLs válidas')),
                          );
                        }
                      }
                    },
                    child: socialLinks.isNotEmpty && socialLinks.any(
                          (link) => Uri.tryParse(link)?.hasAbsolutePath == true,
                    )
                        ? Container(
                      width: double.infinity,
                      // Reducir el padding para evitar espacio innecesario debajo
                      padding: EdgeInsets.symmetric(horizontal: 8), // Ajustado para evitar espacio adicional
                      child: Column(
                        children: [
                          Text(
                            'Redes Sociales',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w400),
                          ),
                          SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center, // Alineación vertical centrada
                            children: [
                              for (int i = 0; i < socialLinks.length; i++) ...[
                                GestureDetector(
                                  onTap: () {
                                    if (Uri.tryParse(socialLinks[i])?.hasAbsolutePath == true) {
                                      _openLink(socialLinks[i]);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('URL inválida')),
                                      );
                                    }
                                  },
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min, // Evita que la columna ocupe más espacio del necesario
                                    children: [
                                      Icon(
                                        _getSocialIcon(socialLinks[i]),
                                        size: 25,
                                        color: _getSocialIconColor(socialLinks[i]),
                                      ),
                                      SizedBox(height: 4), // Espacio controlado entre icono y texto
                                      Text(
                                        _getSocialPlatformName(socialLinks[i]),
                                        style: TextStyle(fontSize: 9, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                if (i < socialLinks.length - 1)
                                  Container(
                                    height: 30,
                                    alignment: Alignment.center,
                                    child: VerticalDivider(
                                      thickness: 0.2,
                                      width: 15,
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    )
                        : SizedBox.shrink(), // Oculta el contenedor si no hay enlaces válidos
                  )
                ],
              ),
            ),
            _buildButtonsSection(),
            _buildContentSection(),
          ],
        ),
      ),
    );
  }

  // Método de seguidores
  Widget _buildStatColumn(String label, String value, double screenWidth) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final fontSize = screenWidth < 350 ? 12.0 : 14.0;

    return Column(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 80),
          child: Text(
            value,
            style: TextStyle(
              fontSize: fontSize + 4,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 80),
          child: Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              color: isDarkMode ? Colors.white70 : Colors.black54,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildButtonsSection() {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
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
                          _showFavorite = false;
                        });
                      },
                      _showGallery,
                      isDarkMode: isDarkMode,
                    ),
                    if (_showGallery)
                      Container(
                        height: 1.0,
                        width: 60.0,
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
                          _showFavorite = false;
                        });
                      },
                      _showVideo,
                      isDarkMode: isDarkMode,
                    ),
                    if (_showVideo)
                      Container(
                        height: 1.0,
                        width: 60.0,
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
                          _showFavorite = false;
                        });
                      },
                      _showStories,
                      isDarkMode: isDarkMode,
                    ),
                    if (_showStories)
                      Container(
                        height: 1.0, // Ajusta el grosor de la línea
                        width: 60.0,
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
                      Icons.bookmark_add,
                      'Favoritos',
                      () {
                        setState(() {
                          _showGallery = false;
                          _showVideo = false;
                          _showStories = false;
                          _showFavorite = true;
                        });
                      },
                      _showFavorite,
                      isDarkMode: isDarkMode,
                    ),
                    if (_showFavorite)
                      Container(
                        height: 1.4, // Ajusta el grosor de la línea
                        width: 60.0,
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
            padding: EdgeInsets.all(9.0),
            // Espacio interior alrededor del icono
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected
                  ? Colors.cyan.withOpacity(0.3)
                  : Colors.transparent,
            ),
            child: Icon(
              icon,
              size: 22,
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
              fontSize: 12,
              color: isSelected
                  ? Colors.cyan
                  : (isDarkMode ? Colors.white : Colors.black),
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
    } else if (_showFavorite) {
      return _buildFavoriteContent();
    } else {
      return Container();
    }
  }

  Future<void> _fetchImages() async {
    const apiKey = 'KAEVuNf8VCwEGTHfxOhWN3gfGvKyU4e2dkE5HOcRM1M';

    // imagenes multiples
    const querys = ['travel', 'mountains',
      'education', 'flowers', 'food', 'nature', ];
    final response = await http.get(
      Uri.parse(
          'https://api.unsplash.com/search/photos?query=$querys&client_id=$apiKey&per_page=20'),
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
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;

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
        mainAxisSpacing: 0.2,
        crossAxisSpacing: 0.2,
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
              border: Border.all(color: isDarkMode ? Colors.black : Colors.white, width: 0.4),
              image: DecorationImage(
                image: NetworkImage(_imageUrls[index])
                  ..resolve(ImageConfiguration()).addListener(
                    ImageStreamListener(
                          (ImageInfo image, bool synchronousCall) {},
                      onError: (error, stackTrace) {
                        setState(() {
                          _imageUrls[index] = 'assets/logo.png'; // Ruta del placeholder
                        });
                      },
                    ),
                  ),
                fit: BoxFit.cover,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 4.0,
                  right: 4.0,
                  child: Icon(
                    Icons.image,
                    size: 19,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  Future<void> _fetchVideos(String query) async {
    const apiKey =
        'jUOv1hg2RxnB7vQcFZzbYdQB9bhYCAyS7wjvZVVpFoDQTqtj2QzoStbB'; // clave API

    final response = await http.get(
      Uri.parse(
          'https://api.pexels.com/videos/search?query=$query&per_page=35'),
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
                  'thumbnailUrl': item['image'],
                  // Aquí extraemos la miniatura del video
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
            Icon(Icons.videocam_off_rounded, size: 70, color: Colors.grey),
            SizedBox(height: 10),
            Text('No hay videos disponibles',
                style: TextStyle(fontSize: 14, color: Colors.grey[500])),
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
                video['thumbnailUrl'], // Usamos la miniatura real
                fit: BoxFit.cover,
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 40, // Tamaño del círculo
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.4),
                    // Fondo blanco translúcido
                    shape: BoxShape.circle, // Forma circular
                  ),
                  child: Icon(
                    Icons.play_arrow,
                    size: 20,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                // Posiciona el Row en la parte inferior central
                child: Padding(
                  padding: const EdgeInsets.all(8.0), // Un poco de espacio
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    // Ajusta el tamaño del Row al contenido
                    mainAxisAlignment: MainAxisAlignment.center,
                    // Centra los hijos del Row horizontalmente
                    children: [
                      Icon(Icons.remove_red_eye_outlined,
                          size: 15, color: Colors.white),
                      // Ícono de reproducción pequeño
                      SizedBox(width: 4),
                      Text(
                        '100 mil', // Simulación de 100 mil vistas
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 11),
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
          videoUrls:
              _videoUrls.map((item) => item['videoUrl'] as String).toList(),
          initialIndex:
              _videoUrls.indexWhere((item) => item['videoUrl'] == videoUrl),
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

  //metodo de favorito
  Widget _buildFavoriteContent() {
    return Container(
      child: favorite.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 30.0),
                  Icon(
                    Icons.bookmark_add,
                    size: 70,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Aún no hay Favoritos',
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
              itemCount: favorite.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ImageDetailScreen(
                          imageUrls: favorite,
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
                        image: AssetImage(favorite[index]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void updateProfileImage(String newImagePath) {
    setState(() {
      _tempProfileImage = newImagePath;
    });
  }
}
