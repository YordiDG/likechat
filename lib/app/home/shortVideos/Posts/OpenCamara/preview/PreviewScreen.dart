import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:icons_plus/icons_plus.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../../../APIS-Consumir/Deezer-API-Musica/MusicModal.dart';
import '../../../../../Globales/estadoDark-White/DarkModeProvider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../Globales/estadoDark-White/Fuentes/FontSizeProvider.dart';
import '../../eventos/ShareButton.dart';
import 'configuracion/Maps/MapScreen.dart';
import 'configuracion/Privacidad/PrivacyOptionsModal.dart';
import 'package:provider/provider.dart';

import 'configuracion/Promocionar/PromotionPreview.dart';
import 'configuracion/EtiquetasAmigos/FriendsModal.dart';

class PreviewScreen extends StatefulWidget {
  final List<String> imagePaths;
  final TextEditingController descriptionController;
  final VoidCallback onPublish;

  PreviewScreen({
    required this.imagePaths,
    required this.descriptionController,
    required this.onPublish,
  });

  @override
  _PreviewScreenState createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> {
  final List<File> _images = [];
  final bool isModal = false;
  final ScrollController _controller = ScrollController();
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.imagePaths.isNotEmpty) {
      setState(() {
        _images.clear();
        _images.addAll(widget.imagePaths.map((path) => File(path)).toList());
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile>? images = await _picker.pickMultiImage();
    if (images != null) {
      setState(() {
        _images.addAll(images.map((image) => File(image.path)).toList());
      });
    }
  }

  Widget _buildAddPhotoButton() {
    return Positioned(
      bottom: 16,
      right: 16,
      child: FloatingActionButton(
        onPressed: _pickImage,
        backgroundColor: Colors.cyan,
        child: const Icon(Icons.add_photo_alternate, size: 30,color: Colors.white),
      ),
    );
  }

  Widget buildImageList() {
    if (_images.isEmpty) {
      return Container(
        height: 300.0,
        margin: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.photo_library_outlined,
                  size: 35, color: Colors.grey[600]),
              const SizedBox(height: 16),
              Text(
                'No hay imágenes seleccionadas',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Agregar Fotos'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 400.0,
      margin: const EdgeInsets.all(10.0),
      child: Stack(
        children: [
          CarouselSlider(
            items: _images.map((file) {
              return Stack(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: const EdgeInsets.symmetric(horizontal: 5.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15.0),
                      child: Image.file(
                        file,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      ),
                    ),
                  ),
                  // Botón de eliminar
                  Positioned(
                    top: 10,
                    left: 12,
                    child: GestureDetector(
                      onTap: () => _removeImage(_currentImageIndex),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          FontAwesomeIcons.close,
                          color: Colors.white,
                          size: 17,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
            options: CarouselOptions(
              height: 400.0,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
            ),
          ),
          // Indicadores de página
          if (_images.length > 1)
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _images.asMap().entries.map((entry) {
                  return Container(
                    width: 6.0,
                    height: 6.0,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _currentImageIndex == entry.key
                          ? Colors.white
                          : Colors.white.withOpacity(0.4),
                    ),
                  );
                }).toList(),
              ),
            ),
          // Contador de imágenes
          if (_images.length > 1)
            Positioned(
              top: 10,
              right: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.white.withOpacity(0.3)),
                ),
                child: Text(
                  '${_currentImageIndex + 1}/${_images.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          _buildAddPhotoButton()
        ],
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
      if (_currentImageIndex >= _images.length) {
        _currentImageIndex = _images.isEmpty ? 0 : _images.length - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final background = darkModeProvider.backgroundColor;
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios, size: 20, color: iconColor),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        leadingWidth: 28,
        backgroundColor: background,
        title: LayoutBuilder(
          builder: (context, constraints) {
            return FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Nuevo contenido',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontSize: fontSizeProvider.fontSize + 2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            );
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton(
              onPressed: widget.onPublish,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF9B30FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 17, vertical: 5),
              ),
              child: Text(
                'Publicar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: fontSizeProvider.fontSize,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildImageList(),
            buildCarousel(),
            buildDescriptionInput(),
            buildPublicationSettings(),
            _buildSettingsItem(
              icon: Icons.group_add,
              iconColor: Colors.grey,
              title: 'Etiquetar personas',
              subtitle: 'Agrega amigos a tu publicación',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => FriendsModales(),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.lock_outline,
              iconColor: Colors.grey,
              title: 'Privacidad',
              subtitle: 'Controla quién puede ver tu post',
              onTap: () {
                _showOptionsModalPrivacity(context);
              },
            ),
            _buildSettingsItem(
              icon: Icons.campaign,
              iconColor: Colors.grey,
              title: 'Promocionar publicación',
              subtitle: 'Aumenta el alcance de tu contenido',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PromotionPreview(
                      imageUrl:
                          'https://cdn.pixabay.com/photo/2021/09/20/23/03/car-6642036_1280.jpg',
                      textColor: textColor,
                    ),
                  ),
                );
              },
            ),
            _buildSettingsItem(
              icon: Icons.location_on,
              iconColor: Colors.grey,
              title: 'Seleccionar ubicación',
              subtitle: 'Comparte dónde estás',
              onTap: () {
                _showOptionsModal(context, 'Seleccionar ubicación');
              },
            ),
            _buildSettingsItem(
              icon: Icons.schedule,
              iconColor: Colors.grey,
              title: 'Programar publicación',
              subtitle: 'Elige cuándo publicar',
              onTap: () {
                _showOptionsModal(context, 'Programar publicación');
              },
            ),
            _buildSettingsItem(
              icon: Icons.more_horiz,
              iconColor: Colors.grey,
              title: 'Ver más',
              subtitle: 'Opciones adicionales',
              onTap: () {
                // Acción de ver más
              },
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: const Duration(milliseconds: 300))
          .slideY(begin: 0.1, end: 0),
    );
  }

  Widget buildCarousel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CarouselSlider(
            items: [
              _buildCarouselButton(
                onPressed: _editMedia,
                icon: Icons.edit,
                label: 'Editar',
              ),
              _buildCarouselButton(
                onPressed: () => _showMusicModal(context),
                icon: Icons.music_note,
                label: 'Musica',
              ),
              _buildCarouselButton(
                onPressed: _addLocation,
                icon: Icons.location_on,
                label: 'Ubicación',
              ),
            ],
            options: CarouselOptions(
              height: 42.0,
              enableInfiniteScroll: false,
              enlargeCenterPage: true,
              viewportFraction: 0.32,
              initialPage: 0,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDescriptionInput() {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: TextField(
        controller: widget.descriptionController,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          filled: true,
          fillColor: isDarkMode ? Colors.black : Colors.grey[200],
          hintText: 'Agrega una breve descripción...',
          hintStyle: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
              fontSize: fontSizeProvider.fontSize),
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.cyan, width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent, width: 1.0),
          ),
        ),
        maxLines: 2,
        cursorColor: Colors.cyan,
      ),
    );
  }

