import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_filters/flutter_image_filters.dart';



class PreviewPage extends StatefulWidget {
  final String imagePath; // Ruta de la imagen para previsualizar

  const PreviewPage({Key? key, required this.imagePath}) : super(key: key);

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  late TextureSource texture;
  late BrightnessShaderConfiguration configuration;
  bool textureLoaded = false;

  @override
  void initState() {
    super.initState();
    configuration = BrightnessShaderConfiguration();
    configuration.brightness = 0.5; // Configuración de brillo inicial
    TextureSource.fromFile(widget.imagePath as File)
        .then((value) => texture = value)
        .whenComplete(
          () => setState(() {
        textureLoaded = true;
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return textureLoaded
        ? ImageShaderPreview(
      texture: texture,
      configuration: configuration,
    )
        : const Center(child: CircularProgressIndicator());
  }
}
