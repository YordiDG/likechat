import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../../../../../Globales/estadoDark-White/DarkModeProvider.dart';
import '../../../../../../Globales/estadoDark-White/Fuentes/FontSizeProvider.dart';

class PermissionsSection extends StatefulWidget {
  @override
  _PermissionsSectionState createState() => _PermissionsSectionState();
}

class _PermissionsSectionState extends State<PermissionsSection> {
  Map<Permission, bool> _permissionStates = {
    Permission.camera: false,
    Permission.microphone: false,
    Permission.storage: false,
    Permission.location: false,
    Permission.contacts: false,
    Permission.notification: false,
    Permission.manageExternalStorage: false,
  };

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    Map<Permission, bool> updatedStates = {};
    for (var permission in _permissionStates.keys) {
      final status = await permission.status;
      updatedStates[permission] = status.isGranted;
    }
    setState(() {
      _permissionStates = updatedStates;
    });
  }

  Future<void> _requestPermission(Permission permission) async {
    final status = await permission.request();
    setState(() {
      _permissionStates[permission] = status.isGranted;
    });
  }

  Widget _buildPermissionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Permission permission,
  }) {

    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final fontSize = fontSizeProvider.fontSize;

    return ListTile(
      leading: Icon(icon, color: Colors.grey, size: 20),
      title: Text(
        title,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),

      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: fontSize - 2, fontWeight: FontWeight.w400, color: Colors.grey),
      ),
      trailing: Transform.scale(
        scale: 0.8,
        child: Switch(
          value: _permissionStates[permission] ?? false,
          onChanged: (value) async {
            await _requestPermission(permission);
          },
          activeColor: Colors.white,
          activeTrackColor: Color(0xFF9B30FF),
          inactiveThumbColor: Colors.grey,
          inactiveTrackColor: Colors.grey.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildPermissionGroup(String title, List<Widget> children, Color cardColor) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final fontSize = fontSizeProvider.fontSize;

    return Card(
      color: cardColor,
      elevation: 1,
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 12.0, right: 8.0, top: 8.0), // Ajusta para reducir espacio
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: fontSize - 2,
                    color: Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Divider(
                  color: isDarkMode ? Colors.grey[850] : Colors.grey[200],
                  thickness: 0.5,
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final fontSize = fontSizeProvider.fontSize;

    final appBarColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final backgroundColor = isDarkMode ? Colors.black : Colors.grey[200];
    final cardColor = isDarkMode ? Colors.grey[900] : Colors.white;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: textColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Center(
          child: Text(
            'Permisos de la Aplicación',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: textColor,
              fontSize: fontSize + 1,
            ),
          ),
        ),
        actions: [SizedBox(width: 48)],
      ),
      backgroundColor: backgroundColor,
      body: ListView(
        children: [
          _buildPermissionGroup(
            'Multimedia',
            [
              _buildPermissionTile(
                icon: Icons.camera_alt,
                title: 'Cámara',
                subtitle: 'Permite tomar fotos y grabar videos',
                permission: Permission.camera,
              ),
              _buildPermissionTile(
                icon: Icons.mic_outlined,
                title: 'Micrófono',
                subtitle: 'Permite grabar audio',
                permission: Permission.microphone,
              ),
              _buildPermissionTile(
                icon: Icons.photo_library,
                title: 'Galería',
                subtitle: 'Permite acceder a fotos y videos',
                permission: Permission.storage,
              ),
            ],
            cardColor!,
          ),
          _buildPermissionGroup(
            'Privacidad',
            [
              _buildPermissionTile(
                icon: Icons.location_on,
                title: 'Ubicación',
                subtitle: 'Permite acceder a tu ubicación',
                permission: Permission.location,
              ),
              _buildPermissionTile(
                icon: Icons.contacts ,
                title: 'Contactos',
                subtitle: 'Permite acceder a tus contactos',
                permission: Permission.contacts,
              ),
            ],
            cardColor!,
          ),
          _buildPermissionGroup(
            'Sistema',
            [
              _buildPermissionTile(
                icon: Icons.notifications ,
                title: 'Notificaciones',
                subtitle: 'Permite recibir notificaciones',
                permission: Permission.notification,
              ),
              _buildPermissionTile(
                icon: Icons.folder ,
                title: 'Archivos',
                subtitle: 'Permite gestionar archivos externos',
                permission: Permission.manageExternalStorage,
              ),
            ],
            cardColor!,
          ),
        ],
      ),
    );
  }
}
