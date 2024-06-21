import 'package:flutter/material.dart';

class GalleryScreen extends StatefulWidget {
  @override
  _GalleryScreenState createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<String> images = []; // Lista de imágenes, puedes cargar tus imágenes aquí

  @override
  void initState() {
    super.initState();
    // Ejemplo: Cargar imágenes de algún origen (base de datos, red, etc.)
    images = [
      'image1.jpg',
      'image2.jpg',
      'image3.jpg',
    ];
  }

  void addPhoto(String imagePath) {
    setState(() {
      // Agregar nueva imagen al inicio de la lista
      images.insert(0, imagePath);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Galería de Fotos'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildGalleryContent(),
            SizedBox(height: 16),
            _buildGalleryList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aquí puedes implementar la lógica para añadir una nueva foto
          addPhoto('new_image.jpg'); // Ejemplo de agregar una nueva imagen
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildGalleryContent() {
    if (images.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.photo,
            size: 100,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No hay fotos disponibles',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Contenido de Galería',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8),
        // Implementación de la lista de imágenes en una cuadrícula o fila
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
          ),
          itemCount: images.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // Acción al hacer clic en la imagen
                // Puedes implementar la lógica para mostrar la imagen en grande
                // o cualquier otra acción según tus necesidades
                print('Clic en imagen ${images[index]}');
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: AssetImage(images[index]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGalleryList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: images.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage(images[index]),
          ),
          title: Text('Imagen ${index + 1}'),

        );
      },
    );
  }
}

