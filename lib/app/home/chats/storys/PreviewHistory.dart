import 'dart:io';
import 'dart:math';
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
import '../../../Globales/estadoDark-White/Fuentes/FontSizeProvider.dart';
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

  // Variables para zoom y transformación
  // Variables para zoom y transformación
  double _scale = 1.0;
  double _previousScale = 1.0;
  Offset _offset = Offset.zero;
  Offset _previousOffset = Offset.zero;
  Map<int, TransformationData> _imageTransformations = {};

  // Variables para el gesto de eliminar
  bool _isDragging = false;
  double _dragExtent = 0.0;
  bool _showDeleteIcon = false;
  bool _hideWidgets = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentPage);
    // Inicializar transformaciones para cada imagen
    for (int i = 0; i < widget.images.length; i++) {
      _imageTransformations[i] = TransformationData();
    }
  }

  @override
  void dispose() {
    _pageController.dispose(); // Libera el controlador al destruir el widget
    super.dispose();
  }

  bool get _canDelete => _scale <= 1.0;

  void _handleScaleStart(ScaleStartDetails details) {
    _previousScale = _scale;
    _previousOffset = _offset;
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    setState(() {
      // Actualizar escala
      _scale = (_previousScale * details.scale)
          .clamp(0.5, 3.0); // Permitir reducir hasta 0.5x

      // Calcular límites de movimiento basados en el zoom
      final double maxOffset = 100.0 * (_scale - 1);

      // Actualizar posición con límites
      if (details.scale == 1.0) {
        final newOffset = _previousOffset + details.focalPointDelta;
        _offset = Offset(
          newOffset.dx.clamp(-maxOffset, maxOffset),
          newOffset.dy.clamp(-maxOffset, maxOffset),
        );
      }

      // Guardar transformación
      _imageTransformations[_currentPage] =
          TransformationData(scale: _scale, offset: _offset);
    });
  }

  void _handleVerticalDragUpdate(DragUpdateDetails details) {
    if (!_canDelete)
      return; // Solo permitir arrastre si la imagen no está ampliada

    setState(() {
      _isDragging = true;
      _hideWidgets = true;
      _dragExtent += details.delta.dy;
      _showDeleteIcon = _dragExtent.abs() > 150; // Aumentar umbral
    });
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    if (_showDeleteIcon && _canDelete) {
      HapticFeedback.heavyImpact();
      setState(() {
        widget.images.removeAt(_currentPage);
        if (widget.images.isEmpty) {
          Navigator.pop(context);
        } else {
          _currentPage = _currentPage.clamp(0, widget.images.length - 1);
          _pageController.jumpToPage(_currentPage);
        }
      });
    }

    setState(() {
      _isDragging = false;
      _hideWidgets = false;
      _dragExtent = 0.0;
      _showDeleteIcon = false;
    });
  }

  Widget _buildImageWithBlur(File image, int index) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Fondo borroso
        Transform.scale(
          scale: 1.2,
          child: Image.file(
            image,
            fit: BoxFit.cover,
          ),
        ),
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            color: Colors.black.withOpacity(0.3),
          ),
        ),
        // Imagen principal
        Transform(
          transform: Matrix4.identity()
            ..translate(_offset.dx, _offset.dy)
            ..scale(_scale),
          alignment: Alignment.center,
          child: Image.file(
            image,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          GestureDetector(
            onScaleStart: _handleScaleStart,
            onScaleUpdate: _handleScaleUpdate,
            onVerticalDragUpdate: _handleVerticalDragUpdate,
            onVerticalDragEnd: _handleVerticalDragEnd,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                  var transform = _imageTransformations[index];
                  _scale = transform?.scale ?? 1.0;
                  _offset = transform?.offset ?? Offset.zero;
                });
              },
              itemCount: widget.images.length,
              itemBuilder: (context, index) =>
                  _buildImageWithBlur(widget.images[index], index),
            ),
          ),

          Positioned(
            top: 40.0,
            left: 16.0,
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.black.withOpacity(0.2),
                        Colors.black.withOpacity(0.2),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 0.5,
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(40),
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 22.0,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Icono de eliminar mejorado
          if (_showDeleteIcon)
            Positioned(
              top: _dragExtent > 0 ? 50 : null,
              bottom: _dragExtent < 0 ? 50 : null,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                opacity: _showDeleteIcon ? 1.0 : 0.0,
                duration: Duration(milliseconds: 200),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),

          // Demás widgets solo si no estamos arrastrando
          if (!_hideWidgets) ...[
            _buildDescriptionInput(),
            _buildTopButtons(),
            _buildImageIndicators(),
            _buildBottomIcons(),
            _buildFloatingActionButton(),
            _buildStatusMessage(),
          ],
        ],
      ),
    );
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
                  filter: ImageFilter.blur(sigmaX: 70.0, sigmaY: 70.0),
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

  // metodo de carrucel de iconos inferiores
  Widget _buildBottomIcons() {
    if (_showIcons) {
      return Positioned(
        bottom: 0.0,
        left: 0,
        right: 0,
        child: SafeArea(
          child: ClipRect(
            child: Stack(
              children: [
                // Glassmorphism effect
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Colors.black.withOpacity(0.5),
                            width: 0.2,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Main content
                Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: BouncingScrollPhysics(),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        SizedBox(width: 8),
                        _buildEditButton(
                          icon: Icons.add_photo_alternate_rounded,
                          onPressed: () => _pickImage(),
                          tooltip: 'Fotos',
                          gradient: [Color(0xFF4CAF50), Color(0xFF2196F3)],
                        ),
                        _buildEditButton(
                          icon: Icons.crop_rounded,
                          onPressed: () {},
                          tooltip: 'Recortar',
                          gradient: [Color(0xFF9C27B0), Color(0xFF673AB7)],
                        ),
                        _buildEditButton(
                          icon: Icons.text_fields_rounded,
                          onPressed: () {
                            TextEditorHandler()
                                .openTextEditor(context, _setText);
                          },
                          tooltip: 'Texto',
                          gradient: [Color(0xFFE91E63), Color(0xFFF44336)],
                        ),
                        _buildEditButton(
                          icon: Icons.music_note_rounded,
                          onPressed: () => _showMusicModal(context),
                          tooltip: 'Música',
                          gradient: [Color(0xFFFF9800), Color(0xFFFF5722)],
                        ),
                        _buildEditButton(
                          icon: Icons.filter_vintage_rounded,
                          onPressed: () {},
                          tooltip: 'Filtros',
                          gradient: [Color(0xFF00BCD4), Color(0xFF03A9F4)],
                        ),
                        _buildEditButton(
                          icon: Icons.emoji_emotions_rounded,
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => StickerModal(),
                            );
                          },
                          tooltip: 'Stickers',
                          gradient: [Color(0xFFFFEB3B), Color(0xFFFFC107)],
                        ),
                        _buildEditButton(
                          icon: Icons.brush_rounded,
                          onPressed: () {
                            String imagePath = widget.images[0].path;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    DrawingPage(imagePath: imagePath),
                              ),
                            );
                          },
                          tooltip: 'Dibujo',
                          gradient: [Color(0xFF795548), Color(0xFF8D6E63)],
                        ),
                        _buildEditButton(
                          icon: Icons.auto_fix_high_rounded,
                          onPressed: () {},
                          tooltip: 'Ajustes',
                          gradient: [Color(0xFF607D8B), Color(0xFF455A64)],
                        ),
                        SizedBox(width: 16),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return SizedBox.shrink();
  }

  Widget _buildEditButton({
    required IconData icon,
    required VoidCallback onPressed,
    required String tooltip,
    required List<Color> gradient,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradient[0].withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onPressed();
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: EdgeInsets.all(12),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 4), // Increased spacing between icon and text
          Text(
            tooltip,
            style: TextStyle(
              color: Colors.white.withOpacity(0.95),
              fontSize: 10,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: Offset(0, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // metodo de añadir una descripcion
  Widget _buildDescriptionInput() {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final textColor = darkModeProvider.textColor;

    bool isToastShown =
        false; // Variable para controlar cuando se muestra el toast

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
          child: Stack(
            children: [
              TextField(
                controller: _descriptionController,
                style: TextStyle(
                  color: textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                onChanged: (text) {
                  setState(() {});
                  // Si intentan escribir más del límite y no se ha mostrado el toast
                  if (text.length >= 150 && !isToastShown) {
                    isToastShown = true; // Marcar que ya se mostró
                    Fluttertoast.showToast(
                        msg: "Límite de caracteres alcanzado",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.TOP,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.grey.shade800,
                        textColor: Colors.white,
                        fontSize: 10.0);
                    // Resetear la bandera después de un corto tiempo
                    Future.delayed(Duration(seconds: 2), () {
                      isToastShown = false;
                    });
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Añade una descripción...',
                  hintStyle: TextStyle(
                    color: textColor.withOpacity(0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                  border: InputBorder.none,
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.transparent),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.cyan.withOpacity(0.6)),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  contentPadding: EdgeInsets.only(
                    left: 16,
                    right: 40,
                    top: 12,
                    bottom: 12,
                  ),
                  counterText: '',
                ),
                maxLines: 3,
                maxLength: 150,
                cursorColor: Colors.cyan,
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _descriptionController,
                  builder: (context, value, child) {
                    return Text(
                      '${value.text.length}/150',
                      style: TextStyle(
                        color: value.text.length >= 140
                            ? Colors.cyan
                            : textColor.withOpacity(0.6),
                        fontSize: 8,
                        fontWeight: FontWeight.w400,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // maneja el boton de de publicar y toast
  Widget _buildTopButtons() {
    return Stack(
      children: [
        // Botón de Postear
        Positioned(
          top: 40.0,
          right: 16.0,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.0),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF9B30FF).withOpacity(0.9),
                      Color(0xFF9B30FF),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF9B30FF).withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () async {
                      HapticFeedback.mediumImpact();
                      await _postAllStories();

                      Fluttertoast.showToast(
                        msg: _statusMessage == 'Historia enviada con éxito'
                            ? 'Historia(s) enviada(s) con éxito'
                            : 'Error al enviar historia(s)',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.grey.shade800,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );

                      if (_statusMessage ==
                          'Historia(s) enviada(s) con éxito') {
                        Navigator.pop(context);
                      }
                    },
                    borderRadius: BorderRadius.circular(8.0),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Postear',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // puntos debajo de la imagnes carrucel
  Widget _buildImageIndicators() {
    if (widget.images.length > 1) {
      final int maxVisibleDots = 6; // Número máximo de puntos visibles
      final int totalImages = widget.images.length;

      // Ajustar el rango de índices visibles
      int startIndex = _currentPage - (maxVisibleDots ~/ 2);
      startIndex = startIndex.clamp(0, totalImages - maxVisibleDots);
      int endIndex = (startIndex + maxVisibleDots).clamp(0, totalImages);

      return Stack(
        children: [
          // Indicadores de puntos deslizables
          Positioned(
            bottom: 160.0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                  min(endIndex - startIndex, maxVisibleDots), (index) {
                final int realIndex = startIndex + index;
                final bool isActive = realIndex == _currentPage;

                // Calcular tamaño dinámico para el punto activo y los demás
                double size = isActive ? 5.5 : 4.5;

                return AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  margin: EdgeInsets.symmetric(horizontal: 3.0),
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? Colors.white : Colors.grey,
                  ),
                );
              }),
            ),
          ),

          // Contador de imágenes en la esquina superior derecha
          Positioned(
            top: 100.0,
            right: 16.0,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 9.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Text(
                '${(_currentPage + 1)}/$totalImages',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return SizedBox.shrink();
    }
  }

  // Method boton de comentario
  Widget _buildFloatingActionButton() {
    return Positioned(
      bottom: 140.0,
      left: 20.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.cyan.withOpacity(0.8),
                  Colors.cyan.shade600.withOpacity(0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 0.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyan.withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  HapticFeedback.mediumImpact();
                  setState(() {
                    _showIcons = !_showIcons;
                    _showDescription = !_showDescription;
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: AnimatedSwitcher(
                    duration: Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return RotationTransition(
                        turns: animation,
                        child: ScaleTransition(
                          scale: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Icon(
                      _showIcons
                          ? FontAwesomeIcons.solidComment
                          : FontAwesomeIcons.pencilAlt,
                      key: ValueKey<bool>(_showIcons),
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusMessage() {
    if (!_showStatusMessage) return Container();

    return Positioned(
      bottom: 90.0,
      left: 0,
      right: 0,
      child: Center(
        child: TweenAnimationBuilder<double>(
          duration: Duration(milliseconds: 300),
          tween: Tween<double>(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: child,
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                constraints: BoxConstraints(maxWidth: 300),
                padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.teal.withOpacity(0.85),
                      Colors.teal.shade700.withOpacity(0.95),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 15,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _statusMessage.contains('éxito')
                          ? Icons.check_circle_outline
                          : Icons.info_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _statusMessage,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
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
        _statusMessage =
            'Error al enviar historia(s). Verifique su conexión a Internet.';
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
      _statusMessage = success
          ? 'Historia(s) enviada(s) con éxito'
          : 'Error al enviar historia(s). Inténtelo de nuevo más tarde.';
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

  //cargar fotos de galeria:
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    var pickedFiles = await picker.pickMultiImage();

    if (pickedFiles != null) {
      // Limitar el número de imágenes a 20
      if (pickedFiles.length > 20) {
        // Mostrar mensaje de advertencia con Flutter Toast
        Fluttertoast.showToast(
          msg: "Solo se puede subir un máximo de 20 imágenes.",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.grey.shade800,
          textColor: Colors.white,
          fontSize: 11.0,
        );

        // Solo toma las primeras 20 imágenes
        pickedFiles = pickedFiles.take(20).toList();
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
      // Mostrar mensaje de que no se seleccionaron imágenes
      Fluttertoast.showToast(
        msg: "No se seleccionaron imágenes.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 3,
        backgroundColor: Color.fromRGBO(0, 255, 255, 0.5),
        textColor: Colors.white,
        fontSize: 16.0,
      );
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

//clase que oculta

class TransformationData {
  double scale;
  Offset offset;

  TransformationData({this.scale = 1.0, this.offset = Offset.zero});
}
