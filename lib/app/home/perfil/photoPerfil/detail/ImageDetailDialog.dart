import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:io';
import '../../../../Globales/estadoDark-White/DarkModeProvider.dart';
import '../../Services/ImageDatabaseHelper.dart';

class ProfileDetailScreen extends StatefulWidget {
  final String imagePath;
  final VoidCallback? onImageDeleted; // Nuevo parámetro para callback

  const ProfileDetailScreen({
    Key? key,
    required this.imagePath,
    this.onImageDeleted
  }) : super(key: key);

  @override
  _ProfileDetailScreenState createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen> {
  late String imagePath;
  bool _isImageDeleted = false;

  @override
  void initState() {
    super.initState();
    imagePath = widget.imagePath;
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final iconColor = darkModeProvider.iconColor;
    final backgroundColor = darkModeProvider.backgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // Muestra imagen o placeholder
            Center(
              child: _isImageDeleted
                  ? _buildPlaceholderImage()
                  : GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Hero(
                  tag: 'profile_image',
                  child: _buildImageWidget(),
                ),
              ),
            ),

            // Custom App Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: iconColor,
                    size: 23,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                actions: [
                  _buildActionButton(
                    icon: Icons.delete,
                    onPressed: () => _showDeleteDialog(context),
                  ),
                  if (!_isImageDeleted) ...[
                    _buildActionButton(
                      icon: Icons.share,
                      onPressed: () => _shareImage(context),
                    ),
                    _buildActionButton(
                      icon: Icons.save,
                      onPressed: () => _saveImage(context),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    return imagePath.contains('lib/assets/')
        ? Image.asset(
      imagePath,
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
    )
        : Image.file(
      File(imagePath),
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
    );
  }

  Widget _buildPlaceholderImage() {
    return Image.asset(
      'lib/assets/placeholder_user.jpg',
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Container(
        decoration: BoxDecoration(
          color: Colors.black54,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, color: Colors.white),
      ),
      onPressed: onPressed,
    );
  }

  // Eliminar imagen
  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar imagen', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('¿Estás seguro de que quieres eliminar esta imagen?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteImage(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // Eliminar imagen de la base de datos y archivo
  void _deleteImage(BuildContext context) async {
    try {
      final dbHelper = ImageDatabaseHelper();
      final profileImage = await dbHelper.getProfileImage();

      if (profileImage != null) {
        final result = await dbHelper.deleteImageByPath(imagePath);
        if (result > 0) {
          File imageFile = File(profileImage);
          if (imageFile.existsSync()) {
            await imageFile.delete();
            _showToast('Imagen eliminada');

            // Actualizar estado para mostrar placeholder
            setState(() {
              imagePath = 'lib/assets/placeholder_user.jpg';
              _isImageDeleted = true;
            });

            // Llamar al callback si está definido
            if (widget.onImageDeleted != null) {
              widget.onImageDeleted!();
            }

            // Opcional: Navegar atrás si es necesario
            // Navigator.of(context).pop();
          } else {
            _showToast('Imagen no encontrada');
          }
        } else {
          _showToast('Error al eliminar la imagen de la base de datos');
        }
      } else {
        _showToast('Imagen no encontrada');
      }
    } catch (e) {
      _showToast('Error al eliminar imagen');
      print('Error deleting image: $e');
    }
  }

  // Compartir imagen
  void _shareImage(BuildContext context) async {
    try {
      final File imageFile = File(imagePath);
      if (!imageFile.existsSync()) {
        _showToast('Imagen no encontrada');
        return;
      }

      // Compartir con SharePlus mostrando apps instaladas
      await Share.shareXFiles([XFile(imageFile.path)], text: 'Mira esta imagen');
    } catch (e) {
      _showToast('Error al compartir imagen');
      print('Error sharing image: $e');
    }
  }

  // Guardar imagen en la galería con ruta específica

  void _saveImage(BuildContext context) async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        _showToast('Sin conexión a internet');
        return;
      }

      // Obtener el directorio de la aplicación
      final directory = await getApplicationDocumentsDirectory();
      final likeChatDirectory = Directory('${directory.path}/LikeChat/imagenes');

      // Crear el directorio si no existe
      if (!await likeChatDirectory.exists()) {
        await likeChatDirectory.create(recursive: true);
      }

      final File imageFile = File(imagePath);
      if (!imageFile.existsSync()) {
        _showToast('Imagen no encontrada');
        return;
      }

      // Generar un nombre de archivo único
      final String fileName = 'imagen_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final File newImageFile = File('${likeChatDirectory.path}/$fileName');

      // Copiar la imagen al nuevo directorio
      await imageFile.copy(newImageFile.path);

      // Opcional: Notificar al sistema sobre la nueva imagen
      await ImageGallerySaver.saveFile(newImageFile.path);

      _showToast('Imagen guardada en: ${newImageFile.path}');
    } catch (e) {
      _showToast('Error al guardar imagen');
      print('Error saving image: $e');
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.grey.shade800,
      textColor: Colors.white,
    );
  }

}