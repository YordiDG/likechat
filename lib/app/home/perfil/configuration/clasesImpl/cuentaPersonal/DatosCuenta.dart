import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../Globales/estadoDark-White/DarkModeProvider.dart';


class DatosCuenta extends StatelessWidget {
  final String email;
  final String phoneNumber;
  final String region;

  DatosCuenta({
    required this.email,
    required this.phoneNumber,
    required this.region,
  });

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final backgroundColor = darkModeProvider.backgroundColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Datos de la Cuenta',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
      ),
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: isDarkMode ? Colors.grey[850] : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  Icons.email,
                  'Correo Electrónico:',
                  email,
                  context,
                ),
                Divider(
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                  thickness: 1,
                ),
                _buildInfoRow(
                  Icons.phone,
                  'Teléfono:',
                  phoneNumber,
                  context,
                ),
                Divider(
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                  thickness: 1,
                ),
                _buildInfoRow(
                  Icons.location_on,
                  'Región:',
                  region,
                  context,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String info, BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;

    return Row(
      children: [
        Icon(icon, color: darkModeProvider.iconColor, size: 24),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: darkModeProvider.textColor,
                ),
              ),
              SizedBox(height: 8),
              Text(
                info,
                style: TextStyle(
                  fontSize: 16,
                  color: darkModeProvider.textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
