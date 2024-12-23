import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:connectivity/connectivity.dart';
import 'dart:io';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int _retryCount = 0;
  bool _isCheckingConnection =
      false; // Variable para controlar el estado de verificación

  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
  }

  Future<void> _checkInternetConnection() async {
    setState(() {
      _isCheckingConnection = true; // Mostrar el círculo de carga
    });

    var connectivityResult = await (Connectivity().checkConnectivity());

    setState(() {
      _isCheckingConnection = false; // Ocultar el círculo de carga
    });

    if (connectivityResult == ConnectivityResult.none) {
      _retryCount++;
      if (_retryCount < 3) {
        _showNoInternetDialog();
      } else {
        exit(0); // Cerrar la aplicación después de 3 intentos
      }
    } else {
      _navigateToLogin();
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.circular(7.0), // Radio del borde del diálogo
        ),
        title: Text(
          'Sin Conexión de Internet',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.red, // Color llamativo para el título
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off, color: Colors.red, size: 50),
            SizedBox(height: 20),
            Text(
              'Por favor, verifica tu conexión a internet e intenta nuevamente.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cerrar el diálogo
              _checkInternetConnection(); // Volver a intentar la conexión
            },
            style: TextButton.styleFrom(
              side: BorderSide(color: Colors.cyan, width: 2.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            ),
            child: Text(
              'Reintentar',
              style: TextStyle(
                fontSize: 18,
                color: Colors.pink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToLogin() {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF00E5FF),
      //backgroundColor: Color(0xFF0D0D55),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('lib/assets/splash/chaski.png', height: 220),
                SizedBox(height: 1),
                Text(
                  'LikeChat',
                  style: GoogleFonts.poppins(
                    fontSize: 40,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black.withOpacity(0.7),
                      ),
                      Shadow(
                        offset: Offset(-2, -2),
                        blurRadius: 1,
                        color: Color(0xFF6A0DAD).withOpacity(0.8),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_isCheckingConnection) // Mostramos el círculo de carga en la parte inferior si está verificando la conexión
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: Lottie.asset(
                  'lib/assets/loading/infinity_cyan.json',
                  width: 60,
                  height: 60,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
