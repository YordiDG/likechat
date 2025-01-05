import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../Globales/estadoDark-White/DarkModeProvider.dart';
import '../../../../../Globales/estadoDark-White/Fuentes/FontSizeProvider.dart';

class SecuritySettings extends StatefulWidget {
  final Color sectionTitleColor;
  final Color titleColor;
  final Color descriptionColor;

  SecuritySettings({
    required this.sectionTitleColor,
    required this.titleColor,
    required this.descriptionColor,
  });

  @override
  _SecuritySettingsState createState() => _SecuritySettingsState();
}

class _SecuritySettingsState extends State<SecuritySettings> {
  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sección: Autenticación
            _buildCardSection(
              title: 'Autenticación',
              isDarkMode: isDarkMode,
              children: [
                _buildSecurityOption(
                  title: 'Autenticación en dos pasos',
                  description: 'Agrega una capa adicional de seguridad a tu cuenta mediante un código enviado a tu dispositivo.',
                  icon: Icons.security,
                  onTap: () {
                    _navigateToDetailScreen('Autenticación en dos pasos');
                  },
                ),
                _buildSecurityOption(
                  title: 'Iniciar sesión con biometría',
                  description: 'Permite iniciar sesión usando tu huella digital o reconocimiento facial.',
                  icon: Icons.fingerprint,
                  onTap: () {
                    _navigateToDetailScreen('Iniciar sesión con biometría');
                  },
                ),
              ],
            ),
            SizedBox(height: 16.0),

            // Sección: Notificaciones
            _buildCardSection(
              title: 'Notificaciones',
              isDarkMode: isDarkMode,
              children: [
                _buildSecurityOption(
                  title: 'Notificar sospechoso',
                  description: 'Recibe notificaciones cuando se detecte un inicio de sesión desde un dispositivo o ubicación no reconocida.',
                  icon: Icons.warning,
                  onTap: () {
                    _navigateToDetailScreen('Notificar inicio de sesión sospechoso');
                  },
                ),
                _buildSecurityOption(
                  title: 'Mostrar historial de inicios de sesión',
                  description: 'Permite ver el historial de tus inicios de sesión recientes.',
                  icon: Icons.history,
                  onTap: () {
                    _navigateToDetailScreen('Mostrar historial de inicios de sesión');
                  },
                ),
              ],
            ),
            SizedBox(height: 16.0),

            // Sección: Protección de Datos
            _buildCardSection(
              title: 'Protección de Datos',
              isDarkMode: isDarkMode,
              children: [
                _buildSecurityOption(
                  title: 'Cifrado de datos',
                  description: 'Asegura que tus datos estén cifrados durante la transmisión y almacenamiento.',
                  icon: Icons.lock_outline,
                  onTap: () {
                    _navigateToDetailScreen('Cifrado de datos');
                  },
                ),
                _buildSecurityOption(
                  title: 'Revisión de permisos',
                  description: 'Revisa y ajusta los permisos que has otorgado a la aplicación.',
                  icon: Icons.perm_device_information,
                  onTap: () {
                    _navigateToDetailScreen('Revisión de permisos');
                  },
                ),
              ],
            ),
            SizedBox(height: 16.0),

            // Sección: Recuperación de Cuenta
            _buildCardSection(
              title: 'Recuperación de Cuenta',
              isDarkMode: isDarkMode,
              children: [
                _buildSecurityOption(
                  title: 'Opciones de recuperación',
                  description: 'Configura tus opciones de recuperación de cuenta en caso de pérdida de acceso.',
                  icon: Icons.restore,
                  onTap: () {
                    _navigateToDetailScreen('Opciones de recuperación');
                  },
                ),
                _buildSecurityOption(
                  title: 'Cambiar preguntas de seguridad',
                  description: 'Actualiza las preguntas de seguridad asociadas a tu cuenta.',
                  icon: Icons.question_answer,
                  onTap: () {
                    _navigateToDetailScreen('Cambiar preguntas de seguridad');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardSection({
    required String title,
    required bool isDarkMode,
    required List<Widget> children,
  }) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return Card(
      elevation: 2,
      color: isDarkMode ? Colors.grey[900] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: TextStyle(
                color: widget.sectionTitleColor,
                fontSize: fontSizeProvider.fontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Divider(
            color: Colors.grey,
            height: 1,
            thickness: 0.1,
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSecurityOption({
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20.0,
              color: Colors.grey,
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: widget.titleColor,
                      fontSize: fontSizeProvider.fontSize - 1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  Text(
                    description,
                    style: TextStyle(
                      color: widget.descriptionColor,
                      fontSize: fontSizeProvider.fontSize - 2,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.0,
              color: widget.titleColor,
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToDetailScreen(String optionTitle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SecurityDetailScreen(title: optionTitle),
      ),
    );
  }
}

class SecurityDetailScreen extends StatelessWidget {
  final String title;

  SecurityDetailScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: TextStyle(fontSize: 14),),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.black,
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            // Puedes personalizar cada pantalla de detalle según la opción seleccionada
            Text(
              'Aquí puedes gestionar los detalles de $title.',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12.0,
              ),
            ),
            // Agregar controles adicionales si es necesario
          ],
        ),
      ),
    );
  }
}