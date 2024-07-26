import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'package:flutter/services.dart' show rootBundle;

class VideoDownloader {
  Future<void> downloadAndSaveVideo(String videoPath) async {
    try {
      // Verificar permisos de almacenamiento
      await _requestPermission();

      // Obtener la ruta de almacenamiento
      final directory = await _getStorageDirectory();
      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final newFilePath = '${directory.path}/LikeChat/$fileName.mp4';

      // Crear la carpeta si no existe
      final likeChatDirectory = Directory('${directory.path}/LikeChat');
      if (!await likeChatDirectory.exists()) {
        await likeChatDirectory.create(recursive: true);
      }

      // Cargar la marca de agua
      final watermarkFile = await _loadAsset('lib/assets/LikeChat.gif');

      // Agregar marca de agua al video
      await _addWatermark(videoPath, watermarkFile.path, newFilePath);

      // Mensaje de éxito
      print('Video guardado en: $newFilePath');
    } catch (e) {
      print('Error al guardar el video: $e');
    }
  }

  Future<void> _requestPermission() async {
    final status = await Permission.storage.request();
    if (!status.isGranted) {
      throw Exception('Permiso de almacenamiento no concedido');
    }
  }

  Future<Directory> _getStorageDirectory() async {
    final directory = await getExternalStorageDirectory();
    if (directory == null) {
      throw Exception('No se pudo obtener el directorio de almacenamiento');
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
    final command = '-i $inputPath -i $watermarkPath -filter_complex "overlay=10:10" $outputPath';

    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (returnCode != null) {
      if (ReturnCode.isSuccess(returnCode)) {
        print('Marca de agua añadida con éxito');
      } else {
        print('Error al añadir la marca de agua: $returnCode');
        print(await session.getOutput());
      }
    } else {
      print('Error desconocido al ejecutar el comando FFmpeg');
    }
  }
}
