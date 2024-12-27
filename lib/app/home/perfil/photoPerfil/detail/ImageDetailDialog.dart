import 'dart:convert';
import 'dart:ui';
import 'package:connectivity/connectivity.dart';
import 'package:crypto/crypto.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:intl/intl.dart';
import 'dart:io';
import '../../Services/ImageDatabaseHelper.dart';


class ProfileDetailScreen extends StatefulWidget {
  final String imagePath;
  final VoidCallback? onImageDeleted;

  const ProfileDetailScreen({
    Key? key,
    required this.imagePath,
    this.onImageDeleted,
  }) : super(key: key);

  @override
  _ProfileDetailScreenState createState() => _ProfileDetailScreenState();
}

class _ProfileDetailScreenState extends State<ProfileDetailScreen>
    with SingleTickerProviderStateMixin {
  late String imagePath;
  bool _isImageDeleted = false;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isDoubleTapped = false;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    imagePath = widget.imagePath;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
    });

    // Mostrar mensaje según el estado del "like"
    final message = _isLiked ? '¡Te gusta!' : 'Ya no te gusta';
    _showToast(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo con efecto blur
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              color: _isDoubleTapped
                  ? Colors.black.withOpacity(0.95)
                  : Colors.black.withOpacity(0.85),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
              child: Container(color: Colors.transparent),
            ),
          ),

          // Contenido principal
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                Expanded(
                  child: _buildMainContent(),
                ),
                if (!_isImageDeleted) _buildBottomBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTopBarButton(
            icon: Icons.close,
            onTap: () => Navigator.of(context).pop(),
          ),
          Row(
            children: [

              _buildTopBarButton(
                icon: Icons.delete,
                onTap: () => _showDeleteDialog(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopBarButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 25),
      ),
    );
  }

  Widget _buildMainContent() {
    return GestureDetector(
      onDoubleTap: () {
        setState(() => _isDoubleTapped = !_isDoubleTapped);
      },
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      child: Center(
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) => Transform.scale(
            scale: _scaleAnimation.value,
            child: Hero(
              tag: 'profile_image',
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.7,
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _isImageDeleted
                      ? _buildPlaceholderImage()
                      : _buildImageWidget(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageWidget() {
    return imagePath.contains('lib/assets/')
        ? Image.asset(
      imagePath,
      fit: BoxFit.contain,
    )
        : Image.file(
      File(imagePath),
      fit: BoxFit.contain,
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[900],
      child: const Center(
        child: Icon(
          Icons.person_outline,
          size: 100,
          color: Colors.white54,
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.only(bottom: 32, left: 20, right: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: Icons.save_alt,
            label: 'Guardar',
            onTap: () => _saveImage(context),
          ),
          _buildActionButton(
            icon: Icons.share_rounded,
            label: 'Compartir',
            onTap: () => _shareImage(context),
          ),
          _buildActionButtonLike(
            icon: _isLiked ? Icons.favorite : Icons.favorite_border,
            label: 'Me gusta',
            onTap: _toggleLike,
            isLiked: _isLiked,
          ),
        ],
      ),
    );
  }


  //dos iconos
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  //icono de likes
  Widget _buildActionButtonLike({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isLiked,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: isLiked ? Colors.red : Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(
              icon,
              color: isLiked ? Colors.red : Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }



  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Eliminar imagen',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          '¿Estás seguro de que quieres eliminar esta imagen?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.blue[200],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteImage(context);
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveImage(BuildContext context) async {
    try {
      // Verificar conexión
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        _showToast('Sin conexión a Internet');
        return;
      }

      // Verificar permisos
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        _showToast('Se requieren permisos de almacenamiento');
        return;
      }

      // Verificar archivo origen
      final File imageFile = File(imagePath);
      if (!imageFile.existsSync()) {
        _showToast('Imagen no encontrada');
        return;
      }

      // Verificar formato
      final String extension = path.extension(imagePath).toLowerCase();
      if (!_isValidImageFormat(extension)) {
        _showToast('Formato de imagen no soportado');
        return;
      }

      // Preparar directorio
      final directory = Directory('/storage/emulated/0/DCIM');
      final likeChatDirectory = Directory('${directory.path}/LikeChat/imagenes');

      if (!await likeChatDirectory.exists()) {
        await likeChatDirectory.create(recursive: true);
      }

      // Verificar si la imagen ya existe
      final List<FileSystemEntity> files = await likeChatDirectory.list().toList();
      bool imageAlreadyExists = false;

      // Obtener hash de la imagen actual
      final List<int> currentImageBytes = await imageFile.readAsBytes();
      final String currentImageHash = await _computeImageHash(currentImageBytes);

      // Comparar con imágenes existentes
      for (var file in files) {
        if (file is File && _isValidImageFormat(path.extension(file.path))) {
          final List<int> existingImageBytes = await file.readAsBytes();
          final String existingImageHash = await _computeImageHash(existingImageBytes);

          if (currentImageHash == existingImageHash) {
            imageAlreadyExists = true;
            _showToast('Esta imagen ya está guardada');
            return;
          }
        }
      }

      // Si no existe, guardar la imagen
      if (!imageAlreadyExists) {
        final String fileName = _generateFileName(extension);
        final String newPath = '${likeChatDirectory.path}/$fileName';

        await imageFile.copy(newPath);
        _showToast('¡Imagen guardada!');
        await _scanFile(newPath);
      }

    } catch (e) {
      _showToast('Error al guardar imagen');
      print('Error saving image: $e');
    }
  }

// Función para calcular el hash de una imagen
  Future<String> _computeImageHash(List<int> bytes) async {
    try {
      // Generar el hash SHA-256 de los bytes de la imagen
      final digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      print('Error computing hash: $e');
      // Fallback seguro en caso de error
      final timestamp = DateTime.now().microsecondsSinceEpoch;
      final fallbackData = bytes.length.toString() + timestamp.toString();
      final fallbackHash = sha256.convert(utf8.encode(fallbackData));
      return fallbackHash.toString();
    }
  }

// Función auxiliar para generar nombre de archivo con fecha y hora
  String _generateFileName(String extension) {
    final DateTime now = DateTime.now();
    final String dateTime = DateFormat('yyyyMMddHHmmss').format(now);
    final String uniqueCode = (now.microsecondsSinceEpoch % 10000).toString().padLeft(4, '0');
    return 'IMG_${dateTime}_$uniqueCode$extension';
  }

  bool _isValidImageFormat(String extension) {
    return [
      '.jpg', '.jpeg', '.png', '.gif', '.webp',
      '.heic', '.heif', '.bmp', '.tiff', '.tif'
    ].contains(extension);
  }


  Future<void> _deleteImage(BuildContext context) async {
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

            setState(() {
              imagePath = 'lib/assets/placeholder_user.jpg';
              _isImageDeleted = true;
            });

            if (widget.onImageDeleted != null) {
              widget.onImageDeleted!();
            }
          }
        }
      }
    } catch (e) {
      _showToast('Error al eliminar imagen');
      print('Error deleting image: $e');
    }
  }

  Future<void> _shareImage(BuildContext context) async {
    try {
      final File imageFile = File(imagePath);
      if (!imageFile.existsSync()) {
        _showToast('Imagen no encontrada');
        return;
      }

      await Share.shareXFiles(
        [XFile(imageFile.path)],
        text: 'Compartido desde LikeChat',
      );
    } catch (e) {
      _showToast('Error al compartir imagen');
      print('Error sharing image: $e');
    }
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey.shade800,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> _scanFile(String path) async {
    try {
      if (Platform.isAndroid) {
        await SystemChannels.platform
            .invokeMethod('MediaScanner.scanFile', path);
      }
    } catch (e) {
      print('Error scanning file: $e');
    }
  }
}