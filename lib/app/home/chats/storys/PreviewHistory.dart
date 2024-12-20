import 'dart:io';
import 'dart:ui';
import 'package:LikeChat/app/home/chats/storys/util/DrawingPainter.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../APIS-Consumir/Deezer-API-Musica/MusicModal.dart';
import '../../../APIS-Consumir/Tenor API/StickerModal.dart';
import '../../../Globales/estadoDark-White/DarkModeProvider.dart';
import '../../shortVideos/PreviewVideo/opciones de edicion/TextEdit/TextEditorHandler.dart';

class PreviewHistory extends StatefulWidget {
  final List<File> images;
  final Function(File) onPostStory;

  const PreviewHistory({required this.images, required this.onPostStory});

  @override
  _PreviewHistoryState createState() => _PreviewHistoryState();
}

class _PreviewHistoryState extends State<PreviewHistory> {
  PageController _pageController = PageController();
  int _currentPage = 0;
  String _statusMessage = '';
  bool _showStatusMessage = false;
  TextEditingController _descriptionController = TextEditingController();

  bool _showIcons = true;
  bool _showDescription = false;
  String _displayText = '';
  TextStyle _textStyle =
      TextStyle(fontSize: 30, color: Colors.white, fontFamily: 'OpenSans');
  TextAlign _textAlign = TextAlign.center;

