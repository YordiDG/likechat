import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../Globales/estadoDark-White/DarkModeProvider.dart';

class AccessibilitySettings extends StatefulWidget {
  final Color tileColor;
  final Color textColor;
  final Color sectionTitleColor;
  final Color titleColor;
  final Color descriptionColor;
  final double titleFontSize;
  final double sectionTitleFontSize;
  final double descriptionFontSize;

  AccessibilitySettings({
    required this.tileColor,
    required this.textColor,
    required this.sectionTitleColor,
    required this.titleColor,
    required this.descriptionColor,
    required this.titleFontSize,
    required this.sectionTitleFontSize,
    required this.descriptionFontSize,
  });

  @override
  _AccessibilitySettingsState createState() => _AccessibilitySettingsState();
}

class _AccessibilitySettingsState extends State<AccessibilitySettings> {
  bool textSizeEnabled = true;
  bool colorBlindModeEnabled = true;
  bool highContrastModeEnabled = true;
  bool screenReaderEnabled = true;
  bool gestureNavigationEnabled = true;

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Configuración de Accesibilidad',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Opciones de Texto',
              children: [
                _buildAccessibilityOption(
                  icon: Icons.text_fields,
                  title: 'Ajustes de Tamaño de Texto',
                  description: 'Modifica el tamaño del texto para mejorar la legibilidad.',
                  isEnabled: textSizeEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      textSizeEnabled = value;
                    });
                  },
                ),
              ],
            ),
            _buildSection(
              title: 'Opciones de Color',
              children: [
                _buildAccessibilityOption(
                  icon: Icons.color_lens,
                  title: 'Modo de Daltónico',
                  description: 'Activar el modo de daltónico para adaptar los colores de la aplicación.',
                  isEnabled: colorBlindModeEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      colorBlindModeEnabled = value;
                    });
                  },
                ),
                _buildAccessibilityOption(
                  icon: Icons.contrast,
                  title: 'Modo de Alto Contraste',
                  description: 'Mejora el contraste de la aplicación para una mejor visibilidad.',
                  isEnabled: highContrastModeEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      highContrastModeEnabled = value;
                    });
                  },
                ),
              ],
            ),
            _buildSection(
              title: 'Opciones de Navegación',
              children: [
                _buildAccessibilityOption(
                  icon: Icons.screen_lock_portrait,
                  title: 'Lectura de Pantalla',
                  description: 'Activar el lector de pantalla para asistencia auditiva.',
                  isEnabled: screenReaderEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      screenReaderEnabled = value;
                    });
                  },
                ),
                _buildAccessibilityOption(
                  icon: Icons.gesture,
                  title: 'Navegación por Gestos',
                  description: 'Habilitar la navegación mediante gestos para una experiencia más fluida.',
                  isEnabled: gestureNavigationEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      gestureNavigationEnabled = value;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      color: isDarkMode ? Colors.black : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: widget.sectionTitleColor,
              fontSize: widget.sectionTitleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibilityOption({
    required IconData icon,
    required String title,
    required String description,
    required bool isEnabled,
    required ValueChanged<bool> onChanged,
  }) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.black : Colors.grey.shade100, // Fondo de cada opción
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start, // Alineación superior
              children: [
                Icon(
                  icon,
                  color: widget.titleColor,
                  size: 24.0,
                ),
                SizedBox(width: 8.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: widget.titleColor,
                          fontSize: widget.titleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.0),
                      Text(
                        description,
                        style: TextStyle(
                          color: Colors.grey, // Color gris para la descripción
                          fontSize: 10.0, // Tamaño de letra más pequeño
                        ),
                        maxLines: null, // Permite que la descripción ocupe varias líneas
                      ),
                    ],
                  ),
                ),
                Transform.scale(
                  scale: 0.9,
                  child: Switch(
                    value: isEnabled,
                    onChanged: onChanged,
                    activeColor: Colors.cyan,
                    inactiveTrackColor: Colors.grey,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    inactiveThumbColor: Colors.grey.shade300,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
