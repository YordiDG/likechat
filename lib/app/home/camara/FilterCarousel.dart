import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class FilterCarousel extends StatefulWidget {
  @override
  _FilterCarouselState createState() => _FilterCarouselState();
}

class _FilterCarouselState extends State<FilterCarousel> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;

  // Índice del filtro actual
  int _currentFilterIndex = 0;

  // Lista de filtros
  final List<String> filterOptions = [
    'Original',
    'Black & White',
    'Sepia',
    'High Exposure',
    'Cartoon',
    'Partial Desaturation'
  ];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  // Método para inicializar la cámara
  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    _cameraController = CameraController(cameras![0], ResolutionPreset.high);

    await _cameraController?.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Professional Filter Carousel'),
      ),
      body: Positioned.fill(
        child: GestureDetector(
          onHorizontalDragUpdate: (details) {
            setState(() {
              if (details.delta.dx > 0) {
                // Deslizar a la derecha
                _currentFilterIndex = (_currentFilterIndex + 1) % filterOptions.length;
              } else if (details.delta.dx < 0) {
                // Deslizar a la izquierda
                _currentFilterIndex = (_currentFilterIndex - 1 + filterOptions.length) % filterOptions.length;
              }
            });
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Verifica si la cámara está inicializada
              _cameraController != null && _cameraController!.value.isInitialized
                  ? CameraPreview(_cameraController!)
                  : Center(child: CircularProgressIndicator()),

              // Aplica el filtro seleccionado
              _applyFilter(filterOptions[_currentFilterIndex]),
            ],
          ),
        ),
      ),
    );
  }

  // Método para aplicar el filtro seleccionado
  Widget _applyFilter(String filterName) {
    switch (filterName) {
      case 'Black & White':
        return ColorFiltered(
          colorFilter: ColorFilter.mode(Colors.grey, BlendMode.saturation),
          child: CameraPreview(_cameraController!),
        );
      case 'Sepia':
        return ColorFiltered(
          colorFilter: ColorFilter.mode(Colors.brown, BlendMode.modulate),
          child: CameraPreview(_cameraController!),
        );
      case 'High Exposure':
        return ColorFiltered(
          colorFilter: ColorFilter.mode(Colors.white.withOpacity(0.8), BlendMode.lighten),
          child: CameraPreview(_cameraController!),
        );
      case 'Cartoon':
        return ColorFiltered(
          colorFilter: ColorFilter.matrix(<double>[
            1.5, 0.5, 0.5, 0, 0,
            0.5, 1.5, 0.5, 0, 0,
            0.5, 0.5, 1.5, 0, 0,
            0, 0, 0, 1, 0,
          ]),
          child: CameraPreview(_cameraController!),
        );
      case 'Partial Desaturation':
        return ColorFiltered(
          colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.3), BlendMode.saturation),
          child: CameraPreview(_cameraController!),
        );
      default:
        return CameraPreview(_cameraController!); // Filtro original
    }
  }
}
