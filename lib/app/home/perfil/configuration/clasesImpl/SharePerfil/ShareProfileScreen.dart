import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';
import 'package:carousel_slider/carousel_slider.dart'; // Paquete para el carrusel

import '../../../../../estadoDark-White/DarkModeProvider.dart';

class ShareProfileScreen extends StatelessWidget {
  final Color tileColor;
  final Color textColor;
  final double fontSize;

  ShareProfileScreen({
    required this.tileColor,
    required this.textColor,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text('Compartir Perfil'),
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildShareOption(
              title: 'Compartir en Redes Sociales',
              icon: Icons.share,
              onTap: () {
                Share.share('¡Mira mi perfil en esta increíble app!');
              },
            ),
            SizedBox(height: 16.0),
            _buildShareOption(
              title: 'Copiar Enlace',
              icon: Icons.link,
              onTap: () {
                final profileLink = 'https://example.com/my-profile';
                Clipboard.setData(ClipboardData(text: profileLink));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Enlace copiado al portapapeles')),
                );
              },
            ),
            SizedBox(height: 16.0),
            _buildShareOption(
              title: 'Enviar por Mensaje',
              icon: Icons.message,
              onTap: () {
                Share.share('¡Mira mi perfil! https://example.com/my-profile');
              },
            ),
            SizedBox(height: 16.0),
            _buildShareOption(
              title: 'Compartir por Email',
              icon: Icons.email,
              onTap: () {
                Share.share('¡Hola! Te invito a visitar mi perfil: https://example.com/my-profile');
              },
            ),
            SizedBox(height: 16.0),
            _buildShareOption(
              title: 'Otras Opciones',
              icon: Icons.more_horiz,
              onTap: () {
                _showOtherOptionsModal(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShareOption({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.cyan,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: tileColor,
          size: 24.0,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: fontSize,
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 20.0,
          color: Colors.white,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showOtherOptionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 2,
                blurRadius: 6,
                offset: Offset(0, -3),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.0),
                color: Colors.grey.shade200,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.menu, color: Colors.black),
                    SizedBox(width: 8.0),
                    Text(
                      'Más Opciones',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              CarouselSlider(
                options: CarouselOptions(
                  height: 120.0, // Ajusta la altura para mostrar más elementos
                  viewportFraction: 0.3, // Ajusta el tamaño visible de cada elemento
                  enlargeCenterPage: true,
                  autoPlay: false,
                ),
                items: List.generate(5, (index) {
                  return Builder(
                    builder: (context) => Container(
                      width: MediaQuery.of(context).size.width * 0.3, // Ajusta el ancho de cada elemento
                      margin: EdgeInsets.symmetric(horizontal: 4.0), // Ajusta el margen entre los elementos
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ClipOval(
                            child: Image.network(
                              'https://via.placeholder.com/150', // Imágenes de ejemplo
                              width: 80.0,
                              height: 80.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 8.0),
                          Text(
                            'Nombre ${index + 1}', // Nombre de ejemplo
                            style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
              Divider(height: 40.0, color: Colors.grey.shade300),
              _buildOptionItem(context, 'Compartir en Historia', Icons.camera_alt),
              _buildOptionItem(context, 'Hacer un Dueto', Icons.music_note),
              _buildOptionItem(context, 'Ajustes Avanzados', Icons.settings),
              _buildOptionItem(context, 'Avisos', Icons.notifications),
              _buildOptionItem(context, 'Promocionar Contenido', Icons.star),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionItem(BuildContext context, String title, IconData icon) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      onTap: () {
        Navigator.pop(context);
        // Implementa la lógica para cada opción
      },
    );
  }
}
