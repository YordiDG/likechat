import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';

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
                backgroundColor: Colors.deepPurple,
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
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
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
                  height: 50.0,
                  enableInfiniteScroll: false,
                  enlargeCenterPage: true,
                  viewportFraction: 0.44, // Ajustar el ancho de los botones
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
                style: TextStyle(color: Colors.black,),
                decoration: InputDecoration(
                  hintText: 'Agregar una descripción...',
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey, width: 1.0),
                  ),
                ),
                maxLines: 2,
              ),
            ),
            Divider(color: Colors.grey),
            ListTile(
              leading: Icon(Icons.person_add_alt, color: Colors.blue),
              title: Text('Etiquetar personas',
                  style: TextStyle(color: Colors.white)),
              onTap: () {
                // Acción para etiquetar personas
              },
            ),
            ListTile(
              leading: Icon(Icons.lock, color: Colors.green),
              title: Text('Privacidad', style: TextStyle(color: Colors.white)),
              onTap: () {
                // Acción para seleccionar privacidad
              },
            ),
            ListTile(
              leading: Icon(Icons.trending_up, color: Colors.orange),
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

  void _editMedia() {
    // Acción para editar la imagen o video
    // Implementa la lógica necesaria
  }

  void _addLocation() {
    // Acción para añadir ubicación
    // Implementa la lógica necesaria
  }

  void _addTags() {
    // Acción para añadir etiquetas
    // Implementa la lógica necesaria
  }

  Widget _buildCarouselButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple, // Fondo morado
        minimumSize: Size(120, 30), // Ancho y alto mínimos del botón
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24.0, color: Colors.white),
          SizedBox(width: 8.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.white, // Letras blancas
              fontWeight: FontWeight.bold, // Letras en negrita
            ),
          ),
        ],
      ),
    );
  }
}
