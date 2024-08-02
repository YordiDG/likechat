import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../estadoDark-White/DarkModeProvider.dart';
import '../../../estadoDark-White/Fuentes/FontSizeProvider.dart';

class MenuConfiguration extends StatefulWidget {
  @override
  _MenuConfigurationState createState() => _MenuConfigurationState();
}

class _MenuConfigurationState extends State<MenuConfiguration> {
  @override
  Widget build(BuildContext context) {
    // Accede al proveedor de modo oscuro
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;

    // Colores según el modo
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final appBarColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final tileColor = isDarkMode ? Colors.black12 : Colors.grey[100]!;
    final sectionHeaderColor = isDarkMode ? Colors.black54 : Colors.grey[200]!;

    final fontSize = fontSizeProvider.fontSize; // Obtén el tamaño de fuente del proveedor

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        title: Text(
          'Configuración',
          style: TextStyle(fontWeight: FontWeight.bold, color: textColor, fontSize: 21),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Container(
          color: backgroundColor,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              SectionHeader(title: 'Ajustes y Privacidad', backgroundColor: sectionHeaderColor, textColor: textColor, fontSize: fontSize),
              MenuTile(icon: Icons.account_circle, title: 'Cuenta', tileColor: tileColor, textColor: textColor, fontSize: fontSize),
              MenuTile(icon: Icons.lock, title: 'Privacidad', tileColor: tileColor, textColor: textColor, fontSize: fontSize),
              MenuTile(icon: Icons.security, title: 'Seguridad', tileColor: tileColor, textColor: textColor, fontSize: fontSize),
              MenuTile(icon: Icons.lock_open, title: 'Permisos', tileColor: tileColor, textColor: textColor, fontSize: fontSize),
              MenuTile(icon: Icons.monetization_on, title: 'Saldo', tileColor: tileColor, textColor: textColor, fontSize: fontSize),
              MenuTile(icon: Icons.share, title: 'Compartir perfil', tileColor: tileColor, textColor: textColor, fontSize: fontSize),
              MenuTile(icon: Icons.block, title: 'Bloqueos', tileColor: tileColor, textColor: textColor, fontSize: fontSize),
              MenuTile(icon: Icons.account_balance_wallet, title: 'Estado de cuenta', tileColor: tileColor, textColor: textColor, fontSize: fontSize),
              MenuTile(icon: Icons.video_camera_back_rounded, title: 'Snippets', tileColor: tileColor, textColor: textColor, fontSize: fontSize),

              SectionHeader(title: 'Contenido y Pantalla', backgroundColor: sectionHeaderColor, textColor: textColor, fontSize: fontSize),
              MenuTile(icon: Icons.language, title: 'Idioma', tileColor: tileColor, textColor: textColor, fontSize: fontSize),
              MenuTile(
                icon: Icons.text_fields,
                title: 'Tamaño de Fuente',
                tileColor: tileColor,
                textColor: textColor,
                fontSize: fontSize,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => FontSizeScreen()),
                  );
                },
              ),
              MenuTile(icon: Icons.accessibility, title: 'Accesibilidad', tileColor: tileColor, textColor: textColor, fontSize: fontSize),
              MenuTile(icon: Icons.notifications, title: 'Notificaciones', tileColor: tileColor, textColor: textColor, fontSize: fontSize),
              MenuTile(icon: Icons.settings, title: 'Preferencias de Actividades', tileColor: tileColor, textColor: textColor, fontSize: fontSize),
              MenuTile(icon: Icons.center_focus_strong, title: 'Centro de Actividades', tileColor: tileColor, textColor: textColor, fontSize: fontSize),

              SectionHeader(title: 'Publicidad', backgroundColor: sectionHeaderColor, textColor: textColor, fontSize: fontSize),
              MenuTile(icon: Icons.payment, title: 'Pagos', tileColor: tileColor, textColor: textColor, fontSize: fontSize),
              MenuTile(icon: Icons.ad_units, title: 'Anuncios', tileColor: tileColor, textColor: textColor, fontSize: fontSize),
              MenuTile(icon: Icons.assessment, title: 'Estadísticas', tileColor: tileColor, textColor: textColor, fontSize: fontSize),

              SectionHeader(title: 'Almacenamiento', backgroundColor: sectionHeaderColor, textColor: textColor, fontSize: fontSize),
              MenuTile(icon: Icons.storage, title: 'Liberar espacio', tileColor: tileColor, textColor: textColor, fontSize: fontSize),
              MenuTile(icon: Icons.data_usage, title: 'Ahorro de datos', tileColor: tileColor, textColor: textColor, fontSize: fontSize),
              MenuTile(icon: Icons.image, title: 'Calidad de imagen y video', tileColor: tileColor, textColor: textColor, fontSize: fontSize),

              SectionHeader(title: 'Ayuda e Información', backgroundColor: sectionHeaderColor, textColor: textColor, fontSize: fontSize),
              MenuTile(icon: Icons.report_problem, title: 'Informar de un problema', tileColor: tileColor, textColor: textColor, fontSize: fontSize),
              MenuTile(icon: Icons.help, title: 'Ayuda', tileColor: tileColor, textColor: textColor, fontSize: fontSize),
              MenuTile(icon: Icons.description, title: 'Términos y condiciones', tileColor: tileColor, textColor: textColor, fontSize: fontSize),
              MenuTile(icon: Icons.info, title: 'Sobre nosotros', tileColor: tileColor, textColor: textColor, fontSize: fontSize),

              SectionHeader(title: 'Inicio de Sesión', backgroundColor: sectionHeaderColor, textColor: textColor, fontSize: fontSize),
              MenuTile(
                icon: Icons.switch_account,
                title: 'Cambiar cuenta',
                tileColor: tileColor,
                textColor: textColor,
                fontSize: fontSize,
                onTap: () {
                  Navigator.pushNamed(context, '/login');
                },
              ),
              MenuTile(
                icon: Icons.exit_to_app,
                title: 'Cerrar sesión',
                tileColor: tileColor,
                textColor: textColor,
                fontSize: fontSize,
                onTap: () {
                  Navigator.pushNamed(context, '/login');
                },
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Modo oscuro',
                      style: TextStyle(
                        color: textColor,
                        fontSize: fontSize, // Tamaño del texto ajustado
                      ),
                    ),
                    Switch(
                      value: isDarkMode,
                      onChanged: (value) {
                        darkModeProvider.setDarkMode(value);
                      },
                      activeColor: isDarkMode ? Colors.cyan : Colors.blue, // Cambiar el color activo del switch
                      inactiveTrackColor: Colors.grey[400], // Color del track cuando está desactivado
                      inactiveThumbColor: Colors.grey[600], // Color del thumb cuando está desactivado
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'LikeChat V10.0 (2025100020)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: 'Arial',
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize; // Añadido para el tamaño de fuente

  SectionHeader({required this.title, required this.backgroundColor, required this.textColor, required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: fontSize, color: textColor),
      ),
    );
  }
}

class MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color tileColor;
  final Color textColor;
  final double fontSize; // Añadido para el tamaño de fuente
  final VoidCallback? onTap;

  MenuTile({
    required this.icon,
    required this.title,
    required this.tileColor,
    required this.textColor,
    this.fontSize = 16.0, // Tamaño de fuente predeterminado
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: tileColor,
      child: ListTile(
        leading: Icon(icon, color: textColor.withOpacity(0.7)),
        title: Text(
          title,
          style: TextStyle(
            color: textColor,
            fontSize: fontSize,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16.0, color: textColor.withOpacity(0.7)),
        onTap: onTap,
      ),
    );
  }
}
