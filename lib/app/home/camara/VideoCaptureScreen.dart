import 'dart:math';
import 'dart:ui';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async'; // Para manejar el temporizador
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import '../../APIS-Consumir/Deezer-API-Musica/MusicModal.dart';
import '../../APIS-Consumir/Tenor API/StickerModal.dart';
import '../../Globales/estadoDark-White/DarkModeProvider.dart';
import '../shortVideos/Posts/OpenCamara/preview/PreviewScreen.dart';
import 'Editar_Files/EditImageScreen.dart';
import 'Editar_Files/EditVideoScreen.dart';
import 'Files/GalleryPage.dart';
import 'FilterCarousel.dart';

class VideoCaptureScreen extends StatefulWidget {
  @override
  _VideoCaptureScreenState createState() => _VideoCaptureScreenState();
}

class _VideoCaptureScreenState extends State<VideoCaptureScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? cameras;
  late Timer _timer;

  double _recordingTime = 0.0; // Tiempo de grabación en segundos
  File? _image;

  String _selectedTab = "video";
  bool _isFlashOn = false;
  bool _isFrontCamera = true;
  bool _isFocusEnabled = false;

  bool isRecording = false;
  bool isPaused = false;
  bool isStopped = false;
  bool isResuming = false;

  final ImagePicker _picker = ImagePicker();
  bool _isVideoMode = false;

  String? _imageFilePath; // Ruta de la imagen
  String? _videoFilePath;

  // Índice del filtro actual
  int _currentFilterIndex = 0;

  bool _isExpanded =
      true; // Controla si los botones están expandidos o colapsados.

  int _selectedPage = 1; //para los label del final
  final PageController _pageController = PageController();

  int _selectedButtonVideo = 0; // Índice del botón seleccionado video")

  int _selectedButton =
      0; // Índice del botón seleccionado (0 para "Short", 1 para "Historia")

  final List<int> _durations = [20, 60, 180, 300]; // Duraciones en segundos

  //de fotos
  AssetEntity? _firstImage; // Primera imagen de la galería

  @override
  void initState() {
    super.initState();
    requestPermissions();
    _loadAssets();
  }

  // Solicitar permisos para cámara y micrófono
  void requestPermissions() async {
    // Solicitar permiso de cámara
    var cameraStatus = await Permission.camera.status;
    var microphoneStatus = await Permission.microphone.status;

    // Verificar y solicitar permiso de cámara
    if (!cameraStatus.isGranted) {
      cameraStatus = await Permission.camera.request();
    }

    // Verificar y solicitar permiso de micrófono
    if (!microphoneStatus.isGranted) {
      microphoneStatus = await Permission.microphone.request();
    }

    // Verificar si ambos permisos fueron otorgados
    if (cameraStatus.isGranted && microphoneStatus.isGranted) {
      initializeCamera();
    } else {
      // Si algún permiso es denegado, muestra un mensaje
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Permisos requeridos"),
          content: Text(
              "La aplicación necesita permisos de cámara y micrófono para funcionar correctamente."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  // Inicializar la cámara
  void initializeCamera() async {
    cameras = await availableCameras();
    CameraDescription selectedCamera;

    if (_isFrontCamera) {
      selectedCamera = cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
    } else {
      selectedCamera = cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
      );
    }

    // Desactiva el controlador anterior si existe
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }

    // Crea un nuevo controlador con la cámara seleccionada
    _cameraController = CameraController(
      selectedCamera,
      ResolutionPreset.high,
    );

    // Inicializa la cámara
    try {
      await _cameraController!.initialize();
      setState(() {});
    } catch (e) {
      print("Error al inicializar la cámara: $e");
    }
  }

// Método para alternar entre la cámara frontal y trasera
  void _toggleCamera() {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
    initializeCamera(); // Vuelve a inicializar la cámara cuando se cambia
  }

  Future<void> _loadAssets() async {
    try {
      final List<AssetPathEntity> assetPaths =
          await PhotoManager.getAssetPathList(onlyAll: true);

      if (assetPaths.isEmpty) {
        // Manejar caso donde no hay rutas de assets
        print('No se encontraron rutas de assets');
        return;
      }

      // Limpiamos cualquier imagen previa
      _firstImage = null;

      for (var path in assetPaths) {
        final int assetCount = await path.assetCountAsync;

        if (assetCount == 0) continue; // Saltar rutas vacías

        // Obtener la lista de imágenes
        final List<AssetEntity> assets =
            await path.getAssetListPaged(page: 0, size: assetCount);

        for (var asset in assets) {
          // Verifica que sea una imagen
          if (asset.type == AssetType.image) {
            _firstImage = asset; // Guarda la primera imagen encontrada
            break;
          }
        }

        // Si ya se encontró la primera imagen, salimos del bucle
        if (_firstImage != null) break;
      }

      setState(() {
        if (_firstImage == null) {
          print('No se encontraron imágenes');
        }
      });
    } catch (e) {
      print('Error al cargar assets: $e');
    }
  }

  /* metodoso de grabacion **/

  // Inicia la grabación
  void startRecording() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      print("La cámara no está inicializada.");
      return;
    }

    setState(() {
      isRecording = true;
      isPaused = false;
      isStopped = false;
      _recordingTime = 0.0; // Reiniciar el contador de tiempo
    });

    try {
      // Inicia la grabación de video usando la cámara
      await _cameraController!.startVideoRecording();

      // Ruta real para almacenar el video (asegúrate de usar un directorio válido)
      final directory = await getApplicationDocumentsDirectory();
      final videoPath =
          '${directory.path}/video_${DateTime.now().millisecondsSinceEpoch}.mp4'; // Ruta única para el video
      _videoFilePath = videoPath; // Guarda la ruta del archivo de video grabado

      print("Video grabando en: $_videoFilePath");

      // Timer para controlar el tiempo de grabación
      _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
        setState(() {
          if (isRecording) {
            _recordingTime += 0.1;
            if (_recordingTime >= _durations[_selectedButtonVideo]) {
              stopRecording(); // Detiene la grabación cuando llega al tiempo seleccionado
            }
          }
        });
      });
    } catch (e) {
      print("Error al grabar video: $e");
      stopRecording(); // Detener grabación en caso de error
    }
  }

  void stopRecording() async {
    setState(() {
      isRecording = false;
      isStopped = true;
    });

    // Detener la grabación de video
    try {
      final file = await _cameraController!.stopVideoRecording();
      _videoFilePath = file.path; // Asigna la ruta del archivo de video grabado
      print("Video grabado en: $_videoFilePath");
    } catch (e) {
      print("Error al detener la grabación de video: $e");
    }

    _timer?.cancel(); // Detener el temporizador
  }

  void pauseRecording() {
    setState(() {
      isRecording = false;
      isPaused = true;
    });
    _timer?.cancel(); // Detiene el temporizador
  }

  void resumeRecording() {
    if (isPaused) {
      setState(() {
        isRecording = true;
        isPaused = false;
        isResuming = true;

        Future.delayed(Duration(milliseconds: 500), () {
          setState(() {
            isResuming = false;
          });
        });
      });

      // Reanuda el temporizador
      _timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
        setState(() {
          if (isRecording) {
            _recordingTime += 0.1;
            if (_recordingTime >= _durations[_selectedButtonVideo]) {
              stopRecording(); // Detiene la grabación cuando llega al tiempo seleccionado
            }
          }
        });
      });
    }
  }

