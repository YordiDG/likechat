import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../../../../../APIS-Consumir/Deezer-API-Musica/MusicModal.dart';
import '../../../../../Globales/estadoDark-White/DarkModeProvider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../eventos/ShareButton.dart';
import 'configuracion/Maps/MapScreen.dart';
import 'configuracion/Privacidad/PrivacyOptionsModal.dart';
import 'package:provider/provider.dart';

import 'configuracion/Promocionar/PromotionPreview.dart';
import 'configuracion/EtiquetasAmigos/FriendsModal.dart';


class PreviewScreen extends StatefulWidget {
  final String imagePath;
  final TextEditingController descriptionController;
  final VoidCallback onPublish;

  PreviewScreen({
    required this.imagePath,
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

  @override
  void initState() {
    super.initState();
    _images.add(File(widget.imagePath));
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


  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final background = darkModeProvider.backgroundColor;

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          // Ajusta el margen izquierdo
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: iconColor),
            // Flecha personalizada
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        leadingWidth: 28,
        // Ajusta el ancho del leading
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
                  fontSize: 20,
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
                backgroundColor: Colors.cyan,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(
                    horizontal: 16, vertical: 6), // Padding interno
              ),
              child: Text(
                'Publicar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
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
          iconColor: Colors.greenAccent,
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
        iconColor: Colors.cyan,
        title: 'Privacidad',
        subtitle: 'Controla quién puede ver tu post',
        onTap: () {
          _showOptionsModalPrivacity(
              context); // Llama al método para mostrar el modal
        },
      ),
      _buildSettingsItem(
        icon: Icons.campaign,
        iconColor: Colors.redAccent,
        title: 'Promocionar publicación',
        subtitle: 'Aumenta el alcance de tu contenido',
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) =>
                  PromotionPreview(
                    imageUrl: 'https://cdn.pixabay.com/photo/2021/09/20/23/03/car-6642036_1280.jpg',
                    // Reemplaza con la URL real
                    textColor: textColor,
                  ),
            ),
          );
        },
      ),
      _buildSettingsItem(
        icon: Icons.location_on,
        iconColor: Colors.blueAccent,
        title: 'Seleccionar ubicación',
        subtitle: 'Comparte dónde estás',
        onTap: () {
          _showOptionsModal(context, 'Seleccionar ubicación');
        },
      ),
      _buildSettingsItem(
        icon: Icons.schedule,
        iconColor: Colors.amber,
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
        .animate(delay: 100. ms)
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.1, end: 0),
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
    final iconColor = darkModeProvider.iconColor;
    final background = darkModeProvider.backgroundColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Circular icon container
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade800 : Colors.grey
                      .shade300,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Text content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // Chevron icon
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

  Widget buildPublicationSettings() {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final background = darkModeProvider.backgroundColor;

    return Column(
      children: [
        Divider(
          color: Colors.grey[100],
          thickness: 0.2,
        ),
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
                Icons.settings, // Ícono de la flecha o ícono que desees
                color: textColor,
              ),
              SizedBox(width: 8), // Espacio entre el ícono y el texto
              Text(
                'Configuración de Publicación',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  //imagen
  Widget buildImageList() {
    return Container(
      height: 300.0,
      margin: EdgeInsets.all(10.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _images.length,
        itemBuilder: (context, index) {
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 5.0),
            decoration: BoxDecoration(
              image: DecorationImage(
                image: FileImage(_images[index]),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(10.0),
            ),
            width: MediaQuery
                .of(context)
                .size
                .width * 0.8,
          );
        },
      ),
    );
  }

  //carrucel de opciones
  Widget buildCarousel() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CarouselSlider(
            items: [
              _buildCarouselButton(
                onPressed: _pickImage,
                icon: Icons.add_photo_alternate,
                label: 'Añadir Foto',
              ),
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
              _buildCarouselButton(
                onPressed: _addTags,
                icon: Icons.tag,
                label: 'Etiquetas',
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

  //descripcion
  Widget buildDescriptionInput() {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: TextField(
        controller: widget.descriptionController,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          filled: true,
          fillColor: isDarkMode ? Colors.black : Colors.grey[200],
          // Fondo negro
          hintText: 'Agrega una breve descripción...',
          hintStyle: TextStyle(color: textColor, fontSize: 13),
          border: InputBorder.none,
          // Sin borde
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.cyan,
                width: 1.0), // Borde cyan cuando está en foco
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent,
                width: 1.0), // Borde transparente cuando está habilitado
          ),
        ),
        maxLines: 2,
        cursorColor: Colors.cyan,
      ),
    );
  }


  void _editMedia() async {
    // Muestra un diálogo o pantalla para editar el medio
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
      // Implementa la lógica según el tipo de medio
      if (result == 'image') {
        // Navegar a la pantalla de edición de imágenes
      } else if (result == 'video') {
        // Navegar a la pantalla de edición de videos
      }
    }
  }

  //api de freezer d emusic
  void _showMusicModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MusicModal();
      },
    );
  }

  void _addLocation() async {
    // Obtiene la ubicación actual del usuario o abre un mapa para seleccionar una ubicación
    final location = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MapScreen(),
      ),
    );

    if (location != null) {
      // Implementa la lógica para manejar la ubicación seleccionada
      print('Ubicación seleccionada: $location');
      // Puedes actualizar el estado o hacer otra cosa con la ubicación
    }
  }

  void _addTags() async {
    final TextEditingController _controller = TextEditingController();
    final List<String> tags = []; // Lista para almacenar las etiquetas

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
      // Implementa la lógica para manejar las etiquetas ingresadas
      tags.addAll(result);
      print('Etiquetas añadidas: $tags');
      // Puedes actualizar el estado o hacer otra cosa con las etiquetas
    }
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
        // Relleno ajustado
        elevation: 5, // Agregar elevación para mayor profundidad
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Tamaño mínimo del botón
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20.0, color: Colors.white),
          SizedBox(width: 3.0), // Espacio entre el icono y el texto
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

  //opciones adicionales va a cambial
  void _showOptionsModal(BuildContext context, String title) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          height: 250, // Ajusta la altura según lo que necesites
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              // Aquí puedes agregar más opciones para cada sección
              Text('Opción 1', style: TextStyle(color: Colors.white)),
              Text('Opción 2', style: TextStyle(color: Colors.white)),
              // Agrega más opciones según sea necesario
            ],
          ),
        );
      },
    );
  }

  //privacidad
  void _showOptionsModalPrivacity(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return PrivacyOptionsModal(
          isFullScreen: isModal, // Aquí pasas isModal
        );
      },
    );
  }

}
