import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:connectivity/connectivity.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkInternetConnection();
  }

  Future<void> _checkInternetConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      _showNoInternetDialog();
    } else {
      _navigateToLogin();
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Sin Conexión de Internet',
          style: TextStyle(
            fontSize: 22,
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
              Navigator.of(context).pop();
              _checkInternetConnection();
            },
            style: TextButton.styleFrom(
              side: BorderSide(color: Colors.cyan, width: 2.0), // Borde ligero en el botón
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
      backgroundColor: Color(0xFF0D0D55),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('lib/assets/logo.png', height: 300),
            SizedBox(height: 20),
            Text(
              'LikeChat',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFD9F103),
              ),
            ),
            Container(
              height: 130,
              width: 130,
              child: Lottie.asset('lib/assets/loading_animation.json'),
            ),
          ],
        ),
      ),
    );
  }
}
