import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../../../Globales/estadoDark-White/DarkModeProvider.dart';
import '../../../../../../Globales/estadoDark-White/Fuentes/FontSizeProvider.dart';
import 'Info-Cuentas Privadas/PrivateAccountInfoScreen.dart';

class RestrictedAccountSettingsScreen extends StatefulWidget {
  final bool isRestricted;

  const RestrictedAccountSettingsScreen(
      {super.key, required this.isRestricted});

  @override
  State<RestrictedAccountSettingsScreen> createState() =>
      _RestrictedAccountSettingsScreenState();
}

class _RestrictedAccountSettingsScreenState
    extends State<RestrictedAccountSettingsScreen>
    with SingleTickerProviderStateMixin {
  late bool isRestricted;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    isRestricted = widget.isRestricted;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    if (isRestricted) _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;

    final appBarColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final backgroundColor = isDarkMode ? Colors.black : Colors.grey[100];
    final cardColor = isDarkMode ? Colors.grey[900] : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Configuración de Privacidad',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: textColor,
            fontSize: fontSizeProvider.fontSize + 1,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isRestricted)
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: Container(
                        width: double.infinity,
                        margin: EdgeInsets.all(16),
                        padding:
                            EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Color(0xFF9B30FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Color(0xFF9B30FF).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.security,
                              color: Color(0xFF9B30FF),
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Tu cuenta está protegida con configuración privada',
                                style: TextStyle(
                                  color: Color(0xFF9B30FF),
                                  fontSize: fontSizeProvider.fontSize - 1,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Cuenta Privada',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontSizeProvider.fontSize,
                                    color: textColor,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  isRestricted ? 'Activada' : 'Desactivada',
                                  style: TextStyle(
                                    fontSize: fontSizeProvider.fontSize - 2,
                                    color: isRestricted
                                        ? Color(0xFF9B30FF)
                                        : Colors.grey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value: isRestricted,
                                onChanged: (value) {
                                  setState(() => isRestricted = value);
                                  if (value) {
                                    _animationController.forward();
                                  } else {
                                    _animationController.reverse();
                                  }
                                },
                                activeColor: Colors.white,
                                activeTrackColor: Color(0xFF9B30FF),
                                inactiveThumbColor: Colors.grey,
                                inactiveTrackColor:
                                    Colors.grey.withOpacity(0.3),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Al activar la cuenta privada:',
                          style: TextStyle(
                            fontSize: fontSizeProvider.fontSize - 2,
                            color: textColor.withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 12),
                        _buildFeatureItem(
                          icon: Icons.people,
                          text: 'Solo usuarios autorizados podrán seguirte',
                          isDarkMode: isDarkMode,
                          textColor: textColor,
                          fontSize: fontSizeProvider.fontSize - 2,
                        ),
                        SizedBox(height: 8),
                        _buildFeatureItem(
                          icon: Icons.visibility,
                          text:
                              'Tus videos serán visibles solo para seguidores aprobados',
                          isDarkMode: isDarkMode,
                          textColor: textColor,
                          fontSize: fontSizeProvider.fontSize - 2,
                        ),
                        SizedBox(height: 8),
                        _buildFeatureItem(
                          icon: FontAwesomeIcons.commentDots,
                          text:
                              'Control total sobre quién puede enviarte mensajes',
                          isDarkMode: isDarkMode,
                          textColor: textColor,
                          fontSize: fontSizeProvider.fontSize - 2,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF9B30FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 10),
                        minimumSize: Size(double.infinity, 40),
                        elevation: 2,
                      ),
                      onPressed: () {
                        Navigator.pop(context, isRestricted);
                      },
                      child: Text(
                        'Guardar Cambios',
                        style: TextStyle(
                          fontSize: fontSizeProvider.fontSize ,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sección de ayuda movida al final
          Container(
            margin: EdgeInsets.only(left: 16, right: 16, bottom: 20, top: 8),
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.grey[800]!.withOpacity(0.5)
                  : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Necesitas ayuda?',
                  style: TextStyle(
                    fontSize: fontSizeProvider.fontSize,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 2),
                InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrivateAccountInfoScreen(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.help_outline,
                            color: Color(0xFF9B30FF), size: 20),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Más información sobre cuentas privadas',
                            style: TextStyle(
                                fontSize: fontSizeProvider.fontSize - 2,
                                color: Color(0xFF9B30FF),
                                decoration: TextDecoration.none,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios,
                            size: 14, color: Color(0xFF9B30FF)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String text,
    required bool isDarkMode,
    required Color textColor,
    required double fontSize,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color(0xFF9B30FF).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: isDarkMode ? Colors.white.withOpacity(0.5) : Color(0xFF9B30FF),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
                fontSize: fontSize - 2,
                color: textColor.withOpacity(0.8),
                fontWeight: FontWeight.w400),
          ),
        ),
      ],
    );
  }
}
