import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../Globales/estadoDark-White/DarkModeProvider.dart';

class VerContrasenia extends StatefulWidget {
  @override
  _VerContraseniaState createState() => _VerContraseniaState();
}

class _VerContraseniaState extends State<VerContrasenia> {
  final TextEditingController _passwordController = TextEditingController();
  bool _obscureText = true;
  final String _password = 'MiContraseñaSegura'; // Contraseña real que quieres mostrar
  bool _isPasswordCorrect = false;
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    // Mostrar el diálogo de verificación al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPasswordDialog();
    });
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void _showPasswordDialog() {
    final darkModeProvider = Provider.of<DarkModeProvider>(
        context, listen: false);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                    10), // Ajusta los bordes aquí
              ),
              backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
              title: Row(
                children: [
                  Icon(Icons.lock, color: iconColor, size: 32),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Verificar Contraseña',
                      style: TextStyle(color: textColor, fontSize: 22),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Ingrese la contraseña',
                      hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureText ? Icons.visibility : Icons
                            .visibility_off, color: iconColor),
                        onPressed: _togglePasswordVisibility,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.cyan, width: 2.0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: iconColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  if (_showError)
                    Row(
                      children: [
                        Icon(Icons.error, color: Colors.red),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Contraseña incorrecta. Inténtalo de nuevo.',
                            style: TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancelar', style: TextStyle(color: iconColor)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    _verifyPassword(setState);
                  },
                  child: Text('Aceptar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _verifyPassword(Function setStateDialog) {
    if (_passwordController.text == '1234') {
      setState(() {
        _isPasswordCorrect = true;
        _showError = false;
      });
      Navigator.of(context).pop();
    } else {
      setStateDialog(() {
        _isPasswordCorrect = false;
        _showError = true;
      });
      Future.delayed(Duration(seconds: 2), () {
        setStateDialog(() {
          _showError = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final backgroundColor = darkModeProvider.backgroundColor;

    return Scaffold(
      appBar: AppBar(
        title: Text('Ver Contraseña', style: TextStyle(color: textColor)),
        backgroundColor: backgroundColor,
      ),
      body: Center(
        child: _isPasswordCorrect
            ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0), // Ajusta el padding aquí
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Contraseña:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blueGrey,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                obscureText: _obscureText,
                decoration: InputDecoration(
                  hintText: '******',
                  hintStyle: TextStyle(color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility : Icons.visibility_off,
                      color: Colors.blueGrey,
                    ),
                    onPressed: _togglePasswordVisibility,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                ),
                controller: TextEditingController(text: _password),
              ),
            ],
          ),
        )
            : _passwordController.text.isEmpty
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, color: Colors.grey, size: 80),
            SizedBox(height: 16),
            Text(
              'Introduce tu contraseña para ver',
              style: TextStyle( color: Colors.grey[600], fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ],
        )
            : _showError
            ? Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Contraseña incorrecta. Inténtalo de nuevo.',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            ),
          ],
        )
            : Container(), // Esto es para ocultar cualquier mensaje de error después de dos segundos
      ),
    );
  }

}