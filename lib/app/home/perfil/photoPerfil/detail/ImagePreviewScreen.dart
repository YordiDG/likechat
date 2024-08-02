import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:ui' as ui;

import '../../../shortVideos/PreviewVideo/opciones de edicion/TextEdit/TextEditorHandler.dart';
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
  late img.Image _image;
  bool _isImageLargeEnough = false;

  String _displayText = '';
  TextStyle _textStyle = TextStyle(
      fontSize: 30, color: Colors.white, fontFamily: 'OpenSans'
  );
  TextAlign _textAlign = TextAlign.center;
  Offset _textPosition = Offset(0, 0); // Posición inicial del texto

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      final file = File(widget.imagePath);
      final image = img.decodeImage(file.readAsBytesSync());
      if (image != null) {
        const minWidth = 1280;
        const minHeight = 720;

        setState(() {
          _image = image;
          _isImageLargeEnough = image.width >= minWidth && image.height >= minHeight;
        });
      }
    } catch (e) {
      print('Error loading image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
                if (_displayText.isNotEmpty)
                  Positioned(
                    left: _textPosition.dx,
                    top: _textPosition.dy,
                    child: Draggable(
                      feedback: _buildTextContainer(),
                      child: _buildTextContainer(),
                      onDragEnd: (details) {
                        setState(() {
                          _textPosition = details.offset;
                        });
                      },
                    ),
                  ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(
                        sigmaX: 5.0,
                        sigmaY: 5.0,
                      ),
                      child: Container(
                        color: Colors.teal.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.2,
                    child: BackdropFilter(
                      filter: ui.ImageFilter.blur(
                        sigmaX: 50.0,
                        sigmaY: 50.0,
                      ),
                      child: Container(
                        color: Colors.teal.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: _editedImage == null
                ? Image.file(
              File(widget.imagePath),
              fit: BoxFit.contain,
            )
                : PreviewPage(imagePath: _editedImage!.path),
          ),
          Positioned(
            bottom: 10.0,
            left: 0,
            right: 0,
            child: CarouselSlider(
              options: CarouselOptions(
                height: 60.0,
                viewportFraction: 0.15,
                enableInfiniteScroll: false,
                scrollDirection: Axis.horizontal,
                initialPage: 0,
              ),
              items: [
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
          Positioned(
            top: 30.0,
            left: 10.0,
            right: 10.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.pink,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context, _editedImage?.path ?? widget.imagePath);
                  },
                  child: Text('Publicar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextContainer() {
    return Container(
      color: Colors.black.withOpacity(0.3), // Fondo semitransparente
      padding: EdgeInsets.all(8.0),
      child: Text(
        _displayText,
        style: _textStyle,
        textAlign: _textAlign,
      ),
    );
  }

  Widget _buildFooterButton({required IconData icon, required int index, required VoidCallback onPressed}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.black.withOpacity(0.5),
      ),
      child: IconButton(
        icon: Icon(icon, color: _selectedIndex == index ? Colors.pink : Colors.white),
        onPressed: () {
          setState(() {
            _selectedIndex = index;
          });
          onPressed();
        },
        iconSize: 28.0,
      ),
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
          _selectedIndex = 0;
        });
      }
    } catch (e) {
      print('Error cropping image: $e');
    }
  }

  void _addTextToImage() {
    TextEditorHandler().openTextEditor(
      context,
          (String text, TextStyle style, TextAlign align) {
        _setText(text, style, align);
      },
    );
  }

  void _setText(String text, TextStyle style, TextAlign align) {
    setState(() {
      _displayText = text;
      _textStyle = style;
      _textAlign = align;
      _textPosition = Offset(
        MediaQuery.of(context).size.width / 2,
        MediaQuery.of(context).size.height / 2,
      ); // Posición inicial en el centro
    });
  }

  Future<void> _takePhoto() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        setState(() {
          _editedImage = File(pickedFile.path);
          _selectedIndex = 2;
        });
      }
    } catch (e) {
      print('Error taking photo: $e');
    }
  }

  Future<void> _selectFromGallery() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _editedImage = File(pickedFile.path);
          _selectedIndex = 3;
        });
      }
    } catch (e) {
      print('Error selecting image from gallery: $e');
    }
  }

  void _applyFilter() {
    // Implementa la lógica para aplicar filtros utilizando ImageFilterService
  }
}
