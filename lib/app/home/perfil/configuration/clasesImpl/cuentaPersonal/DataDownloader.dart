import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;

import '../../../../../Globales/estadoDark-White/DarkModeProvider.dart';


class DownloadDataScreen extends StatefulWidget {
  @override
  _DownloadDataScreenState createState() => _DownloadDataScreenState();
}

class _DownloadDataScreenState extends State<DownloadDataScreen> {
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final backgroundColor = darkModeProvider.backgroundColor;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: iconColor,
            size: 24,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Descargar tus Datos',
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        ),
        backgroundColor: backgroundColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Descarga una copia de tus datos personales.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 20),
            _buildDownloadTile(context),
            if (_isDownloading) _buildLoadingIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildDownloadTile(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDarkMode ? Colors.grey.shade600 : Colors.grey.shade400,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Icon(
          Icons.security_update,
          color: Colors.cyan,
        ),
        title: Text(
          'Descargar tus Datos',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          'Descarga una copia de tus datos personales.',
          style: TextStyle(
            color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade700,
            fontSize: 12,
          ),
        ),
        onTap: _isDownloading ? null : () => _downloadUserData(context),
        contentPadding: EdgeInsets.all(16),
      ),
    );
  }


  Widget _buildLoadingIndicator() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<void> _downloadUserData(BuildContext context) async {
    setState(() {
      _isDownloading = true;
    });

    // Simulamos datos de usuario
    final userData = {
      'nombre': 'Juan Pérez',
      'email': 'juan.perez@example.com',
      'publicaciones': [
        {
          'id': 1,
          'contenido': 'Mi primera publicación',
          'fecha': '2023-01-01',
          'comentarios': [
            {'usuario': 'Ana', 'comentario': '¡Genial!', 'fecha': '2023-01-01'},
            {'usuario': 'Luis', 'comentario': 'Interesante...', 'fecha': '2023-01-02'}
          ],
          'likes': 10
        },
        {
          'id': 2,
          'contenido': 'Mi segunda publicación',
          'fecha': '2023-01-02',
          'comentarios': [
            {'usuario': 'Carlos', 'comentario': 'Me gusta esto.', 'fecha': '2023-01-03'}
          ],
          'likes': 20
        },
      ],
      'seguidores': [
        {'nombre': 'Ana', 'email': 'ana@example.com'},
        {'nombre': 'Luis', 'email': 'luis@example.com'}
      ],
      'seguidos': [
        {'nombre': 'Carlos', 'email': 'carlos@example.com'},
        {'nombre': 'María', 'email': 'maria@example.com'}
      ],
    };

    // Cargamos la fuente personalizada
    final font = pw.Font.ttf(await rootBundle.load('assets/fonts/Pacifico-Regular.ttf'));

    // Convertimos los datos a un formato PDF
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Datos de Usuario', style: pw.TextStyle(font: font, fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 20),
              pw.Text('Nombre: ${userData['nombre']}', style: pw.TextStyle(font: font)),
              pw.Text('Email: ${userData['email']}', style: pw.TextStyle(font: font)),
              pw.SizedBox(height: 20),
              pw.Text('Publicaciones:', style: pw.TextStyle(font: font)),
              pw.Column(
                children: (userData['publicaciones'] as List<dynamic>?)?.map<pw.Widget>((post) {
                  return pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('ID: ${post['id']}', style: pw.TextStyle(font: font)),
                      pw.Text('Contenido: ${post['contenido']}', style: pw.TextStyle(font: font)),
                      pw.Text('Fecha: ${post['fecha']}', style: pw.TextStyle(font: font)),
                      pw.Text('Likes: ${post['likes']}', style: pw.TextStyle(font: font)),
                      pw.Text('Comentarios:', style: pw.TextStyle(font: font)),
                      pw.Column(
                        children: (post['comentarios'] as List<dynamic>?)?.map<pw.Widget>((comment) {
                          return pw.Text('${comment['usuario']}: ${comment['comentario']} (${comment['fecha']})', style: pw.TextStyle(font: font));
                        }).toList() ?? [],
                      ),
                      pw.SizedBox(height: 10),
                    ],
                  );
                }).toList() ?? [],
              ),
              pw.SizedBox(height: 20),
              pw.Text('Seguidores:', style: pw.TextStyle(font: font)),
              pw.Column(
                children: (userData['seguidores'] as List<dynamic>?)?.map<pw.Widget>((follower) {
                  return pw.Text('${follower['nombre']} (${follower['email']})', style: pw.TextStyle(font: font));
                }).toList() ?? [],
              ),
              pw.SizedBox(height: 20),
              pw.Text('Seguidos:', style: pw.TextStyle(font: font)),
              pw.Column(
                children: (userData['seguidos'] as List<dynamic>?)?.map<pw.Widget>((following) {
                  return pw.Text('${following['nombre']} (${following['email']})', style: pw.TextStyle(font: font));
                }).toList() ?? [],
              ),
            ],
          );
        },
      ),
    );

    // Guardamos el PDF en un archivo
    final outputFile = await _getFilePath();
    final file = File(outputFile);
    await file.writeAsBytes(await pdf.save());

    setState(() {
      _isDownloading = false;
    });

    // Lanzamos el archivo PDF
    await _launchFile(outputFile);
  }

  Future<String> _getFilePath() async {
    final directory = await getExternalStorageDirectory();
    final filePath = '${directory!.path}/user_data.pdf';
    return filePath;
  }

  Future<void> _launchFile(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await launchUrl(Uri.file(filePath));
    } else {
      // Manejar error si el archivo no existe
    }
  }
}