  Widget buildPublicationSettings() {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return Column(
      children: [
        Divider(color: Colors.grey[100], thickness: 0.2),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[850] : Colors.grey[100],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.settings,
                color: textColor,
              ),
              SizedBox(width: 8),
              Text(
                'Configuración de Publicación',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSizeProvider.fontSize + 1,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:
                      isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: fontSizeProvider.fontSize,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: fontSizeProvider.fontSize - 1.5,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCarouselButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.cyan,
        minimumSize: Size(150, 40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
        elevation: 5,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20.0, color: Colors.white),
          SizedBox(width: 3.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _editMedia() async {
    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Editar Medio'),
          content: Text('¿Qué deseas hacer con el medio?'),
          actions: <Widget>[
            TextButton(
              child: Text('Editar Imagen'),
              onPressed: () {
                Navigator.of(context).pop('image');
              },
            ),
            TextButton(
              child: Text('Editar Video'),
              onPressed: () {
                Navigator.of(context).pop('video');
              },
            ),
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
          ],
        );
      },
    );

    if (result != null) {
      if (result == 'image') {
        // Implementar edición de imágenes
      } else if (result == 'video') {
        // Implementar edición de videos
      }
    }
  }

  void _showMusicModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MusicModal();
      },
    );
  }

  void _addLocation() async {
    final location = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MapScreen(),
      ),
    );

    if (location != null) {
      print('Ubicación seleccionada: $location');
    }
  }

  void _addTags() async {
    final TextEditingController _controller = TextEditingController();
    final List<String> tags = [];

    final result = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Añadir Etiquetas'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Introduce etiquetas separadas por comas',
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Añadir'),
              onPressed: () {
                Navigator.of(context).pop(
                    _controller.text.split(',').map((e) => e.trim()).toList());
              },
            ),
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(null);
              },
            ),
          ],
        );
      },
    );

    if (result != null) {
      tags.addAll(result);
      print('Etiquetas añadidas: $tags');
    }
  }

  void _showOptionsModal(BuildContext context, String title) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          height: 250,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              Text('Opción 1', style: TextStyle(color: Colors.white)),
              Text('Opción 2', style: TextStyle(color: Colors.white)),
            ],
          ),
        );
      },
    );
  }

  void _showOptionsModalPrivacity(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return PrivacyOptionsModal(
          isFullScreen: isModal,
        );
      },
    );
  }
}

