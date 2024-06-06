import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;



class MyImageFilterApp extends StatefulWidget {
  @override
  _MyImageFilterAppState createState() => _MyImageFilterAppState();
}

class _MyImageFilterAppState extends State<MyImageFilterApp> {
  List<img.Image> imagenes = [];

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      final imagen = img.decodeImage(bytes);
      setState(() {
        imagenes.add(imagen!);
      });
    }
  }

  Widget _buildImagenes() {
    return GridView.builder(
      itemCount: imagenes.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
      ),
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _aplicarFiltros(index),
          child: Image.memory(
            _convertirAUInt8List(imagenes[index]),
            fit: BoxFit.cover,
          ),
        );
      },
    );
  }

  Uint8List _convertirAUInt8List(img.Image image) {
    return Uint8List.fromList(img.encodePng(image));
  }

  void _aplicarFiltros(int index) {
    final imagenOriginal = imagenes[index];

    // Aplicar filtro Sepia
    final filtroSepia = img.grayscale(imagenOriginal);

    // Aplicar filtro Cartoon
    final filtroCartoon = _aplicarCartoon(imagenOriginal);

    // Aplicar filtro Acuarela
    final filtroAcuarela = _aplicarAcuarela(imagenOriginal);

    // Reemplazar la imagen original con los filtros aplicados
    setState(() {
      imagenes[index] = filtroSepia;
      // Agregar las nuevas imágenes a la lista
      imagenes.add(filtroCartoon);
      imagenes.add(filtroAcuarela);
      // Si se desea aplicar el espejo, puedes hacerlo aquí
    });
  }

  img.Image _aplicarCartoon(img.Image imagen) {
    final grayscale = img.grayscale(imagen);
    final sobel = img.sobel(grayscale);
    return img.invert(sobel);
  }

  img.Image _aplicarAcuarela(img.Image imagen) {
    final blur = img.gaussianBlur(imagen, radius: 20);
    return img.colorOffset(blur, red: 30, green: 30, blue: 30);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filtros de Imágenes'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: imagenes.isEmpty
                ? Center(child: Text('No hay imágenes seleccionadas'))
                : _buildImagenes(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _seleccionarImagen,
        tooltip: 'Seleccionar Imagen',
        child: Icon(Icons.add),
      ),
    );
  }
}
