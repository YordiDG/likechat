import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ImageDetailGaleria extends StatefulWidget {
  final AssetEntity asset;
  final VoidCallback onClose;
  final VoidCallback onSelect;

  const ImageDetailGaleria({
    Key? key,
    required this.asset,
    required this.onClose,
    required this.onSelect,
  }) : super(key: key);

  @override
  _ImageDetailGaleriaState createState() => _ImageDetailGaleriaState();
}

class _ImageDetailGaleriaState extends State<ImageDetailGaleria> {
  Uint8List? highQualityImage;
  bool isLoading = true;
  bool isSelected = false;

  @override
  void initState() {
    super.initState();
    _loadHighQualityImage();
  }

  Future<void> _loadHighQualityImage() async {
    try {
      final file = await widget.asset.file;
      if (file != null) {
        final imageBytes = await file.readAsBytes();
        setState(() {
          highQualityImage = imageBytes;
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error cargando imagen de alta calidad: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get safe area insets
    final EdgeInsets safePadding = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Imagen a pantalla completa
          Center(
            child: isLoading
                ? Center(
              child: Lottie.asset(
                'lib/assets/loading/infinity_cyan.json',
                width: 60,
                height: 60,
              ),
            )
                : (highQualityImage != null
                ? InteractiveViewer(
              panEnabled: true,
              scaleEnabled: true,
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.memory(
                highQualityImage!,
                fit: BoxFit.contain,
                width: double.infinity,
                height: double.infinity,
                gaplessPlayback: true,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Text(
                      'Error al cargar la imagen',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            )
                : const Center(
              child: Text(
                'No se pudo cargar la imagen',
                style: TextStyle(color: Colors.white),
              ),
            )),
          ),

          // Top Row with Close Button and Checkbox
          Positioned(
            top: safePadding.top,
            left: 10,
            right: 10,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Botón de cierre
                  IconButton(
                    icon: Container(
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    onPressed: widget.onClose,
                  ),

                  // Checkbox personalizado
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isSelected = !isSelected;
                      });
                    },
                    child: Container(
                      width: 25,
                      height: 25,
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.cyan : Colors.grey.shade600,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.5),
                          width: 1,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 23,
                      )
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Botón de selección mejorado
          Positioned(
            bottom: safePadding.bottom + 20,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  if (isSelected) {
                    widget.onSelect();
                  } else {
                    Fluttertoast.showToast(
                      msg: "Imagen no seleccionada",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.TOP,
                      backgroundColor: Colors.grey.shade700,
                      textColor: Colors.white,
                      fontSize: 12.0,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSelected
                      ? Colors.cyan
                      : Colors.grey.shade800,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 70,
                      vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 6,
                ),
                child: Text(
                  'Seleccionar',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}