// Función para confirmar la grabación de video
  void confirmRecording() {
    print("Modo video: true");
    print("Ruta del video: $_videoFilePath");

    try {
      if (_videoFilePath != null && File(_videoFilePath!).existsSync()) {
        print("Archivo de video encontrado: $_videoFilePath");
        File fileToEdit = File(_videoFilePath!);

        // Navegar a la pantalla de edición de video
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditVideoScreen(file: fileToEdit),
          ),
        );
      } else {
        print("Archivo de video no válido o no encontrado.");
        _showErrorDialog(
            "No se encontró un archivo de video válido para editar.");
      }
    } catch (e) {
      print("Error en confirmRecording: $e");
      _showErrorDialog("Ocurrió un error al confirmar la grabación.");
    }
  }

// Función para mostrar el diálogo de confirmación
  void _showCancelConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: 15),
                Text(
                  "¿Está seguro?",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  "Si cancela ahora, perderá todo el progreso de la grabación y no podrá recuperarla.",
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.black,
                        backgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text("No"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        cancelRecording(); // Llama a la función de cancelación
                      },
                      child: Text(
                        "Sí, cancelar",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

// Cancela la grabación y reinicia el estado
  void cancelRecording() {
    setState(() {
      isRecording = false;
      isPaused = false;
      isStopped = false;
      isResuming = false; // Añadido
      _recordingTime = 0.0; // Reinicia el contador al cancelar
    });
    _timer.cancel();
  }

// Función para mostrar un diálogo de error
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Aceptar"),
            ),
          ],
        );
      },
    );
  }

  /***********************/

  // Función para tomar una foto o grabar un video
  void takePhoto() async {
    // Tomar la foto
    XFile file = await _cameraController!.takePicture();
    _imageFilePath = file.path; // Guardamos la ruta de la imagen
    print("Foto tomada en: ${file.path}");

    // Redirigir a la pantalla de edición de la imagen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditImageScreen(
            file: File(file.path), isVideo: false), // Solo manejamos imágenes
      ),
    );
  }

  /*Para fluxh*/
  Future<void> _requestPermissions() async {
    var status = await Permission.camera.request();
    if (status.isGranted) {
      await Permission.microphone.request();
    } else {
      // Manejar si no se conceden permisos
      print("Permisos de cámara no otorgados");
    }
  }

  // Activar o desactivar el flash
  Future<void> _toggleFlash() async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      // Verifica si la cámara actual es la trasera, ya que solo esa tiene flash
      if (_cameraController!.description.lensDirection ==
          CameraLensDirection.back) {
        print("Intentando alternar flash");
        print("Estado actual del flash: $_isFlashOn");

        try {
          if (_isFlashOn) {
            await _cameraController!.setFlashMode(FlashMode.off);
          } else {
            await _cameraController!.setFlashMode(FlashMode.torch);
          }

          setState(() {
            _isFlashOn = !_isFlashOn;
          });

          print("Flash alternado. Nuevo estado: $_isFlashOn");
        } catch (e) {
          print("Error al alternar el flash: $e");
        }
      } else {
        print("El flash no está disponible en la cámara frontal");
      }
    } else {
      print("Controlador de cámara no inicializado o no válido");
    }
  }

  //para enfocar
  void _toggleFocusMode() {
    setState(() {
      _isFocusEnabled = !_isFocusEnabled; // Alterna el estado del enfoque
    });
    print(_isFocusEnabled
        ? "Enfoque táctil activado"
        : "Enfoque táctil desactivado");
  }

  void _onTapToFocus(TapDownDetails details) async {
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      // Coordenadas donde el usuario tocó
      Offset position = details.localPosition;
      Size previewSize = MediaQuery.of(context).size;

      // Normaliza las coordenadas (0.0 a 1.0)
      double x = position.dx / previewSize.width;
      double y = position.dy / previewSize.height;

      try {
        await _cameraController!.setFocusPoint(Offset(x, y));
        print("Cámara enfocada en: ($x, $y)");
      } catch (e) {
        print("Error al intentar enfocar: $e");
      }
    }
  }

  Future<void> _usarMuestra() async {}

  //filtros
  Widget _applyFilter(String filterName) {
    // Verificar que _cameraController esté inicializado
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return Center(child: Text('Cámara no disponible'));
    }

    try {
      switch (filterName) {
        case 'Original':
          return CameraPreview(_cameraController!);

        case 'Black & White':
          return _colorFilteredCameraPreview(
              Colors.black, BlendMode.saturation);

        case 'Sepia':
          return _colorFilteredCameraPreview(Colors.pink, BlendMode.modulate);

        case 'Clarendon':
          return _colorFilteredCameraPreview(
              Colors.blue.withOpacity(0.5), BlendMode.colorDodge);

        case 'Juno':
          return _colorFilteredCameraPreview(
              Colors.red.withOpacity(0.5), BlendMode.modulate);

        case 'Lark':
          return _colorFilteredCameraPreview(
              Colors.green.withOpacity(0.5), BlendMode.colorDodge);

        case 'Ludwig':
          return _colorFilteredCameraPreview(
              Colors.white.withOpacity(0.5), BlendMode.lighten);

        case 'Amaro':
          return _colorFilteredCameraPreview(
              Colors.white.withOpacity(0.8), BlendMode.lighten);

        case 'Valencia':
          return _colorFilteredCameraPreview(
              Colors.orange.withOpacity(0.5), BlendMode.modulate);

        case 'Lo-Fi':
          return _colorFilteredCameraPreview(
              Colors.brown.withOpacity(0.4), BlendMode.darken);

        // TikTok Filters
        case 'Brew':
          return _colorFilteredCameraPreview(Colors.brown.withOpacity(0.9),
              BlendMode.modulate); // Warm and cozy

        case 'Cool Blue':
          return _colorFilteredCameraPreview(Colors.blue.withOpacity(0.9),
              BlendMode.modulate); // Cool tone effect

        case 'Brighten':
          return _colorFilteredCameraPreview(Colors.white.withOpacity(0.5),
              BlendMode.lighten); // Brightens the image

        case 'Vivid':
          return _colorFilteredCameraPreview(
              Colors.deepOrangeAccent.withOpacity(0.7),
              BlendMode.overlay); // Brightens the image
        // Nuevos filtros inspirados en TikTok
        case 'Vivid':
          return _colorFilteredCameraPreview(
              Colors.deepOrangeAccent.withOpacity(0.7), BlendMode.overlay);
        case 'Neon Glow':
          return _colorFilteredCameraPreview(
              Colors.cyan.withOpacity(0.9), BlendMode.screen);
        case 'Cinemático': // Filtro inspirado en tonos de cine
          return _colorFilteredCameraPreview(
              Colors.deepOrange.withOpacity(0.4), BlendMode.overlay);

        default:
          // Filtro normal si no se encuentra coincidencia
          return CameraPreview(_cameraController!);
      }
    } catch (e) {
      // Manejo de errores en caso de fallos
      return Center(child: Text('Error al aplicar filtro: $filterName'));
    }
  }

