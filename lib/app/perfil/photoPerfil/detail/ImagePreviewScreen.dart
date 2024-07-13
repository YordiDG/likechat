import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';

import '../filterPhoto/ImageFilterService.dart';


class ImagePreviewScreen extends StatefulWidget {
  final String imagePath;
  final void Function(String newImagePath) onUpdateProfileImage;

  const ImagePreviewScreen({Key? key, required this.imagePath, required this.onUpdateProfileImage}) : super(key: key);

  @override
  _ImagePreviewScreenState createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  File? _editedImage;
  int _selectedIndex = -1;
  final ImagePicker _picker = ImagePicker();
  final PreviewPage _filterService = PreviewPage(imagePath: '',);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Previsualización',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red,),
            onPressed: _handleDeleteImage

          ),
          IconButton(
            icon: Icon(Icons.check, color: Colors.white),
            onPressed: () {
              Navigator.pop(context, _editedImage?.path ?? widget.imagePath);
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: _editedImage == null
                  ? Image.file(
                File(widget.imagePath),
                fit: BoxFit.contain,
              )
                  : PreviewPage(imagePath: _editedImage!.path),
            ),
          ),
          Container(
            color: Color(0xFF0D0D55), // Color de fondo para resaltar las opciones
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                _buildFooterButton(
                  icon: Icons.crop,
                  index: 0,
                  onPressed: _cropImage,
                ),
                _buildFooterButton(
                  icon: Icons.text_fields,
                  index: 1,
                  onPressed: _addTextToImage,
                ),
                _buildFooterButton(
                  icon: Icons.camera,
                  index: 2,
                  onPressed: _takePhoto,
                ),
                _buildFooterButton(
                  icon: Icons.photo,
                  index: 3,
                  onPressed: _selectFromGallery,
                ),
                _buildFooterButton(
                  icon: Icons.filter_alt_outlined,
                  index: 4,
                  onPressed: _applyFilter,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButton({required IconData icon, required int index, required VoidCallback onPressed}) {
    return IconButton(
      icon: Icon(icon),
      onPressed: () {
        setState(() {
          _selectedIndex = index;
        });
        onPressed();
      },
      color: _selectedIndex == index ? Colors.blue : Colors.white, // Cambia el color según el botón seleccionado
      iconSize: 28.0,
    );
  }

  Future<void> _cropImage() async {
    try {
      CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: widget.imagePath,
      );

      if (croppedFile != null) {
        setState(() {
          _editedImage = File(croppedFile.path);
          _selectedIndex = 0; // Actualiza el índice del botón seleccionado
        });
      }
    } catch (e) {
      print('Error cropping image: $e');
      // Manejar el error según sea necesario
    }
  }

  void _addTextToImage() {
    // Implementa la funcionalidad para añadir texto a la imagen
    // Por ejemplo, mostrar un diálogo para introducir el texto
    showDialog(
      context: context,
      builder: (context) {
        String? inputText;
        return AlertDialog(
          title: Text('Agregar texto'),
          content: TextField(
            onChanged: (text) {
              inputText = text;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                // Implementa la lógica para añadir texto a la imagen aquí
                Navigator.of(context).pop();
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    ).then((_) {
      setState(() {
        _selectedIndex = 1; // Actualiza el índice del botón seleccionado
      });
    });
  }

  Future<void> _takePhoto() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        setState(() {
          _editedImage = File(pickedFile.path);
          _selectedIndex = 2; // Actualiza el índice del botón seleccionado
        });
      }
    } catch (e) {
      print('Error taking photo: $e');
      // Manejar el error según sea necesario
    }
  }

  Future<void> _selectFromGallery() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _editedImage = File(pickedFile.path);
          _selectedIndex = 3; // Actualiza el índice del botón seleccionado
        });
      }
    } catch (e) {
      print('Error selecting image from gallery: $e');
      // Manejar el error según sea necesario
    }
  }

  void _handleDeleteImage() {
    if (_editedImage != null) {
      setState(() {
        _editedImage = null;
      });
    } else {
      Navigator.pop(context, widget.imagePath); // Regresa a la imagen anterior si no hay imagen editada
    }
  }

  void _applyFilter() {
    // Implementa la lógica para aplicar filtros utilizando ImageFilterService
    // y actualizar la imagen editada (_editedImage)
  }
}
