import 'package:LikeChat/app/perfil/photoPerfil/detail/ImageDetailDialog.dart';
import 'package:LikeChat/app/perfil/photoPerfil/detail/ImagePreviewScreen.dart';
import 'package:LikeChat/app/perfil/snippets/DetailSnipptes/SnippetsDetailScreen.dart';
import 'package:flutter/material.dart';
import 'editProfile/EditProfile.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  List<String> images = [];
  List<String> videos = [];
  List<String> history = [];
  String? _tempProfileImage;

  String username = 'Yordi Gonzales';
  String description = 'Añade una breve descripción';

  @override
  void initState() {
    super.initState();

    images = [
      'lib/assets/logo.png',
      'lib/assets/placeholder_user.jpg',
      'lib/assets/logo.png',
      'lib/assets/logo.png',
      'lib/assets/logo.png',
      'lib/assets/logo.png',
    ];

    videos = [
      'https://www.tom_w=pc',
      'https://www.tiktok.com/@webapp=1&sender_device=pc',
      'https://www.tiktbapp=1&sender_device=pc',
      'https://www.tiktok.cis_from_webapp=1&sender_device=pc',
    ];
  }

  void _updateProfile(String newUsername, String newDescription) {
    setState(() {
      username = newUsername;
      description = newDescription;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[600],
        title: Text(
          'Perfil',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return Container(
                    color: Colors.white,
                    child: Wrap(
                      children: <Widget>[
                        ListTile(
                          leading: Icon(Icons.settings),
                          title: Text(
                            'Configuración',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            // Acción para Configuración
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.exit_to_app),
                          title: Text(
                            'Cerrar sesión',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            // Acción para cerrar sesión
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.privacy_tip),
                          title: Text(
                            'Privacidad',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            // Acción para privacidad
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.help),
                          title: Text(
                            'Ayuda',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            // Acción para ayuda
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.security),
                          title: Text(
                            'Seguridad',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            // Acción para seguridad
                          },
                        ),
                        ListTile(
                          leading: Icon(Icons.notifications),
                          title: Text(
                            'Notificaciones',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onTap: () {},
                        ),
                      ],
                    ),
                  );
                },
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
                  Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfileDetailScreen(
                                imagePath: _tempProfileImage ?? 'lib/assets/placeholder_user.jpg',
                              ),
                            ),
                          );
                        },
                        child: Stack(
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: _tempProfileImage != null
                                  ? FileImage(File(_tempProfileImage!)) as ImageProvider<Object>?
                                  : AssetImage('lib/assets/placeholder_user.jpg'),
                            ),
                            Positioned(
                              bottom: -3,
                              right: 59,
                              child: GestureDetector(
                                onTap: () {
                                  openImagePicker(context, ImageSource.gallery);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blue,
                                    border: Border.all(color: Colors.white, width: 2.5),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Icon(
                                      Icons.camera_alt,
                                      color: Colors.white,
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
                  SizedBox(height: 12),
                  Text(
                    username,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Text(
                            'Seguidos',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '100',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 20),
                      Column(
                        children: [
                          Text(
                            'Seguidores',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '200',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(width: 20),
                      Column(
                        children: [
                          Text(
                            'Likes',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '500',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black,
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
                                onSave: _updateProfile,
                              ),
                            ),
                          );
                        },
                        child: Text('Editar Perfil'),
                      ),
                      SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Acción para Compartir
                        },
                        child: Text('Compartir'),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _buildButtonsSection(),
            SizedBox(height: 16),
            _buildContentSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonsSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 7.0),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildIconButton(Icons.image, 'Galería', () {
            setState(() {
              _showGallery = true;
              _showVideo = false;
              _showStories = false;
            });
          }, _showGallery),
          _buildIconButton(Icons.video_library, 'Snippets', () {
            setState(() {
              _showGallery = false;
              _showVideo = true;
              _showStories = false;
            });
          }, _showVideo),
          _buildIconButton(Icons.history_outlined, 'Historias', () {
            setState(() {
              _showGallery = false;
              _showVideo = false;
              _showStories = true;
            });
          }, _showStories),
        ],
      ),
    );
  }

  Widget _buildIconButton(
      IconData icon, String label, VoidCallback onPressed, bool isSelected) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(12.0), // Espacio interior alrededor del icono
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Colors.blue.withOpacity(0.3) : Colors.transparent,
            ),
            child: Icon(
              icon,
              size: 26, // Tamaño del icono
              color: isSelected ? Colors.blue : Colors.black,
            ),
          ),
          SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? Colors.blue : Colors.black,
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

  Widget _buildGalleryContent() {
    if (images.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.photo,
              size: 100,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No hay fotos disponibles',
              style: TextStyle(fontSize: 18, color: Colors.black),
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
        mainAxisSpacing: 2.0, // Espacio vertical entre los elementos
        crossAxisSpacing: 2.0, // Espacio horizontal entre los elementos
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImageDetailScreen(
                  imageUrls: images,
                  initialIndex: index,
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5.0),
              border: Border.all(color: Colors.white, width: 1.0), // Borde blanco delgado
              image: DecorationImage(
                image: AssetImage(images[index]),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );

      },

    );
  }

  Widget _buildVideoContent() {
    if (videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_off_rounded,
              size: 100,
              color: Colors.black,
            ),
            SizedBox(height: 16),
            Text(
              'No hay Snippets disponibles',
              style: TextStyle(fontSize: 18, color: Colors.black),
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
        mainAxisSpacing: 1.0,
        crossAxisSpacing: 1.0,
      ),
      itemCount: videos.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () {
            _playVideo(context, videos[index]);
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                'https://via.placeholder.com/150', // Placeholder image
                fit: BoxFit.cover,
              ),
              Align(
                alignment: Alignment.center,
                child: Icon(
                  Icons.play_circle_fill,
                  size: 50,
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
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
        builder: (context) => SnippetsDetailScreen(imageUrls: [], initialIndex: 1,),
      ),
    );
  }


  Widget _buildStoriesContent() {
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.timer_off_outlined,
              size: 100,
              color: Colors.black,
            ),
            SizedBox(height: 16),
            Text(
              'No hay Historias disponibles',
              style: TextStyle(fontSize: 18, color: Colors.black),
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