// Funciones auxiliares para filtros
  Widget _colorFilteredCameraPreview(Color color, BlendMode blendMode) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(color, blendMode),
      child: CameraPreview(_cameraController!),
    );
  }

// Lista de filtros actualizada
  final List<String> filterOptions = [
    'Original',
    'Black & White',
    'Sepia',
    'Clarendon',
    'Juno',
    'Lark',
    'Ludwig',
    'Amaro',
    'Valencia',
    'Lo-Fi',
    'Vivid', // Nuevo filtro
    'Neon Glow', // Nuevo filtro
    'Vintage', // Nuevo filtro
    'Dreamy', // Nuevo filtro
    'Cinematic', // Nuevo filtro
  ];

  //categoria
  final Map<String, List<String>> filterCategories = {
    'Populares': [], // Mantener vacía ya que los filtros son dinámicos
    'Crear': [],
    'Nuevos AI': [],
    'Herramienta': [],
    'Navidad': [],
    'Comedia': [],
    'Interactivo': [],
    'Ambiente': [],
    'Paisaje': [],
    'Edición': [],
    'Animales': [],
    'RA': [],
    'Eventos': [],
    'Música': [],
  };

  int _currentCategoryIndex = 0;

  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black.withOpacity(0.2),
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.4,
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Text(
                      'Selecciona un filtro',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      // Acción al presionar el ícono de búsqueda
                    },
                  ),
                ],
              ),

              // Carrusel de categorías
              SizedBox(
                height: 22,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: filterCategories.keys.length,
                  itemBuilder: (context, index) {
                    final category = filterCategories.keys.elementAt(index);
                    bool isSelected = _currentCategoryIndex == index;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentCategoryIndex =
                              index; // Cambia la categoría seleccionada
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          border: isSelected
                              ? Border(
                                  bottom:
                                      BorderSide(color: Colors.white, width: 1))
                              : null,
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? Colors.white : Colors.grey,
                            fontWeight:
                                isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 0.5,
                color: Colors.grey.withOpacity(0.2),
              ),

              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: filterOptions.length, // Lista de filtros
                  itemBuilder: (context, index) {
                    final filterName = filterOptions[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Cierra el modal
                        setState(() {
                          _currentFilterIndex = index; // Actualiza el índice
                        });
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.asset(
                              'lib/assets/placeholder_filter.png',
                              // Imagen del filtro
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            filterName,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _timer.cancel();
    _pageController.dispose();

    _timer.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Establecer el estilo de la barra de estado
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark, // Para dispositivos iOS
    ));

    return Scaffold(
      body: Container(
        color: Colors.black,
        child: Stack(
          children: [
            // Vista de la cámara, ocupando la pantalla hasta el carrusel
            Positioned.fill(
              top: 0,
              bottom: MediaQuery.of(context).size.height * 0.15,
              child: Stack(
                children: [
                  GestureDetector(
                    onHorizontalDragUpdate: (details) {
                      setState(() {
                        double sensitivity = 10.0;
                        if (details.primaryDelta != null) {
                          if (details.primaryDelta! > sensitivity) {
                            _currentFilterIndex = (_currentFilterIndex + 1) %
                                filterOptions.length;
                          } else if (details.primaryDelta! < -sensitivity) {
                            _currentFilterIndex = (_currentFilterIndex -
                                    1 +
                                    filterOptions.length) %
                                filterOptions.length;
                          }
                        }
                      });
                    },
                    child: _applyFilter(filterOptions[_currentFilterIndex]),
                  ),
                ],
              ),
            ),

            // Barra superior con íconos sidebar
            siderIcons(context),

            // Botón de cerrar (X) en la esquina superior derecha
            buildCloseButton(context),

            // controles de video
            buildRecordingControls(context),

            // Opción para seleccionar stickers o subir contenido
            buildPhotoPicker(context),

            // Efectos
            buildFilterButton(context),

            // Carrusel de botones
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildLabelCarousel(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelCarousel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
      ),
      padding: EdgeInsets.symmetric(vertical: 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_labels.length, (index) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPage = index;
                    });

                    // Si se selecciona "Album", navega a GalleryPage()
                    if (_labels[index] == "Album") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => GalleryPage()),
                      );
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        Text(
                          _labels[index],
                          style: TextStyle(
                            fontWeight: _selectedPage == index
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: _selectedPage == index
                                ? Colors.white
                                : Colors.grey,
                          ),
                        ),
                        if (_selectedPage == index)
                          Container(
                            height: 4,
                            width: 4,
                            margin: EdgeInsets.only(top: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  //metodo de iconos
  Widget siderIcons(BuildContext context) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Positioned(
          top: 60,
          left: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mostrar siempre el ícono del temporizador, sin importar si está expandido o colapsado
              _buildTopIcon(Icons.timer, "Temporizador", _usarMuestra),

              // Solo si está expandido, muestra todos los botones adicionales
              if (_isExpanded) ...[
                SizedBox(height: 8),
                _buildTopMusica(
                  Icons.queue_music_rounded,
                  "Música",
                  () => _Musica(context),
                ),
                SizedBox(height: 10),
                _buildTopIcon(Icons.emoji_nature, "Belleza", _usarMuestra),
                SizedBox(height: 8),
                _buildTopIcon(FontAwesomeIcons.smileBeam, "Emoji", () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (context) => StickerModal(),
                  );
                }),
                SizedBox(height: 8),
                if (!_isFrontCamera) ...[
                  _buildTopIcon(
                    _isFlashOn ? Icons.flash_on : Icons.flash_off,
                    "Flash",
                    _toggleFlash,
                    iconColor: _isFlashOn ? Colors.yellow : Colors.white,
                  ),
                  SizedBox(height: 8),
                ],
                _buildTopIcon(
                  _isFrontCamera ? Icons.camera_front : Icons.camera_rear,
                  _isFrontCamera ? "Cámara Frontal" : "Cámara Trasera",
                  _toggleCamera,
                ),
                SizedBox(height: 8),
                _buildTopIcon(
                  Icons.center_focus_strong,
                  "Enfoque",
                  _toggleFocusMode,
                  iconColor: _isFocusEnabled ? Colors.orange : Colors.white,
                ),
                SizedBox(height: 8),
                _buildTopIcon(
                  Icons.lightbulb,
                  "Inspiración",
                  _toggleFocusMode,
                  iconColor: _isFocusEnabled ? Colors.orange : Colors.white,
                ),
              ],
              SizedBox(height: 6),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: IconButton(
                        iconSize: 24,
                        padding: EdgeInsets.zero,
                        icon: Icon(
                          _isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: Colors.white, // Color blanco para el ícono.
                        ),
                        onPressed: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        tooltip: _isExpanded ? 'Ver menos' : 'Ver más',
                      ),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    _isExpanded ? 'Ver menos' : 'Ver más',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                      shadows: [
                        Shadow(
                          offset: Offset(1, 1),
                          blurRadius: 1,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  //close de cerrar
  Widget buildCloseButton(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 1,
      right: 20,
      child: SafeArea(
        child: Container(
          width: 34, // Ancho fijo
          height: 34, // Alto fijo
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 22,
              icon: Icon(
                Icons.close,
                color: Colors.white,
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(height: 15),
                            Text(
                              "¿Estás seguro de que quieres salir?",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Si sales ahora, el video se descartará y no se descargará. ¿Deseas continuar?",
                              style: TextStyle(
                                  fontSize: 13, color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    backgroundColor: Colors.grey[300],
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text("Cancelar"),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.redAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.pushNamed(context, '/home');
                                  },
                                  child: Text(
                                    "Continuar",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  //metodo de imagenes
  Widget buildPhotoPicker(BuildContext context) {
    return Positioned(
      bottom: 105,
      right: 40,
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickImage, // Aquí puedes manejar la selección de imagen
            child: Container(
              width: 37,
              height: 37,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              child: _image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _image!,
                        width: 37,
                        height: 37,
                        fit: BoxFit.cover,
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _firstImage != null
                          ? FutureBuilder<Widget>(
                              future: _firstImage!.thumbnailData.then((data) {
                                return Image.memory(data!, fit: BoxFit.cover);
                              }),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.done) {
                                  return snapshot.data ?? Container();
                                } else {
                                  return Image.asset(
                                    'lib/assets/placeholder-image.png',
                                    width: 37,
                                    height: 37,
                                    fit: BoxFit.cover,
                                  );
                                }
                              },
                            )
                          : Image.asset(
                              'lib/assets/placeholder-image.png',
                              width: 37,
                              height: 37,
                              fit: BoxFit.cover,
                            ),
                    ),
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Galería',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w700,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 1,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? pickedImage = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedImage != null) {
      // Guarda la imagen seleccionada
      final File selectedImage = File(pickedImage.path);

      // Navega a la clase EditImageScreen con la imagen seleccionada
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditImageScreen(
            file: selectedImage, // Pasa el archivo seleccionado
            isVideo: false, // Indica que no es un video
          ),
        ),
      );
    }
  }

  //metodos de efectos
  Widget buildFilterButton(BuildContext context) {
    return Positioned(
      bottom: 105,
      left: 40,
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              // Llama al método para mostrar el modal de filtros
              _showFilterModal(context);
            },
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 0.6),
              ),
              child: ClipOval(
                child: Image.asset(
                  'lib/assets/placeholder_filter.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Filtros',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w700,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 1,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Función para crear íconos en la parte superior izquierda
  Widget _buildTopIcon(IconData iconData, String label, VoidCallback onPressed,
      {Color? iconColor}) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        children: [
          CircleAvatar(
            radius: 24, // Aumenta el tamaño del círculo
            backgroundColor: Colors.black.withOpacity(0.3),
            child: Icon(
              iconData,
              color: iconColor ?? Colors.white,
              size: 30, // Aumenta el tamaño del ícono
            ),
          ),
          SizedBox(width: 6),
          RichText(
            text: TextSpan(
              children: label.split('').map((char) {
                return TextSpan(
                  text: char,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 1,
                        color: Colors.black,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopMusica(
      IconData iconData, String label, VoidCallback onPressed,
      {Color? iconColor}) {
    return GestureDetector(
      onTap: onPressed,
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.black.withOpacity(0.3),
            child: Icon(
              iconData,
              color: iconColor ??
                  Colors.white, // Aplica el color del ícono, si se especifica
            ),
          ),
          SizedBox(width: 6),
          // Usar RichText con TextSpan para aplicar un ligero borde a cada letra
          RichText(
            text: TextSpan(
              children: label.split('').map((char) {
                return TextSpan(
                  text: char,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: 13,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 1,
                        color: Colors.black,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Método musica modal

  void _Musica(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MusicModal();
      },
    );
  }

  //carrucel de botones final

  final List<String> _labels = ["Album", "Foto", "Video", "Short", "LIVE"];

  //controles de grabacion
  Widget buildRecordingControls(BuildContext context) {
    return Stack(
      children: [
        // Main recording/capture button
        Positioned(
          bottom: 110,
          left: MediaQuery.of(context).size.width / 2 - 40,
          child: GestureDetector(
            onTap: () {
              if (_selectedPage != 1) {
                if (isPaused) {
                  resumeRecording(); // Reanudar si estaba pausado
                } else if (isRecording) {
                  pauseRecording(); // Pausar si estaba grabando
                } else {
                  startRecording(); // Iniciar grabación si estaba detenida
                }
              } else {
                takePhoto(); // Capturar fotos en modo de fotos
              }
            },
            onLongPress: () {
              if (_selectedPage != 1 && !isRecording && !isPaused) {
                startRecording(); // Iniciar grabación con presión larga
              }
            },
            onLongPressUp: () {
              if (_selectedPage != 1 && isRecording) {
                pauseRecording(); // Pausar grabación al soltar
              }
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size(68, 68),
                  painter: ProgressCirclePainter(
                    progress: _getProgressBasedOnMode(),
                    showPauseIndicator: isPaused,
                    pausedTime: _recordingTime,
                    isRecording: isRecording,
                    isPaused: isPaused,
                  ),
                ),
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getButtonColorBasedOnMode(),
                  ),
                  child: _selectedPage == 3 &&
                          _selectedButton ==
                              1 // Cámara en la pestaña "Historia"
                      ? Icon(
                          Icons.history_edu,
                          color: Colors.white,
                          size: 38,
                        )
                      : _selectedPage == 3 // Rayo en la pestaña "Short"
                          ? Icon(
                              Icons.bolt, // Icono de rayo
                              color: Colors.white,
                              size: 55,
                            )
                          : null, // No mostrar ícono en otras pestañas
                ),
              ],
            ),
          ),
        ),

        // Timer display (for modes other than Photos)
        if ((isRecording || isPaused) && _selectedPage != 1)
          Positioned(
            bottom: 90,
            left: MediaQuery.of(context).size.width / 2 - 30,
            child: Text(
              _getTimerTextBasedOnMode(),
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

        // Confirmation/Cancel buttons
        if ((isPaused || isStopped) && _selectedPage != 1)
          Positioned(
            bottom: 80,
            left: MediaQuery.of(context).size.width / 2 - 80,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Cancel button
                GestureDetector(
                  onTap: () {
                    _showCancelConfirmationDialog();
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.clear,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                SizedBox(width: 70),
                // Confirm button
                GestureDetector(
                  onTap: () {
                    if (_selectedPage != 1) {
                      // Validación adicional si es necesaria
                      confirmRecording();
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.check_sharp,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Etiquetas encima del botón
        if (_selectedPage == 3)
          Positioned(
            bottom: 185,
            left: MediaQuery.of(context).size.width / 2 - 75,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildButton(
                  label: "Short",
                  isSelected: _selectedButton == 0,
                  onPressed: () {
                    setState(() {
                      _selectedButton = 0;
                    });
                  },
                ),
                SizedBox(width: 2),
                _buildButton(
                  label: "Historia",
                  isSelected: _selectedButton == 1,
                  onPressed: () {
                    setState(() {
                      _selectedButton = 1;
                    });
                  },
                ),
              ],
            ),
          ),

        // Etiquetas encima del botón
        if (_selectedPage == 2)
          Positioned(
            bottom: 185,
            left: MediaQuery.of(context).size.width / 2 - 75,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildButtonVideo(
                  label: "20s",
                  isSelected: _selectedButtonVideo == 0,
                  onPressed: () {
                    setState(() {
                      _selectedButtonVideo = 0;
                    });
                  },
                ),
                SizedBox(width: 9),
                _buildButtonVideo(
                  label: "60s",
                  isSelected: _selectedButtonVideo == 1,
                  onPressed: () {
                    setState(() {
                      _selectedButtonVideo = 1;
                    });
                  },
                ),
                SizedBox(width: 9),
                _buildButtonVideo(
                  label: "3min",
                  isSelected: _selectedButtonVideo == 2,
                  onPressed: () {
                    setState(() {
                      _selectedButtonVideo = 2;
                    });
                  },
                ),
                SizedBox(width: 9),
                _buildButtonVideo(
                  label: "5min",
                  isSelected: _selectedButtonVideo == 3,
                  onPressed: () {
                    setState(() {
                      _selectedButtonVideo = 3;
                    });
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }

  // Helper method to handle different modes and set button color
  Color _getButtonColorBasedOnMode() {
    if (_selectedPage == 1) return Colors.cyanAccent;
    if (_selectedPage == 2) return Color(0xFFFF3B30);
    if (_selectedPage == 3) return Color(0xFFFF3B30);
    return Colors.cyanAccent; // Default
  }

  double _getProgressBasedOnMode() {
    double maxTime;
    switch (_selectedPage) {
      case 2:
        maxTime = 20.0;
        break; // Videos
      case 3:
        maxTime = 10.0;
        break; // Shorts
      case 4:
        maxTime = 10.0;
        break; // Historias
      default:
        maxTime = 0.0;
    }
    return _recordingTime / maxTime; // Calcula progreso relativo
  }

  String _getTimerTextBasedOnMode() {
    double maxTime;
    switch (_selectedPage) {
      case 2:
        maxTime = 20.0;
        break; // Videos
      case 3:
        maxTime = 10.0;
        break; // Shorts
      case 4:
        maxTime = 10.0;
        break; // Historias
      default:
        maxTime = 0.0;
    }
    return '${_recordingTime.toStringAsFixed(1)} s / ${maxTime.toInt()} s';
  }

  //disñeo del boton de short o historias
  Widget _buildButton({
    required String label,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 25,
      width: 65,
      decoration: BoxDecoration(
        color: isSelected ? Colors.black.withOpacity(0.3) : Colors.transparent,
        borderRadius: BorderRadius.circular(7),
        border: isSelected
            ? Border.all(color: Colors.white.withOpacity(0.3))
            : null,
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  offset: Offset(1, 1),
                  blurRadius: 0.5,
                  color: Colors.black,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //disñeo de video
  Widget _buildButtonVideo({
    required String label,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return Container(
      height: 25,
      width: 44,
      decoration: BoxDecoration(
        color: isSelected ? Colors.white : Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(15),
        border:
            isSelected ? Border.all(color: Colors.grey.withOpacity(0.2)) : null,
      ),
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.black : Colors.white.withOpacity(0.5),
              fontSize: isSelected ? 13 : 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// CustomPainter para el progreso circular de grabación
class ProgressCirclePainter extends CustomPainter {
  final double progress;
  final bool showPauseIndicator;
  final double pausedTime;
  final bool isRecording;
  final bool isPaused;
  final bool isResuming;

  ProgressCirclePainter({
    required this.progress,
    required this.showPauseIndicator,
    required this.pausedTime,
    required this.isRecording,
    required this.isPaused,
    this.isResuming = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint backgroundPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Pincel para el progreso (cyan)
    Paint progressPaint = Paint()
      ..color = Colors.cyan
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    // Pincel para el indicador de pausa (blanco)
    Paint pauseIndicatorPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;

    // Dibujar el círculo de fondo
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), size.width / 2,
        backgroundPaint);

    // Calcular el ángulo de progreso
    double sweepAngle = 2 * pi * progress;

    // Condición para dibujar el progreso (grabando, pausado o reanudando)
    if (isRecording || isPaused || isResuming) {
      // Dibujar arco de progreso en cyan
      canvas.drawArc(
          Rect.fromCircle(
              center: Offset(size.width / 2, size.height / 2),
              radius: size.width / 2),
          -pi / 2, // Ángulo de inicio (parte superior del círculo)
          sweepAngle, // Ángulo del progreso
          false,
          progressPaint);

      // Añadir separador pequeño durante pausa o reanudación
      double separatorAngle = 0.05; // Ángulo muy pequeño para el separador
      if (isPaused || isResuming) {
        canvas.drawArc(
            Rect.fromCircle(
                center: Offset(size.width / 2, size.height / 2),
                radius: size.width / 2),
            -pi / 2 + sweepAngle, // Posición del inicio de la separación
            separatorAngle,
            false,
            pauseIndicatorPaint);
      }
    }
  }

  // Método para decidir si se debe redibujar
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Siempre redibuja para mostrar cambios de estado
    return true;
  }
}
