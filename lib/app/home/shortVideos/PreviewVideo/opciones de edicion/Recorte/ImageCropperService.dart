import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class ImageCropperService {
  // Method to crop image with multiple configuration options
  Future<File?> cropImage({
    required File imageFile,
    CropAspectRatio? aspectRatio,
    int compressQuality = 100,
    int? maxWidth,
    int? maxHeight,
  }) async {
    try {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: aspectRatio ?? const CropAspectRatio(ratioX: 1, ratioY: 1),
        compressQuality: compressQuality,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Recortar Imagen',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Recortar Imagen',
            aspectRatioLockEnabled: false,
          ),
        ],
      );

      return croppedFile != null ? File(croppedFile.path) : null;
    } catch (e) {
      print('Error cropping image: $e');
      return null;
    }
  }

  // Method to show crop options with predefined aspect ratios
  Future<void> showCropOptions({
    required BuildContext context,
    required File imageFile,
    required Function(File) onCropped,
  }) async {
    // Show a bottom sheet with crop aspect ratio options
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Cuadrado'),
                onTap: () async {
                  Navigator.pop(context);
                  await _performCrop(
                    context,
                    imageFile,
                    onCropped,
                    aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
                  );
                },
              ),
              ListTile(
                title: const Text('16:9'),
                onTap: () async {
                  Navigator.pop(context);
                  await _performCrop(
                    context,
                    imageFile,
                    onCropped,
                    aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 9),
                  );
                },
              ),
              ListTile(
                title: const Text('4:3'),
                onTap: () async {
                  Navigator.pop(context);
                  await _performCrop(
                    context,
                    imageFile,
                    onCropped,
                    aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 3),
                  );
                },
              ),
              ListTile(
                title: const Text('Original'),
                onTap: () async {
                  Navigator.pop(context);
                  await _performCrop(
                    context,
                    imageFile,
                    onCropped,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Internal method to handle cropping with optional aspect ratio
  Future<void> _performCrop(
      BuildContext context,
      File imageFile,
      Function(File) onCropped, {
        CropAspectRatio? aspectRatio,
      }) async {
    File? croppedImage = await cropImage(
      imageFile: imageFile,
      aspectRatio: aspectRatio,
    );

    if (croppedImage != null) {
      onCropped(croppedImage);
    }
  }
}