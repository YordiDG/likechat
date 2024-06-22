import 'package:flutter/material.dart';

class SnippetsScreen extends StatefulWidget {
  @override
  _SnippetsScreenState createState() => _SnippetsScreenState();
}

class _SnippetsScreenState extends State<SnippetsScreen> {
  List<String> videos = [];

  @override
  void initState() {
    super.initState();
  }

  void addPhoto(String imagePath) {
    setState(() {
      // Agregar nueva imagen al inicio de la lista
      videos.insert(0, imagePath);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Snippets de Fotos'),
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

          addPhoto('new_image.jpg');
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildGalleryContent() {
    if (videos.isEmpty) {
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
            'No hay Snippets disponibles',
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
          'Contenido de Snippets',
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
          itemCount: videos.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // Acción al hacer clic en la imagen
                // Puedes implementar la lógica para mostrar la imagen en grande
                // o cualquier otra acción según tus necesidades
                print('Clic en el Snippets ${videos[index]}');
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  image: DecorationImage(
                    image: AssetImage(videos[index]),
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
      itemCount: videos.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: AssetImage(videos[index]),
          ),
          title: Text('Snippets ${index + 1}'),

        );
      },
    );
  }
}

