import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';

import 'Maps/MapScreen.dart';

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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Flecha personalizada
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        leadingWidth: 56, // Ajusta el ancho del leading si es necesario
        backgroundColor: Colors.black,
        title: Text(
          'New Post',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: OutlinedButton(
              onPressed: widget.onPublish,
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.cyan,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            Container(
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
                    width: MediaQuery.of(context).size.width * 0.8,
                  );
                },
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CarouselSlider(
                    items: [
                      _buildCarouselButton(
                        onPressed: _pickImage,
                        icon: Icons.add_photo_alternate,
                        label: 'Add Foto',
                      ),
                      _buildCarouselButton(
                        onPressed: _editMedia,
                        icon: Icons.edit,
                        label: 'Editar',
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
                      // Ajustar el ancho de los botones
                      initialPage: 0,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15.0),
              child: TextField(
                controller: widget.descriptionController,
                style: TextStyle(color: Colors.white),  // Color del texto blanco
                decoration: InputDecoration(
                  filled: true,  // Habilitar el color de fondo
                  fillColor: Colors.black,  // Fondo negro
                  hintText: 'Agrega una breve descripción...',
                  hintStyle: TextStyle(color: Colors.grey[400]),  // Color del texto del hint
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black, width: 1.0), // por definir el borde
                  ),
                ),
                maxLines: 2,
              ),
            ),
            Divider(color: Colors.grey[850]),
            ListTile(
              leading: Container(
                width: 40,  // Ancho del contenedor
                height: 40, // Altura del contenedor
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2), // Fondo negro con opacidad
                  shape: BoxShape.circle, // Forma circular
                ),
                child: Icon(Icons.group_add, color: Colors.lightGreenAccent),
              ),
              title: Text('Etiquetar personas',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                // Acción para etiquetar personas
              },
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.lock, color: Colors.cyan),
              ),
              title: Text('Privacidad', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Acción para seleccionar privacidad
              },
            ),
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.campaign_sharp, size: 29, color: Colors.red),
              ),
              title: Text('Promocionar publicación',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                // Acción para promocionar publicación
              },
            ),
          ],
        ),
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
                Navigator.of(context).pop(_controller.text.split(',').map((e) => e.trim()).toList());
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
        backgroundColor: Colors.blueGrey[800], // Fondo del botón oscuro
        minimumSize: Size(100, 40), // Tamaño compacto del botón
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0), // Relleno ajustado
        elevation: 5, // Agregar elevación para mayor profundidad
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, // Tamaño mínimo del botón
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20.0, color: Colors.white),
          SizedBox(width: 8.0), // Espacio entre el icono y el texto
          Text(
            label,
            style: TextStyle(
              fontSize: 14.0,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

}
