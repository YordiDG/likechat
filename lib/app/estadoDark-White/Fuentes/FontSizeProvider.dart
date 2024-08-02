import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../DarkModeProvider.dart';

class FontSizeProvider with ChangeNotifier {
  static const double smallFontSize = 11.0;
  static const double mediumFontSize = 15.0;
  static const double largeFontSize = 21.0;

  double _fontSize = mediumFontSize; // Tamaño de fuente por defecto

  double get fontSize => _fontSize;

  void setFontSize(double newSize) {
    _fontSize = newSize;
    notifyListeners();
  }
}

class FontSizeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;

    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final selectedColor = Colors.cyan.withOpacity(0.2); // Color de fondo cian transparente para el seleccionado
    final iconColor = isDarkMode ? Colors.white : Colors.black;
    final selectedIconColor = Colors.cyan; // Color del ícono de check cuando está seleccionado

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tamaño de Fuente',
          style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: backgroundColor,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SafeArea(
        child: Container(
          color: backgroundColor,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selecciona el tamaño de fuente para la aplicación',
                style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 20),
              _buildFontSizeOption(
                context,
                iconColor,
                selectedIconColor,
                textColor,
                selectedColor,
                fontSizeProvider,
                'Pequeño',
                FontSizeProvider.smallFontSize,
              ),
              _buildFontSizeOption(
                context,
                iconColor,
                selectedIconColor,
                textColor,
                selectedColor,
                fontSizeProvider,
                'Mediano',
                FontSizeProvider.mediumFontSize,
              ),
              _buildFontSizeOption(
                context,
                iconColor,
                selectedIconColor,
                textColor,
                selectedColor,
                fontSizeProvider,
                'Grande',
                FontSizeProvider.largeFontSize,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFontSizeOption(
      BuildContext context,
      Color iconColor,
      Color selectedIconColor,
      Color textColor,
      Color selectedColor,
      FontSizeProvider fontSizeProvider,
      String label,
      double fontSize,
      ) {
    final bool isSelected = fontSizeProvider.fontSize == fontSize;

    return Container(
      color: isSelected ? selectedColor : null,
      child: ListTile(
        leading: Icon(Icons.text_fields, size: fontSize, color: iconColor),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.cyan : textColor, // Fuente seleccionada en cian, otras en el color de texto
            fontSize: fontSize,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: isSelected
            ? Icon(Icons.check, color: selectedIconColor)
            : null,
        onTap: () {
          fontSizeProvider.setFontSize(fontSize);
        },
      ),
    );
  }
}
