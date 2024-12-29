import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class FontSizeProvider with ChangeNotifier {
  static const double extraSmall = 12.0;
  static const double small = 14.0;
  static const double medium = 16.0;
  static const double large = 18.0;

  double _fontSize = small;

  double get fontSize => _fontSize;

  // Factores de escala basados en el fontSize
  double get iconScale => _fontSize / medium;

  // Tamaños de iconos que escalan con el fontSize
  double get mainIconSize => 30.0 * iconScale;

  double get secondaryIconSize => 24.0 * iconScale;

  double get avatarSize => 48.0 * iconScale;

  // Tamaños de texto que escalan con el fontSize
  double get counterTextSize => (_fontSize) * iconScale; // Para contadores
  double get captionTextSize => _fontSize * iconScale; // Para descripciones
  double get usernameTextSize =>
      (_fontSize + 1) * iconScale; // Para nombres de usuario

  //para comentarios
  static const double commentAvatarSize = 32.0;

  void setFontSize(double newSize) {
    _fontSize = newSize;
    notifyListeners();
  }

}

class FontSizeScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.black,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        centerTitle: true,
        // Asegura que el texto esté centrado
        title: Text(
          'Tamaño de Texto',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Post Preview Card
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // User Header
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.grey[800],
                                  radius: fontSizeProvider.avatarSize / 2,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.grey[600],
                                    size: fontSizeProvider.avatarSize * 0.6,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Usuario',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: fontSizeProvider.usernameTextSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Post Content
                          Container(
                            height: 200,
                            color: Colors.grey[800],
                            child: Center(
                              child: Icon(
                                Icons.image,
                                color: Colors.grey[600],
                                size: fontSizeProvider.avatarSize,
                              ),
                            ),
                          ),
                          // Post Actions
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Grupo izquierdo de iconos
                                Row(
                                  children: [
                                    _buildInteractionColumn(
                                      icon: Icons.favorite,
                                      label: '85.4K',
                                      provider: fontSizeProvider,
                                    ),
                                  ],
                                ),
                                Spacer(),
                                _buildInteractionColumn(
                                  icon: FontAwesomeIcons.comment,
                                  label: '1,234',
                                  provider: fontSizeProvider,
                                ),
                                SizedBox(width: 12),
                                _buildInteractionColumn(
                                  icon: Icons.reply,
                                  label: 'Compartir',
                                  provider: fontSizeProvider,
                                ),
                                SizedBox(width: 12),
                                // Icono de guardar
                                _buildInteractionColumn(
                                  icon: Icons.bookmark,
                                  label: 'Guardar',
                                  provider: fontSizeProvider,
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: Colors.grey.shade800,
                            height: 1,
                            thickness: 0.2,
                          ),

                          // Caption
                          Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Comentarios',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: fontSizeProvider.fontSize,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(height: 8),
                                _buildCommentPreview(
                                    '@usuario1',
                                    'Este es un comentario de ejemplo',
                                    fontSizeProvider.fontSize),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 30),

                    // Modern Volume-like Slider
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey[900],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Icon(
                                Icons.text_fields,
                                color: Colors.grey[600],
                                size: fontSizeProvider.secondaryIconSize,
                              ),
                              Icon(
                                Icons.text_fields,
                                color: Colors.white,
                                size: fontSizeProvider.mainIconSize,
                              ),
                            ],
                          ),
                          SizedBox(height: 10),
                          SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 6,
                              thumbShape:
                                  RoundSliderThumbShape(enabledThumbRadius: 8),
                              overlayShape:
                                  RoundSliderOverlayShape(overlayRadius: 20),
                            ),
                            child: Slider(
                              value: fontSizeProvider.fontSize,
                              min: FontSizeProvider.extraSmall,
                              max: FontSizeProvider.large,
                              divisions: 3,
                              activeColor: Color(0xFF00FFFF),
                              inactiveColor: Colors.grey[800],
                              onChanged: (value) {
                                fontSizeProvider.setFontSize(value);
                              },
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Pequeña',
                                  overflow: TextOverflow.ellipsis,
                                  // Agrega elipsis al texto
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: fontSizeProvider.counterTextSize,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Mediana',
                                  overflow: TextOverflow.ellipsis,
                                  // Agrega elipsis al texto
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: fontSizeProvider.counterTextSize,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'Grande',
                                  overflow: TextOverflow.ellipsis,
                                  // Agrega elipsis al texto
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: fontSizeProvider.counterTextSize,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  'ExtraGrande',
                                  overflow: TextOverflow.ellipsis,
                                  // Agrega elipsis al texto
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: fontSizeProvider.counterTextSize,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Botón Aplicar
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 40),
            decoration: BoxDecoration(
              color: Colors.black,
              border: Border(
                top: BorderSide(color: Colors.grey[900]!, width: 1),
              ),
            ),
            child: ElevatedButton(
              onPressed: () {
                Fluttertoast.showToast(
                  msg: "Cambios Aplicados",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.grey.shade800,
                  textColor: Colors.white,
                  fontSize: fontSizeProvider.fontSize,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF9B30FF),
                padding: EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Aplicar Cambios',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCommentPreview(
      String username, String comment, double fontSize) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: FontSizeProvider.commentAvatarSize / 3,
            backgroundColor: Colors.grey[800],
            child: Icon(
              Icons.person,
              color: Colors.grey[600],
              size: FontSizeProvider.small,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: username + ' ',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize:
                          14.0, // Tamaño fijo para username en comentarios
                    ),
                  ),
                  TextSpan(
                    text: comment,
                    style: TextStyle(fontSize: fontSize),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionColumn({
    required IconData icon,
    required String label,
    required FontSizeProvider provider,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: Colors.white,
          size: provider.mainIconSize,
        ),
        SizedBox(height: 4),
        SizedBox(
          width: 60, // Define un ancho fijo para centrar el texto
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: provider.counterTextSize,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
            textAlign: TextAlign.center, // Asegura que el texto esté centrado
          ),
        ),
      ],
    );
  }

}