  List<String> _stories = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
        initialPage: _currentPage); // inicializa con el índice actual
  }

  @override
  void dispose() {
    _pageController.dispose(); // Libera el controlador al destruir el widget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final blurHeight = screenHeight * 0.2;

    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final backgroundColor = darkModeProvider.backgroundColor;

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black, // Fondo negro
      statusBarIconBrightness: Brightness.light, // Letras blancas
    ));

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                return Image.file(
                  widget.images[index],
                  fit: BoxFit.cover,
                  color: Colors.black.withOpacity(0.2),
                  colorBlendMode: BlendMode.darken,
                );
              },
            ),
          ),
          // Desenfoque en la parte superior
          _buildImagePageView(),
          Positioned(
            top: 40.0,
            left: 16.0,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withOpacity(0.4),
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  Navigator.pop(context);
                },
                iconSize: 26.0,
              ),
            ),
          ),
          _buildDescriptionInput(),
          _buildTopButtons(),
          _buildImageIndicators(),
          _buildBottomIcons(),
          _buildFloatingActionButton(),
          _buildStatusMessage()
        ],
      ),
    );
  }

  // metodo de carrucel de iconos inferiores
  Widget _buildBottomIcons() {
    if (_showIcons) {
      return Positioned(
        bottom: 0.0,
        left: 0,
        right: 0,
        child: Container(
          color: Colors.grey.shade200.withOpacity(0.2),
          child: SizedBox(
            height: 65.0, // Ajustamos la altura para un mejor aspecto
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribuir los íconos equitativamente
                children: [
                  _buildEditButton(
                    icon: Icons.image,
                    onPressed: () => _pickImage(),
                    tooltip: 'Add Fotos',
                  ),
                  _buildEditButton(
                    icon: Icons.crop,
                    onPressed: () {
                      // Implementar funcionalidad de recorte
                    },
                    tooltip: 'Recortar',
                  ),
                  _buildEditButton(
                    icon: Icons.text_fields,
                    onPressed: () {
                      TextEditorHandler().openTextEditor(context, _setText);
                    },
                    tooltip: 'Texto',
                  ),
                  _buildEditButton(
                    icon: Icons.music_note,
                    onPressed: () => _showMusicModal(context),
                    tooltip: 'Música',
                  ),
                  _buildEditButton(
                    icon: Icons.filter_alt_outlined,
                    onPressed: () {
                      // Implementar funcionalidad de filtro
                    },
                    tooltip: 'Filtros',
                  ),
                  _buildEditButton(
                    icon: Icons.emoji_emotions,
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        builder: (context) => StickerModal(),
                      );
                    },
                    tooltip: 'Stickers',
                  ),
                  _buildEditButton(
                    icon: Icons.brush,
                    onPressed: () {
                      String imagePath = widget.images[0].path;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DrawingPage(imagePath: imagePath),
                        ),
                      );
                    },
                    tooltip: 'Dibujo',
                  ),
                  _buildEditButton(
                    icon: Icons.adjust,
                    onPressed: () {
                      // Implementar funcionalidad de ajuste
                    },
                    tooltip: 'Ajustes',
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return SizedBox.shrink(); // Retorna un widget vacío si _showIcons es falso
    }
  }


  // maneja el carrucel de imagens
  Widget _buildImagePageView() {
    return Center(
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        itemCount: widget.images.length,
        itemBuilder: (context, index) {
          return Stack(
            children: [
              Positioned.fill(
                child: Image.file(
                  widget.images[index],
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 50.0, sigmaY: 50.0),
                  child: Container(
                    color: Colors.transparent,
                  ),
                ),
              ),
              Center(
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.center,
                    widthFactor: 1.0,
                    heightFactor: 1.0,
                    child: Image.file(
                      widget.images[index],
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // metodo de añadir una descripcion
  Widget _buildDescriptionInput() {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final textColor = darkModeProvider.textColor;

    return Positioned(
      bottom: 0.1,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        opacity: _showDescription ? 1.0 : 0.0,
        duration: Duration(milliseconds: 300),
        child: Container(
          color: Colors.black.withOpacity(0.4),
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            controller: _descriptionController,
            style: TextStyle(color: textColor),
            decoration: InputDecoration(
              hintText: 'Añade una descripción...',
              hintStyle: TextStyle(color: textColor),
              border: InputBorder.none,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.transparent),
                borderRadius: BorderRadius.circular(8.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.cyan),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
            maxLines: 3,
            maxLength: 150,
            cursorColor: Colors.white,
          ),
        ),
      ),
    );
  }

  // maneja el boton de de publicar y toast
  Widget _buildTopButtons() {
    return Stack(
      children: [
        Positioned(
          top: 40.0,
          right: 16.0,
          child: Row(
            children: [
              ElevatedButton(
                onPressed: () async {
                  await _postAllStories();

                  // Mostrar el Toast con el mensaje correspondiente
                  Fluttertoast.showToast(
                    msg: _statusMessage == 'Historia enviada con éxito'
                        ? 'Historia(s) enviada(s) con éxito'
                        : 'Error al enviar historia(s)',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    // Posición del Toast
                    timeInSecForIosWeb: 1,
                    // Duración en iOS y web
                    backgroundColor: Colors.grey.shade800,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );

                  // Verifica si el mensaje es de éxito para cerrar la pantalla
                  if (_statusMessage == 'Historia(s) enviada(s) con éxito') {
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  'Postear',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: 40.0,
          left: MediaQuery.of(context).size.width / 2 - 22, // Centra el ícono de tachar
          child: Container(
            width: 50.0,
            height: 50.0,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.black.withOpacity(0.4),
            ),
            child: Center(
              child: IconButton(
                icon: Icon(Icons.delete, color: Colors.white),
                onPressed: () {
                  _deleteCurrentStory();
                },
                iconSize: 28.0,
                tooltip: 'Borrar historia',
              ),
            ),
          ),
        ),
      ],
    );
  }

  // metodo mide la imagnes seleccionada y hacer carrucel con los tres puntos
  Widget _buildImageIndicators() {
    if (widget.images.length > 1) {
      return Positioned(
        bottom: 160.0,
        left: 0,
        right: 0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.images.length, (index) {
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              width: 7.2,
              height: 7.2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _currentPage == index
                      ? Colors.grey.shade100
                      : Colors.transparent,
                  width: 0.1,
                ),
                color: _currentPage == index ? Colors.white : Colors.grey,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 2.0,
                    spreadRadius: 1.0,
                  ),
                ],
              ),
            );
          }),
        ),
      );
    } else {
      return SizedBox.shrink(); // Return an empty widget if the condition is not met
    }
  }

  // Method boton de comentario
  Widget _buildFloatingActionButton() {
    return Positioned(
      bottom: 140.0,
      left: 20.0,
      child: FloatingActionButton(
        onPressed: () {
          setState(() {
            _showIcons = !_showIcons;
            _showDescription = !_showDescription;
          });
        },
        backgroundColor: Colors.cyan.withOpacity(0.7),
        child: Icon(
          _showIcons ? FontAwesomeIcons.solidComment : FontAwesomeIcons.pencilAlt,
          color: Colors.white,
          size: 25,
        ),
      ),
    );
  }

  // Method de escribir comentario
  Widget _buildStatusMessage() {
    if (!_showStatusMessage) return Container();  // Return an empty container if not showing the message

    return Positioned(
      bottom: 90.0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        margin: EdgeInsets.symmetric(horizontal: 20.0),
        decoration: BoxDecoration(
          color: Colors.teal.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          _statusMessage,
          style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  void _setText(String text, TextStyle style, TextAlign align) {
    setState(() {
      _displayText = text;
      _textStyle = style;
      _textAlign = align;
    });
  }

  Future<void> _postAllStories() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      setState(() {
        _statusMessage = 'Error al enviar historia(s). Verifique su conexión a Internet.';
      });
      return;
    }

    bool success = true;
    for (File image in widget.images) {
      try {
        await widget.onPostStory(image);
      } catch (e) {
        print('Error al publicar historia: $e');
        success = false;
      }
    }

    setState(() {
      _statusMessage = success ? 'Historia(s) enviada(s) con éxito' : 'Error al enviar historia(s). Inténtelo de nuevo más tarde.';
    });
  }

  void _deleteCurrentStory() {
    final darkModeProvider =
        Provider.of<DarkModeProvider>(context, listen: false);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0), // Bordes más redondeados
          ),
          backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
          title: Text(
            'Eliminar Historia',
            style: TextStyle(
              color: textColor,
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            '¿Estás seguro de que deseas eliminar esta historia?',
            style: TextStyle(
              color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade800,
              fontSize: 15.0,
            ),
          ),
          actionsPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          actions: <Widget>[
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.grey.shade600),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(6.0), // Bordes redondeados
                ),
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
              ),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                  fontSize: 14.0,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo sin hacer nada
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent, // Color de fondo
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(6.0), // Bordes redondeados
                ),
                padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
              ),
              child: Text(
                'Eliminar',
                style: TextStyle(
                  color: Colors.white,
                  // Color del texto en blanco para contraste
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                ),
              ),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Cierra el diálogo antes de eliminar

                setState(() {
                  widget.images.removeAt(_currentPage);

                  if (widget.images.isEmpty) {
                    Navigator.of(context).pop(); // Cierra la vista actual
                    return;
                  } else {
                    _currentPage =
                        (_currentPage - 1).clamp(0, widget.images.length - 1);
                    _pageController.jumpToPage(_currentPage);
                  }
                });
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildEditButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 12.0), // Espaciado entre botones
        padding: EdgeInsets.symmetric(vertical: 6.0), // Ajustamos el padding para mejor distribución
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Tooltip(
              message: tooltip,
              child: Icon(
                icon,
                size: 33,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4.0),
            Flexible(
              fit: FlexFit.loose,
              child: Text(
                tooltip,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }


  //cargar fotos de galeria:
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    var pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      // Limitar el número de imágenes a 10
      if (pickedFiles.length > 10) {
        // Mostrar mensaje de advertencia y cortar la lista a 10 imágenes
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            'Solo se puede subir un máximo de 10 imágenes.',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          // Hacer que el snackbar flote
          duration: Duration(seconds: 3),
          // Duración del mensaje
          margin: EdgeInsets.all(16.0), // Margen para el snackbar
        ));
        // Solo toma las primeras 10 imágenes
        pickedFiles = pickedFiles.take(10).toList();
      }

      // Crear una lista para mantener las imágenes seleccionadas
      List<File> imagesToPreview =
          pickedFiles.map((file) => File(file.path)).toList();

      // Mostrar la pantalla de previsualización para todas las imágenes
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewHistory(
            images: imagesToPreview, // Pasar la lista de imágenes
            onPostStory: _postStory,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'No se seleccionaron imágenes.',
          style: TextStyle(color: Colors.white), // Color del texto
        ),
        backgroundColor: Color.fromRGBO(0, 255, 255, 0.5),
        // Fondo cian con opacidad
        behavior: SnackBarBehavior.floating,
        // Hacer que el snackbar flote
        duration: Duration(seconds: 3),
        // Duración del mensaje
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), // Bordes redondeados
          side: BorderSide(color: Colors.cyan, width: 2.0), // Borde cian
        ),
        margin: EdgeInsets.all(16.0), // Margen para el snackbar
      ));
    }
  }

  void _postStory(File image) {
    setState(() {
      _stories.add(image.path);
    });
    // Aquí puedes añadir el código para postear la historia en tu backend
  }

  void _showMusicModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return MusicModal();
      },
    );
  }
}
