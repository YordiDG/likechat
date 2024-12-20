import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../Globales/estadoDark-White/DarkModeProvider.dart';
import '../../../Globales/estadoDark-White/Fuentes/FontSizeProvider.dart';
import 'clasesImpl/Bloqueados/BlockScreen.dart';
import 'clasesImpl/Cuenta.dart';
import 'clasesImpl/Monetization/MonetizationScreen.dart';
import 'clasesImpl/Permisos/PermissionsSettings.dart';
import 'clasesImpl/Privacidad/PrivacySettings.dart';
import 'clasesImpl/VideoList/ListVideos.dart';
import 'clasesImpl/accesibilidad/AccessibilitySettings.dart';
import 'clasesImpl/estadoDeCuenta/EstadoDeCuentaScreen.dart';
import 'clasesImpl/idioma/LanguageSelectionWidget.dart';
import 'clasesImpl/security/SecuritySettings.dart';

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
    final backgroundColor = isDarkMode ? Colors.black : Colors.grey.shade200;
    final appBarColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final tileColor = isDarkMode ? Colors.black12 : Colors.grey[100]!;
    final sectionHeaderColor = isDarkMode ? Colors.black : Colors.grey.shade200;

    final fontSize =
        fontSizeProvider.fontSize; // Obtén el tamaño de fuente del proveedor

    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: textColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          children: [
            SizedBox(
              width: 30,
            ),
            Text(
              'Configuración',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
                fontSize: 19,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Container(
          color: backgroundColor,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              SectionHeader(
                  title: 'Ajustes y Privacidad',
                  backgroundColor: sectionHeaderColor,
                  textColor: Colors.grey,
                  fontSize: 12),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    children: [
                      MenuTile(
                        icon: Icons.account_circle,
                        title: 'Cuenta',
                        tileColor: Colors.transparent,
                        textColor: textColor,
                        fontSize: fontSize,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Cuenta(
                                    tileColor: tileColor,
                                    textColor: textColor,
                                    fontSize: fontSize)),
                          );
                        },
                      ),
                      MenuTile(
                        icon: Icons.lock,
                        title: 'Privacidad',
                        tileColor: Colors.transparent,
                        textColor: textColor,
                        fontSize: fontSize,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Scaffold(
                                appBar: AppBar(
                                  title: Text('Privacidad',
                                      style: TextStyle(color: textColor)),
                                  backgroundColor: tileColor,
                                ),
                                body: PrivacySettings(
                                  switchActiveColor: Colors.cyan,
                                  titleColor: textColor,
                                  sectionTitleColor: Colors.grey.shade600,
                                  descriptionColor: Colors.grey,
                                  sectionBackgroundColor: isDarkMode
                                      ? Colors.black
                                      : Colors.grey.shade100,
                                  titleFontSize: 14.0,
                                  sectionTitleFontSize: 16.0,
                                  descriptionFontSize: 11.0,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      MenuTile(
                        icon: Icons.security,
                        title: 'Seguridad',
                        tileColor: Colors.transparent,
                        textColor: textColor,
                        fontSize: fontSize,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Scaffold(
                                appBar: AppBar(
                                  title: Text('Seguridad',
                                      style: TextStyle(color: textColor)),
                                  backgroundColor: tileColor,
                                ),
                                body: SecuritySettings(
                                  titleColor: textColor,
                                  sectionTitleColor: isDarkMode
                                      ? Colors.white
                                      : Colors.grey.shade700,
                                  descriptionColor: Colors.grey,
                                  titleFontSize: 14.0,
                                  sectionTitleFontSize: 16.0,
                                  descriptionFontSize: 11.0,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      MenuTile(
                        icon: Icons.lock_open,
                        title: 'Permisos',
                        tileColor: Colors.transparent,
                        textColor: textColor,
                        fontSize: fontSize,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PermissionsSettings(
                                tileColor: textColor,
                                textColor: textColor,
                                sectionTitleColor:
                                    isDarkMode ? Colors.white : Colors.black,
                                titleColor:
                                    isDarkMode ? Colors.white : Colors.black,
                                descriptionColor: Colors.grey,
                                titleFontSize: fontSize,
                                sectionTitleFontSize: fontSize + 1,
                                descriptionFontSize: fontSize - 4,
                              ),
                            ),
                          );
                        },
                      ),
                      MenuTile(
                        icon: Icons.monetization_on,
                        title: 'Saldo',
                        tileColor: Colors.transparent,
                        textColor: textColor,
                        fontSize: fontSize,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MonetizationScreen(),
                            ),
                          );
                        },
                      ),
                      MenuTile(
                        icon: Icons.reply,
                        title: 'Compartir perfil',
                        tileColor: Colors.transparent,
                        textColor: textColor,
                        fontSize: fontSize,
                        onTap: () {
                          _showShareDialog(context);
                        },
                      ),
                      MenuTile(
                        icon: Icons.live_tv,
                        title: 'LIVE',
                        tileColor: Colors.transparent,
                        textColor: textColor,
                        fontSize: fontSize,
                        onTap: () {},
                      ),
                      MenuTile(
                        icon: Icons.block,
                        title: 'Bloqueos',
                        tileColor: Colors.transparent,
                        textColor: textColor,
                        fontSize: fontSize,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BlockScreen(
                                tileColor: Colors.grey.shade200,
                                textColor: Colors.black,
                                fontSize: 16.0,
                              ),
                            ),
                          );
                        },
                      ),
                      MenuTile(
                        icon: Icons.account_balance_wallet,
                        title: 'Estado de cuenta',
                        tileColor: Colors.transparent,
                        textColor: textColor,
                        fontSize: fontSize,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EstadoDeCuentaScreen(),
                            ),
                          );
                        },
                      ),
                      MenuTile(
                        icon: Icons.video_camera_back_rounded,
                        title: 'Snippets',
                        tileColor: Colors.transparent,
                        textColor: textColor,
                        fontSize: fontSize,
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => VideoListScreen()));
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SectionHeader(
                  title: 'Contenido y Pantalla',
                  backgroundColor: sectionHeaderColor,
                  textColor: Colors.grey,
                  fontSize: 12),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Container(

                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(children: [
                        MenuTile(
                          icon: Icons.language,
                          title: 'Idioma',
                          tileColor: tileColor,
                          textColor: textColor,
                          fontSize: fontSize,
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        LanguageSelectionWidget()));
                          },
                        ),
                        MenuTile(
                          icon: Icons.text_increase_outlined,
                          title: 'Tamaño de Fuente',
                          tileColor: tileColor,
                          textColor: textColor,
                          fontSize: fontSize,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FontSizeScreen()),
                            );
                          },
                        ),
                        MenuTile(
                          icon: Icons.accessibility,
                          title: 'Accesibilidad',
                          tileColor: tileColor,
                          textColor: textColor,
                          fontSize: fontSize,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AccessibilitySettings(
                                  tileColor: tileColor,
                                  textColor: textColor,
                                  sectionTitleColor: textColor,
                                  titleColor: textColor,
                                  descriptionColor: textColor,
                                  titleFontSize: fontSize,
                                  sectionTitleFontSize: fontSize,
                                  descriptionFontSize: fontSize,
                                ),
                              ),
                            );
                          },
                        ),
                        MenuTile(
                            icon: Icons.notifications,
                            title: 'Notificaciones',
                            tileColor: tileColor,
                            textColor: textColor,
                            fontSize: fontSize),
                        MenuTile(
                            icon: Icons.settings,
                            title: 'Preferencias de Actividades',
                            tileColor: tileColor,
                            textColor: textColor,
                            fontSize: fontSize),
                        MenuTile(
                            icon: Icons.center_focus_strong,
                            title: 'Centro de Actividades',
                            tileColor: tileColor,
                            textColor: textColor,
                            fontSize: fontSize),
                      ]))),
              SectionHeader(
                  title: 'Publicidad',
                  backgroundColor: sectionHeaderColor,
                  textColor: Colors.grey,
                  fontSize: 12),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(children: [
                        MenuTile(
                            icon: Icons.payment,
                            title: 'Pagos',
                            tileColor: tileColor,
                            textColor: textColor,
                            fontSize: fontSize),
                        MenuTile(
                            icon: Icons.ad_units,
                            title: 'Anuncios',
                            tileColor: tileColor,
                            textColor: textColor,
                            fontSize: fontSize),
                        MenuTile(
                            icon: Icons.assessment,
                            title: 'Estadísticas',
                            tileColor: tileColor,
                            textColor: textColor,
                            fontSize: fontSize),
                      ]))),
              SectionHeader(
                  title: 'Almacenamiento',
                  backgroundColor: sectionHeaderColor,
                  textColor: Colors.grey,
                  fontSize: 12),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(children: [
                        MenuTile(
                            icon: Icons.storage,
                            title: 'Liberar espacio',
                            tileColor: tileColor,
                            textColor: textColor,
                            fontSize: fontSize),
                        MenuTile(
                            icon: Icons.data_usage,
                            title: 'Ahorro de datos',
                            tileColor: tileColor,
                            textColor: textColor,
                            fontSize: fontSize),
                        MenuTile(
                            icon: Icons.image,
                            title: 'Calidad de imagen y video',
                            tileColor: tileColor,
                            textColor: textColor,
                            fontSize: fontSize),
                      ]))),
              SectionHeader(
                  title: 'Ayuda e Información',
                  backgroundColor: sectionHeaderColor,
                  textColor: Colors.grey,
                  fontSize: 12),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(children: [
                        MenuTile(
                            icon: Icons.report_problem,
                            title: 'Informar de un problema',
                            tileColor: tileColor,
                            textColor: textColor,
                            fontSize: fontSize),
                        MenuTile(
                            icon: Icons.help,
                            title: 'Ayuda',
                            tileColor: tileColor,
                            textColor: textColor,
                            fontSize: fontSize),
                        MenuTile(
                            icon: Icons.description,
                            title: 'Términos y condiciones',
                            tileColor: tileColor,
                            textColor: textColor,
                            fontSize: fontSize),
                        MenuTile(
                            icon: Icons.info,
                            title: 'Sobre nosotros',
                            tileColor: tileColor,
                            textColor: textColor,
                            fontSize: fontSize),
                      ]))),
              SectionHeader(
                  title: 'Inicio de Sesión',
                  backgroundColor: sectionHeaderColor,
                  textColor: Colors.grey,
                  fontSize: 12),
              Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Column(children: [
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
                      ]))),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(width: 15.0),
                        Icon(
                          isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
                          color: isDarkMode ? Colors.white : Colors.black,
                          size: 20.0,
                        ),
                        SizedBox(width: 8.0),
                        Padding(
                          padding: const EdgeInsets.only(left: 2.0),
                          child: Text(
                            'Modo ${isDarkMode ? "claro" : "oscuro"}',
                            style: TextStyle(
                                color: textColor, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: isDarkMode,
                        onChanged: (value) {
                          darkModeProvider.setDarkMode(value);
                        },
                        activeColor: Colors.white,
                        activeTrackColor: Colors.cyan,
                        inactiveThumbColor: Colors.grey,
                        inactiveTrackColor: Colors.grey.withOpacity(0.5),
                      ),
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
                    fontWeight: FontWeight.w500,
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

  //metodo de compartir perfil
  void _showShareDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          backgroundColor: Colors.grey.shade900,
          title: Center(
            child: Text(
              'Compartir perfil',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          content: Text(
            '¿Deseas compartir tu perfil?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                final String shareText = 'Mira mi perfil en LikeChat!';
                final String shareLink =
                    'https://www.likechat.com/yordigonzales';

                // Usar el paquete share_plus para compartir
                Share.share('$shareText\n$shareLink');
                Navigator.of(context)
                    .pop(); // Cierra el diálogo después de compartir
              },
              child: Text(
                'Compartir',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                ),
                minimumSize: MaterialStateProperty.all<Size>(
                  Size(0, 40),
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(Colors.cyan),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                ),
                minimumSize: MaterialStateProperty.all<Size>(
                  Size(0, 40),
                ),
                side: MaterialStateProperty.all<BorderSide>(
                  BorderSide(color: Colors.grey.withOpacity(0.7), width: 1),
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.transparent),
              ),
            ),
          ],
        );
      },
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize; // Añadido para el tamaño de fuente

  SectionHeader(
      {required this.title,
      required this.backgroundColor,
      required this.textColor,
      required this.fontSize});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 30.0),
      child: Text(
        title,
        style: TextStyle(
            fontWeight: FontWeight.bold, fontSize: fontSize, color: textColor),
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
    this.fontSize = 11.0, // Tamaño de fuente predeterminado
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: tileColor,
      child: ListTile(
        title: Row(
          children: [
            SizedBox(width: 5),
            Icon(icon, size: 19, color: Colors.grey), // El ícono
            SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 11.0, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
