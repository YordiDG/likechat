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
  Map<String, bool> permissions = {
    'notifications': true,
    'messages': true,
    'cameraAccess': true,
    'galleryAccess': true,
    'storiesView': true,
    'storiesCreate': true,
    'preciseLocation': true,
    'approximateLocation': true,
    'microphone': true,
    'contacts': true,
  };

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final screenWidth = MediaQuery.of(context).size.width;
    final isNarrowScreen = screenWidth < 360; // Adjust this value as needed
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final iconColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: iconColor,
            size: 20,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Configuración de Permisos',
          style: TextStyle(
              fontSize: isNarrowScreen ? 16 : 20,
              fontWeight: FontWeight.bold
          ),
        ),
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    title: 'Interacciones',
                    children: [
                      _buildPermissionOption(
                        permissionKey: 'notifications',
                        icon: Icons.notifications,
                        title: 'Permisos de Notificaciones',
                        description: 'Permite recibir notificaciones sobre nuevas interacciones, mensajes y actualizaciones.',
                        isNarrowScreen: isNarrowScreen,
                      ),
                      _buildPermissionOption(
                        permissionKey: 'messages',
                        icon: Icons.message,
                        title: 'Permisos de Mensajes',
                        description: 'Configura quién puede enviarte mensajes y cómo se te notifica.',
                        isNarrowScreen: isNarrowScreen,
                      ),
                    ],
                  ),
                  _buildSection(
                    title: 'Contenido',
                    children: [
                      _buildPermissionOption(
                        permissionKey: 'cameraAccess',
                        icon: Icons.camera,
                        title: 'Permisos de Acceso a la Cámara',
                        description: 'Permite a la aplicación acceder a tu cámara para grabar y subir videos.',
                        isNarrowScreen: isNarrowScreen,
                      ),
                      _buildPermissionOption(
                        permissionKey: 'galleryAccess',
                        icon: Icons.photo_library,
                        title: 'Permisos de Acceso a la Galería',
                        description: 'Permite a la aplicación acceder a tu galería para seleccionar videos y fotos.',
                        isNarrowScreen: isNarrowScreen,
                      ),
                    ],
                  ),
                  _buildSection(
                    title: 'Historias',
                    children: [
                      _buildPermissionOption(
                        permissionKey: 'storiesView',
                        icon: Icons.visibility,
                        title: 'Permisos para Ver Historias',
                        description: 'Configura quién puede ver tus historias y cómo se notifica a otros sobre tus publicaciones.',
                        isNarrowScreen: isNarrowScreen,
                      ),
                      _buildPermissionOption(
                        permissionKey: 'storiesCreate',
                        icon: Icons.create,
                        title: 'Permisos para Crear Historias',
                        description: 'Configura quién puede crear historias y gestionar tus publicaciones de forma más segura.',
                        isNarrowScreen: isNarrowScreen,
                      ),
                    ],
                  ),
                  _buildSection(
                    title: 'Ubicación',
                    children: [
                      _buildPermissionOption(
                        permissionKey: 'preciseLocation',
                        icon: Icons.location_on,
                        title: 'Permisos de Ubicación Precisa',
                        description: 'Permite que la aplicación acceda a tu ubicación precisa para mejorar las recomendaciones.',
                        isNarrowScreen: isNarrowScreen,
                      ),
                      _buildPermissionOption(
                        permissionKey: 'approximateLocation',
                        icon: Icons.location_searching,
                        title: 'Permisos de Ubicación Aproximada',
                        description: 'Permite que la aplicación acceda a tu ubicación aproximada para personalizar contenido.',
                        isNarrowScreen: isNarrowScreen,
                      ),
                    ],
                  ),
                  _buildSection(
                    title: 'Permisos Generales',
                    children: [
                      _buildPermissionOption(
                        permissionKey: 'microphone',
                        icon: Icons.mic,
                        title: 'Permisos de Acceso a Micrófono',
                        description: 'Permite a la aplicación acceder a tu micrófono para grabar audio.',
                        isNarrowScreen: isNarrowScreen,
                      ),
                      _buildPermissionOption(
                        permissionKey: 'contacts',
                        icon: Icons.contacts,
                        title: 'Permisos de Acceso a Contactos',
                        description: 'Permite a la aplicación acceder a tus contactos para facilitar la conexión con amigos.',
                        isNarrowScreen: isNarrowScreen,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;

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
    required String permissionKey,
    required IconData icon,
    required String title,
    required String description,
    bool isNarrowScreen = false,
  }) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icono
            Container(
              padding: EdgeInsets.only(right: 16),
              child: Icon(
                icon,
                color: widget.titleColor,
                size: isNarrowScreen ? 20 : 24,
              ),
            ),

            // Texto
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: widget.titleColor,
                      fontSize: isNarrowScreen ? 14 : widget.titleFontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: widget.descriptionColor,
                      fontSize: isNarrowScreen ? 12 : widget.descriptionFontSize,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                  ),
                ],
              ),
            ),

            // Switch al final
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Transform.scale(
                scale: isNarrowScreen ? 0.7 : 0.9,
                child: Switch(
                  value: permissions[permissionKey] ?? true,
                  onChanged: (value) {
                    setState(() {
                      permissions[permissionKey] = value;
                    });
                  },
                  activeColor: Colors.white,
                  activeTrackColor: Colors.cyan,
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey.withOpacity(0.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}