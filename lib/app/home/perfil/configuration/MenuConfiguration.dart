import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../Globales/estadoDark-White/DarkModeProvider.dart';
import '../../../Globales/estadoDark-White/Fuentes/FontSizeProvider.dart';
import '../../shortVideos/Posts/eventos/ShareButton.dart';
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
    final tileColor = isDarkMode ? Colors.grey.shade900 : Colors.white;
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
          title: Center(
            child: Text(
              'Configuración',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor,
                fontSize: 14,
              ),
            ),
          ),
          actions: [
            // Esto asegura que haya espacio simétrico en el lado derecho para equilibrar la flecha de la izquierda
            SizedBox(width: 48),
          ],
        ),
        body: SafeArea(
          child: Container(
            color: backgroundColor,
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                // Cuenta y Perfil
                SectionHeader(
                  title: 'Cuenta y Perfil',
                  backgroundColor: sectionHeaderColor,
                  textColor: Colors.grey,
                ),
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
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Cuenta(
                                fontSize: fontSize,
                              ),
                            ),
                          ),
                        ),
                        MenuTileShared(
                          icon: Icons.reply,
                          // Cambiado para que apunte hacia el otro lado
                          title: 'Compartir perfil',
                          tileColor: Colors.transparent,
                          textColor: textColor,
                          onTap: () => _showFriendsModal(context),
                        ),
                        MenuTile(
                          icon: Icons.video_camera_back_rounded,
                          title: 'Snippets',
                          tileColor: Colors.transparent,
                          textColor: textColor,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VideoListScreen()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Seguridad y Privacidad
                SectionHeader(
                  title: 'Seguridad y Privacidad',
                  backgroundColor: sectionHeaderColor,
                  textColor: Colors.grey,
                ),
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
                          icon: Icons.lock,
                          title: 'Privacidad',
                          tileColor: Colors.transparent,
                          textColor: textColor,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Scaffold(
                                    appBar: AppBar(
                                      backgroundColor: appBarColor,
                                      leading: IconButton(
                                        icon: Icon(Icons.arrow_back_ios_new,
                                            size: 20, color: textColor),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                      title: Center(
                                        child: Text(
                                          'Privacidad',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: textColor,
                                            fontSize: fontSize + 1,
                                          ),
                                        ),
                                      ),
                                      actions: [
                                        // Esto asegura que haya espacio simétrico en el lado derecho para equilibrar la flecha de la izquierda
                                        SizedBox(width: 48),
                                      ],
                                    ),
                                    body: PrivacySettings()),
                              ),
                            );
                          },
                        ),
                        MenuTile(
                          icon: Icons.security,
                          title: 'Seguridad',
                          tileColor: Colors.transparent,
                          textColor: textColor,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Scaffold(
                                  appBar: AppBar(
                                    backgroundColor: appBarColor,
                                    leading: IconButton(
                                      icon: Icon(Icons.arrow_back_ios_new,
                                          size: 20, color: textColor),
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                    title: Center(
                                      child: Text(
                                        'Seguridad',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: textColor,
                                          fontSize: fontSize + 2,
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      // Esto asegura que haya espacio simétrico en el lado derecho para equilibrar la flecha de la izquierda
                                      SizedBox(width: 48),
                                    ],
                                  ),
                                  body: SecuritySettings(
                                    titleColor: textColor,
                                    sectionTitleColor: isDarkMode
                                        ? Colors.white
                                        : Colors.grey.shade700,
                                    descriptionColor: Colors.grey,

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
                          icon: Icons.block,
                          title: 'Bloqueos',
                          tileColor: Colors.transparent,
                          textColor: textColor,
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
                      ],
                    ),
                  ),
                ),

                // Finanzas y Monetización
                SectionHeader(
                  title: 'Finanzas y Monetización',
                  backgroundColor: sectionHeaderColor,
                  textColor: Colors.grey,
                ),
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
                          icon: Icons.monetization_on,
                          title: 'Saldo',
                          tileColor: Colors.transparent,
                          textColor: textColor,
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
                          icon: Icons.account_balance_wallet,
                          title: 'Estado de cuenta',
                          tileColor: Colors.transparent,
                          textColor: textColor,
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
                          icon: Icons.payment,
                          title: 'Pagos',
                          tileColor: Colors.transparent,
                          textColor: textColor,
                        ),
                        MenuTile(
                          icon: Icons.ad_units,
                          title: 'Anuncios',
                          tileColor: Colors.transparent,
                          textColor: textColor,
                        ),
                        MenuTile(
                          icon: Icons.assessment,
                          title: 'Estadísticas',
                          tileColor: Colors.transparent,
                          textColor: textColor,
                        ),
                      ],
                    ),
                  ),
                ),

                // Contenido y Streaming
                SectionHeader(
                  title: 'Contenido y Streaming',
                  backgroundColor: sectionHeaderColor,
                  textColor: Colors.grey,
                ),
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
                          icon: Icons.live_tv,
                          title: 'LIVE',
                          tileColor: Colors.transparent,
                          textColor: textColor,
                        ),
                        MenuTile(
                          icon: Icons.settings,
                          title: 'Preferencias de Actividades',
                          tileColor: tileColor,
                          textColor: textColor,
                        ),
                        MenuTile(
                          icon: Icons.center_focus_strong,
                          title: 'Centro de Actividades',
                          tileColor: tileColor,
                          textColor: textColor,
                        ),
                      ],
                    ),
                  ),
                ),

                // Personalización
                SectionHeader(
                  title: 'Personalización',
                  backgroundColor: sectionHeaderColor,
                  textColor: Colors.grey,
                ),
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
                          icon: Icons.language,
                          title: 'Idioma',
                          tileColor: tileColor,
                          textColor: textColor,
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
                        ),
                      ],
                    ),
                  ),
                ),

                // Almacenamiento y Datos
                SectionHeader(
                  title: 'Almacenamiento y Datos',
                  backgroundColor: sectionHeaderColor,
                  textColor: Colors.grey,
                ),
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
                          icon: Icons.storage,
                          title: 'Liberar espacio',
                          tileColor: tileColor,
                          textColor: textColor,
                        ),
                        MenuTile(
                          icon: Icons.data_usage,
                          title: 'Ahorro de datos',
                          tileColor: tileColor,
                          textColor: textColor,
                        ),
                        MenuTile(
                          icon: Icons.image,
                          title: 'Calidad de imagen y video',
                          tileColor: tileColor,
                          textColor: textColor,
                        ),
                      ],
                    ),
                  ),
                ),

                // Soporte y Legal
                SectionHeader(
                  title: 'Soporte y Legal',
                  backgroundColor: sectionHeaderColor,
                  textColor: Colors.grey,
                ),
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
                          icon: Icons.report_problem,
                          title: 'Informar de un problema',
                          tileColor: tileColor,
                          textColor: textColor,
                        ),
                        MenuTile(
                          icon: Icons.help,
                          title: 'Ayuda',
                          tileColor: tileColor,
                          textColor: textColor,
                        ),
                        MenuTile(
                          icon: Icons.description,
                          title: 'Términos y condiciones',
                          tileColor: tileColor,
                          textColor: textColor,
                        ),
                        MenuTile(
                          icon: Icons.info,
                          title: 'Sobre nosotros',
                          tileColor: tileColor,
                          textColor: textColor,
                        ),
                      ],
                    ),
                  ),
                ),

                // Cuenta y Sesión
                SectionHeader(
                  title: 'Cuenta y Sesión',
                  backgroundColor: sectionHeaderColor,
                  textColor: Colors.grey,
                ),
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
                          icon: Icons.switch_account,
                          title: 'Cambiar cuenta',
                          tileColor: tileColor,
                          textColor: textColor,
                          onTap: () => Navigator.pushNamed(context, '/login'),
                        ),
                        MenuTile(
                          icon: Icons.exit_to_app,
                          title: 'Cerrar sesión',
                          tileColor: tileColor,
                          textColor: textColor,
                          onTap: () => Navigator.pushNamed(context, '/login'),
                        ),
                      ],
                    ),
                  ),
                ),

                // Tema
                SectionHeader(
                  title: 'Tema',
                  backgroundColor: sectionHeaderColor,
                  textColor: Colors.grey,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0), // Reducido el padding vertical
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              SizedBox(width: 10.0), // Reducido el espacio
                              Icon(
                                isDarkMode
                                    ? Icons.wb_sunny
                                    : Icons.nightlight_round,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                              SizedBox(width: 5.0),
                              Padding(
                                padding: const EdgeInsets.only(left: 2.0),
                                child: Text(
                                  'Modo ${isDarkMode ? "claro" : "oscuro"}',
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
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
                              activeTrackColor: Color(0xFF9B30FF),
                              inactiveThumbColor: Colors.grey,
                              inactiveTrackColor: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10,),
                // Versión
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'LikeChat V10.0 (2025100020)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSize -1,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Arial',
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[800],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  //metodo de compartir perfil
  void _showFriendsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.35,
        // Tamaño inicial del modal
        minChildSize: 0.35,
        // Tamaño mínimo al contraerlo
        maxChildSize: 0.35,
        // Tamaño máximo al expandirlo
        builder: (context, scrollController) {
          return ShareModalPerfil(scrollController: scrollController);
        },
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final Color textColor;

  SectionHeader({
    required this.title,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    // Obtener el FontSizeProvider
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 30.0),
      child: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: textColor,
          fontSize: fontSizeProvider.fontSize - 1,
        ),
      ),
    );
  }
}

class MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color tileColor;
  final Color textColor;
  final VoidCallback? onTap;

  MenuTile({
    required this.icon,
    required this.title,
    required this.tileColor,
    required this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return Container(
      color: tileColor,
      child: ListTile(
        title: Row(
          children: [
            SizedBox(width: 5),
            Icon(icon, color: Colors.grey), // El ícono
            SizedBox(width: 6),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow
                    .ellipsis, // Muestra los puntos suspensivos si es largo
              ),
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios,
            size: fontSizeProvider.fontSize, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}

//para shared
class MenuTileShared extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color tileColor;
  final Color textColor;
  final VoidCallback? onTap;

  MenuTileShared({
    required this.icon,
    required this.title,
    required this.tileColor,
    required this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return Container(
      color: tileColor,
      child: ListTile(
        title: Row(
          children: [
            SizedBox(width: 5),
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.rotationY(3.14), // Rotación horizontal
              child: Icon(icon, color: Colors.grey), // El ícono invertido
            ),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        trailing: Icon(Icons.arrow_forward_ios,
            size: fontSizeProvider.fontSize, color: Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
