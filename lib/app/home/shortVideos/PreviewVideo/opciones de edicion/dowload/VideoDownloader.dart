import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'package:connectivity/connectivity.dart';

class VideoDownloader {
  final int maxSizeInMB = 50; // Tamaño máximo permitido en MB

  Future<void> downloadAndSaveVideo(String videoPath) async {
    try {
      // Verificar conexión a Internet
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        throw Exception('No hay conexión a Internet');
      }

      // Verificar permisos de almacenamiento
      await _requestPermission();

      // Verificar el tamaño del video
      final videoFile = File(videoPath);
      final fileSizeInMB = await _getFileSizeInMB(videoFile);
      if (fileSizeInMB > maxSizeInMB) {
        throw Exception('El video es demasiado grande. Tamaño máximo permitido: $maxSizeInMB MB');
      }

      // Obtener la ruta del directorio DCIM público
      final directory = await _getPublicDCIMDirectory();
      final likeChatDirectory = Directory('${directory.path}/LikeChat/videos');

      // Crear la carpeta "LikeChat" y subcarpeta "videos" si no existen
      if (!await likeChatDirectory.exists()) {
        await likeChatDirectory.create(recursive: true);
        print('Carpeta LikeChat/videos creada en: ${likeChatDirectory.path}');
      } else {
        print('Carpeta LikeChat/videos ya existe en: ${likeChatDirectory.path}');
      }

      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final newFilePath = '${likeChatDirectory.path}/$fileName.mp4';

      // Cargar la marca de agua
      final watermarkFile = await _loadAsset('lib/assets/LikeChat.gif');

      // Agregar marca de agua al video
      await _addWatermark(videoPath, watermarkFile.path, newFilePath);

      // Mensaje de éxito
      print('Video guardado en: $newFilePath');
    } catch (e) {
      throw Exception('Error al guardar el video: $e');
    }
  }

  Future<void> _requestPermission() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      throw Exception('Permiso de almacenamiento no concedido');
    }
  }

  Future<Directory> _getPublicDCIMDirectory() async {
    final directory = Directory('/storage/emulated/0/DCIM');
    if (!await directory.exists()) {
      throw Exception('No se pudo obtener el directorio DCIM');
    }
    return directory;
  }

  Future<File> _loadAsset(String assetPath) async {
    final byteData = await rootBundle.load(assetPath);
    final file = File('${(await getTemporaryDirectory()).path}/${assetPath.split('/').last}');
    await file.writeAsBytes(byteData.buffer.asUint8List(), flush: true);
    return file;
  }

  Future<void> _addWatermark(String inputPath, String watermarkPath, String outputPath) async {
    final command = '-i $inputPath -i $watermarkPath -filter_complex "overlay=10:10" -codec:a copy $outputPath';

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();
    final output = await session.getOutput();
    final logs = await session.getLogs();

    if (returnCode != null) {
      if (ReturnCode.isSuccess(returnCode)) {
        print('Marca de agua añadida con éxito');
      } else {
        throw Exception('Error al añadir la marca de agua: $returnCode\nOutput: $output\nLogs: $logs');
      }
    } else {
      throw Exception('Error desconocido al ejecutar el comando FFmpeg');
    }
  }



  Future<double> _getFileSizeInMB(File file) async {
    final fileSizeInBytes = await file.length();
    return fileSizeInBytes / (1024 * 1024);
  }
}

class VideoSaveScreen extends StatefulWidget {
  @override
  _VideoSaveScreenState createState() => _VideoSaveScreenState();
}

class _VideoSaveScreenState extends State<VideoSaveScreen> {
  bool _isLoading = false;
  String _message = '';

  final VideoDownloader _videoDownloader = VideoDownloader();

  Future<void> _saveVideo() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      // Simular la ruta del video
      String videoPath = '/path/to/your/video.mp4';

      await _videoDownloader.downloadAndSaveVideo(videoPath);

      setState(() {
        _message = '¡Video guardado con éxito!';
      });
      _showSnackBar(_message, Colors.green);
    } catch (e) {
      setState(() {
        _message = 'Error al guardar el video: $e';
      });
      _showSnackBar(_message, Colors.red);
    } finally {
      // Esperar 1 segundo antes de ocultar el mensaje y la animación de carga
      Timer(Duration(milliseconds: 1000), () {
        setState(() {
          _isLoading = false;
        });
      });
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        padding: EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Guardar Video'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveVideo,
                  child: Text('Guardar Video'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
