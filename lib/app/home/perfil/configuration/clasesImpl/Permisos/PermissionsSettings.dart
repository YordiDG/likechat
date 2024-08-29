import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../Globales/estadoDark-White/DarkModeProvider.dart';

class PermissionsSettings extends StatefulWidget {
  final Color tileColor;
  final Color textColor;
  final Color sectionTitleColor;
  final Color titleColor;
  final Color descriptionColor;
  final double titleFontSize;
  final double sectionTitleFontSize;
  final double descriptionFontSize;

  PermissionsSettings({
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
  _PermissionsSettingsState createState() => _PermissionsSettingsState();
}

class _PermissionsSettingsState extends State<PermissionsSettings> {
  bool notificationsEnabled = true;
  bool messagesEnabled = true;
  bool cameraAccessEnabled = true;
  bool galleryAccessEnabled = true;
  bool storiesViewEnabled = true;
  bool storiesCreateEnabled = true;
  bool preciseLocationEnabled = true;
  bool approximateLocationEnabled = true;

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Configuración de Permisos',
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
              title: 'Interacciones',
              children: [
                _buildPermissionOption(
                  icon: Icons.notifications,
                  title: 'Permisos de Notificaciones',
                  description: 'Permite recibir notificaciones sobre nuevas interacciones, mensajes y actualizaciones.',
                  isEnabled: notificationsEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      notificationsEnabled = value;
                    });
                  },
                ),
                _buildPermissionOption(
                  icon: Icons.message,
                  title: 'Permisos de Mensajes',
                  description: 'Configura quién puede enviarte mensajes y cómo se te notifica.',
                  isEnabled: messagesEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      messagesEnabled = value;
                    });
                  },
                ),
              ],
            ),
            _buildSection(
              title: 'Contenido',
              children: [
                _buildPermissionOption(
                  icon: Icons.camera,
                  title: 'Permisos de Acceso a la Cámara',
                  description: 'Permite a la aplicación acceder a tu cámara para grabar y subir videos.',
                  isEnabled: cameraAccessEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      cameraAccessEnabled = value;
                    });
                  },
                ),
                _buildPermissionOption(
                  icon: Icons.photo_library,
                  title: 'Permisos de Acceso a la Galería',
                  description: 'Permite a la aplicación acceder a tu galería para seleccionar videos y fotos.',
                  isEnabled: galleryAccessEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      galleryAccessEnabled = value;
                    });
                  },
                ),
              ],
            ),
            _buildSection(
              title: 'Historias',
              children: [
                _buildPermissionOption(
                  icon: Icons.visibility,
                  title: 'Permisos para Ver Historias',
                  description: 'Configura quién puede ver tus historias y cómo se notifica a otros sobre tus publicaciones.',
                  isEnabled: storiesViewEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      storiesViewEnabled = value;
                    });
                  },
                ),
                _buildPermissionOption(
                  icon: Icons.create,
                  title: 'Permisos para Crear Historias',
                  description: 'Configura quién puede crear historias y gestionar tus publicaciones de forma más segura.',
                  isEnabled: storiesCreateEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      storiesCreateEnabled = value;
                    });
                  },
                ),
              ],
            ),
            _buildSection(
              title: 'Ubicación',
              children: [
                _buildPermissionOption(
                  icon: Icons.location_on,
                  title: 'Permisos de Ubicación Precisa',
                  description: 'Permite que la aplicación acceda a tu ubicación precisa para mejorar las recomendaciones.',
                  isEnabled: preciseLocationEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      preciseLocationEnabled = value;
                    });
                  },
                ),
                _buildPermissionOption(
                  icon: Icons.location_searching,
                  title: 'Permisos de Ubicación Aproximada',
                  description: 'Permite que la aplicación acceda a tu ubicación aproximada para personalizar contenido.',
                  isEnabled: approximateLocationEnabled,
                  onChanged: (bool value) {
                    setState(() {
                      approximateLocationEnabled = value;
                    });
                  },
                ),
              ],
            ),
            _buildSection(
              title: 'Permisos Generales',
              children: [
                _buildPermissionOption(
                  icon: Icons.mic,
                  title: 'Permisos de Acceso a Micrófono',
                  description: 'Permite a la aplicación acceder a tu micrófono para grabar audio.',
                  isEnabled: true,
                  onChanged: (bool value) {},
                ),
                _buildPermissionOption(
                  icon: Icons.contacts,
                  title: 'Permisos de Acceso a Contactos',
                  description: 'Permite a la aplicación acceder a tus contactos para facilitar la conexión con amigos.',
                  isEnabled: true,
                  onChanged: (bool value) {},
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

  Widget _buildPermissionOption({
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
                          color: widget.descriptionColor,
                          fontSize: widget.descriptionFontSize, // Ajuste del tamaño de la descripción
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
