import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';

class CameraScreenPost extends StatefulWidget {
  @override
  _CameraScreenPostState createState() => _CameraScreenPostState();
}

class _CameraScreenPostState extends State<CameraScreenPost> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _isCameraReady = false;
  XFile? _imageFile; // Archivo de imagen capturada

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Solicitar permiso de cámara
    bool cameraPermission = await _requestCameraPermission();
    if (!cameraPermission) {
      return;
    }

    // Inicializar la cámara
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    _controller = CameraController(firstCamera, ResolutionPreset.medium);
    _initializeControllerFuture = _controller.initialize();
    setState(() {
      _isCameraReady = true;
    });
  }

  Future<bool> _requestCameraPermission() async {
    PermissionStatus status = await Permission.camera.request();
    return status == PermissionStatus.granted;
  }

  void _onCapturePressed() async {
    try {
      XFile? capturedImage = await _controller.takePicture();
      if (capturedImage != null) {
        setState(() {
          _imageFile = capturedImage;
        });
      }
    } catch (e) {
      print('Error al capturar imagen: $e');
    }
  }

  Widget _buildCameraPreview() {
    if (_isCameraReady) {
      return CameraPreview(_controller);
    } else {
      return Center(child: CircularProgressIndicator());
    }
  }

  void _applyFilter() {
    if (_imageFile == null) return;

    img.Image image = img.decodeImage(File(_imageFile!.path).readAsBytesSync())!;
    img.Image filteredImage = applyFilter(image); // Aplicar el filtro (método personalizado)

    setState(() {
      _imageFile = null; // Limpiar la imagen original
      _imageFile = saveImage(filteredImage); // Guardar la imagen filtrada
    });
  }

  img.Image applyFilter(img.Image image) {
    // Implementar lógica de aplicación de filtros aquí
    // Por ejemplo, redimensionar, aplicar filtros de imagen, etc.
    return img.copyResize(image, width: 300); // Ejemplo de redimensionamiento
  }

  XFile saveImage(img.Image image) {
    // Guardar la imagen procesada en el dispositivo
    final Directory extDir = Directory.systemTemp;
    final String filePath = '${extDir.path}/${DateTime.now().millisecondsSinceEpoch}.png';
    File(filePath).writeAsBytesSync(img.encodePng(image));
    return XFile(filePath);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildCameraPreview(), // Vista previa de la cámara
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.all(8.0),
              color: Colors.black.withOpacity(0.5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: _onCapturePressed,
                    icon: Icon(Icons.camera, color: Colors.white),
                  ),
                  IconButton(
                    onPressed: _applyFilter,
                    icon: Icon(Icons.filter, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
