import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Importa el paquete flutter_svg

class ImageDetailScreen extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImageDetailScreen({
    Key? key,
    required this.imageUrls,
    required this.initialIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(Duration(seconds: 2)); // Simula una carga
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Actualizado')),
          );
        },
        child: ListView.builder(
          itemCount: imageUrls.length,
          itemBuilder: (context, index) {
            return Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (index == 0) SizedBox(height: 16), // Solo añadir espacio antes de la primera imagen
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundImage: AssetImage('lib/assets/placeholder_user.jpg'), // Aquí debe ser la imagen del usuario
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Nombre del Usuario',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Icon(Icons.favorite_border),
                        SizedBox(width: 4),
                        Text('100 likes', style: TextStyle(color: Colors.black)),
                        SizedBox(width: 16),
                        SvgPicture.asset(
                          'lib/assets/mesage.svg',
                          height: 24,
                          width: 24,
                          color: Colors.black,
                        ),
                        SizedBox(width: 4),
                        Text('50 comentarios', style: TextStyle(color: Colors.black)),
                        SizedBox(width: 16),
                        Icon(Icons.share),
                        SizedBox(width: 4),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Image.asset(
                    imageUrls[index],
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
