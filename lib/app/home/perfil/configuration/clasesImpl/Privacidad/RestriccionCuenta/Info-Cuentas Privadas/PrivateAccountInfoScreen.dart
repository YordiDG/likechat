import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../../../Globales/estadoDark-White/DarkModeProvider.dart';
import '../../../../../../../Globales/estadoDark-White/Fuentes/FontSizeProvider.dart';

class PrivateAccountInfoScreen extends StatelessWidget {
  const PrivateAccountInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;

    final backgroundColor = isDarkMode ? Colors.black : Colors.grey[50];
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final descipcionColor = Colors.grey;
    final cardColor = isDarkMode ? Colors.grey[900] : Colors.white;
    final primaryPurple = Color(0xFF9B30FF);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Cuenta Privada',
          style: TextStyle(
            color: textColor,
            fontSize: fontSizeProvider.fontSize + 2,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Banner mejorado
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDarkMode
                      ? [primaryPurple.withOpacity(0.2), Colors.black]
                      : [primaryPurple.withOpacity(0.1), Colors.white],
                ),
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 75,
                        height: 75,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: primaryPurple.withOpacity(0.1),
                        ),
                      ),
                      Icon(
                        Icons.lock,
                        size: 40,
                        color: primaryPurple,
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Mantén tu contenido seguro',
                    style: TextStyle(
                      fontSize: fontSizeProvider.fontSize + 1,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Una cuenta privada te da control total sobre quién puede ver tu contenido e interactuar contigo',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSizeProvider.fontSize - 2,
                      color: textColor.withOpacity(0.8),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // Stats Section
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem(
                    context: context,
                    icon: Icons.verified_user,
                    label: 'Privacidad\nMejorada',
                    textColor: textColor,
                    primaryPurple: primaryPurple,
                    fontSize: fontSizeProvider.fontSize,
                  ),
                  _buildStatItem(
                    context: context,
                    icon: Icons.shield,
                    label: 'Control\nTotal',
                    textColor: textColor,
                    primaryPurple: primaryPurple,
                    fontSize: fontSizeProvider.fontSize,
                  ),
                  _buildStatItem(
                    context: context,
                    icon: Icons.security,
                    label: 'Máxima\nSeguridad',
                    textColor: textColor,
                    primaryPurple: primaryPurple,
                    fontSize: fontSizeProvider.fontSize,
                  ),
                ],
              ),
            ),

            // Características principales mejoradas
            Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Beneficios exclusivos',
                    style: TextStyle(
                      fontSize: fontSizeProvider.fontSize ,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 20),
                  _buildFeatureCard(
                    icon: Icons.remove_red_eye,
                    title: 'Contenido protegido',
                    description: 'Tus fotos, videos e historias solo serán visibles para seguidores aprobados.',
                    color: cardColor,
                    textColor: textColor,
                    primaryPurple: primaryPurple,
                    fontSize: fontSizeProvider.fontSize,
                    isDarkMode: isDarkMode,
                  ),
                  _buildFeatureCard(
                    icon: Icons.group,
                    title: 'Comunidad selecta',
                    description: 'Aprueba manualmente cada solicitud de seguimiento para crear tu comunidad ideal.',
                    color: cardColor,
                    textColor: textColor,
                    primaryPurple: primaryPurple,
                    fontSize: fontSizeProvider.fontSize,
                    isDarkMode: isDarkMode,
                  ),
                  _buildFeatureCard(
                    icon: Icons.notifications_active,
                    title: 'Notificaciones personalizadas',
                    description: 'Recibe alertas sobre nuevas solicitudes de seguimiento y mensajes.',
                    color: cardColor,
                    textColor: textColor,
                    primaryPurple: primaryPurple,
                    fontSize: fontSizeProvider.fontSize,
                    isDarkMode: isDarkMode,
                  ),
                  _buildFeatureCard(
                    icon: FontAwesomeIcons.commentDots,
                    title: 'Mensajes controlados',
                    description: 'Decide quién puede enviarte mensajes directos y solicitudes.',
                    color: cardColor,
                    textColor: textColor,
                    primaryPurple: primaryPurple,
                    fontSize: fontSizeProvider.fontSize,
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),

            // Consejos de seguridad mejorados
            Container(
              margin: EdgeInsets.symmetric(horizontal: 24,),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? primaryPurple.withOpacity(0.15)
                    : primaryPurple.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: primaryPurple.withOpacity(0.2),
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.tips_and_updates,
                        color: primaryPurple,
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Consejos de seguridad',
                        style: TextStyle(
                          fontSize: fontSizeProvider.fontSize + 1,
                          fontWeight: FontWeight.bold,
                          color: primaryPurple,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildSecurityTip(
                    'Revisa regularmente tus seguidores y elimina cuentas sospechosas',
                    textColor: textColor,
                    primaryPurple: primaryPurple,
                    fontSize: fontSizeProvider.fontSize,
                  ),
                  _buildSecurityTip(
                    'Configura la autenticación en dos pasos para mayor seguridad',
                    textColor: textColor,
                    primaryPurple: primaryPurple,
                    fontSize: fontSizeProvider.fontSize,
                  ),
                  _buildSecurityTip(
                    'Actualiza regularmente tu configuración de privacidad',
                    textColor: textColor,
                    primaryPurple: primaryPurple,
                    fontSize: fontSizeProvider.fontSize,
                  ),
                  _buildSecurityTip(
                    'No compartas tu ubicación en tiempo real',
                    textColor: textColor,
                    primaryPurple: primaryPurple,
                    fontSize: fontSizeProvider.fontSize,
                  ),
                ],
              ),
            ),

            // CTA Section
            Container(
              margin: EdgeInsets.symmetric(horizontal: 24, vertical:12),
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: primaryPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    '¿Listo para proteger tu contenido?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: fontSizeProvider.fontSize,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // Implementar acción para cambiar a cuenta privada
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryPurple,
                      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cambiar a cuenta privada',
                      style: TextStyle(
                        fontSize: fontSizeProvider.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color textColor,
    required Color primaryPurple,
    required double fontSize,
  }) {
    // Accediendo a los providers con el contexto proporcionado
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    // Verificando si se necesita el valor de 'isDarkMode' explícitamente
    final isDarkMode = darkModeProvider.isDarkMode;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.white.withOpacity(0.1) : primaryPurple.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: primaryPurple,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: fontSize - 2, // Fuente ajustada
            color: textColor.withOpacity(0.8),
            fontWeight: FontWeight.w500,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
    required Color? color,
    required Color textColor,
    required Color primaryPurple,
    required double fontSize,
    required bool isDarkMode,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDarkMode
            ? primaryPurple.withOpacity(0.15)
            : primaryPurple.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDarkMode ? Colors.black12 : Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: primaryPurple,
              size: 26,
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: fontSize ,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: fontSize - 2,
                    color: Colors.grey,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTip(
      String tip, {
        required Color textColor,
        required Color primaryPurple,
        required double fontSize,
      }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle,
            size: 18,
            color: primaryPurple,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                fontSize: fontSize - 1,
                color: textColor.withOpacity(0.8),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}