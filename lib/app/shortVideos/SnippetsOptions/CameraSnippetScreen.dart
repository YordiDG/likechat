import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraSnippetScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraSnippetScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late List<CameraDescription> cameras;

  @override
  void initState() {
    super.initState();
    // Inicializa las cámaras disponibles
    _initializeCameras();
  }

  Future<void> _initializeCameras() async {
    try {
      // Obtén la lista de cámaras disponibles en el dispositivo
      cameras = await availableCameras();

      // Configura la cámara deseada (en este caso, la primera cámara disponible)
      _controller = CameraController(
        cameras.first, // Selecciona la primera cámara disponible
        ResolutionPreset.medium,
      );

      // Inicializa el controlador de la cámara
      _initializeControllerFuture = _controller.initialize();
    } catch (e) {
      print('Error inicializando cámaras: $e');
    }
  }

  @override
  void dispose() {
    // Asegúrate de liberar la cámara cuando no esté en uso
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cámara'),
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Si la conexión está completa, muestra la vista de la cámara
            return Stack(
              children: [
                CameraPreview(_controller), // Vista previa de la cámara

                // Botones y controles flotantes
                Positioned(
                  top: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.timer),
                        onPressed: () {
                          // Acción para el tiempo
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.filter),
                        onPressed: () {
                          // Acción para los filtros
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.switch_camera),
                        onPressed: () {
                          // Acción para cambiar la cámara
                        },
                      ),
                    ],
                  ),
                ),

                // Botón para grabar
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: FloatingActionButton(
                    onPressed: () {
                      // Acción para grabar
                    },
                    child: Icon(Icons.videocam),
                  ),
                ),

                // Botón para cargar foto o video desde galería
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton(
                    onPressed: () {
                      // Acción para cargar desde galería
                    },
                    child: Icon(Icons.photo_library),
                  ),
                ),

                // Botones de envío y publicación
                Positioned(
                  bottom: 80,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      FloatingActionButton(
                        onPressed: () {
                          // Acción para envío en vivo
                        },
                        child: Icon(Icons.live_tv),
                      ),
                      FloatingActionButton(
                        onPressed: () {
                          // Acción para publicar
                        },
                        child: Icon(Icons.publish),
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else {
            // Mientras se carga la cámara, muestra un indicador de carga
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
