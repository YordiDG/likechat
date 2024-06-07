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
        title: Text('No Internet Connection'),
        content: Row(
          children: [
            Icon(Icons.wifi_off, color: Color(0xFFD9F103)),
            SizedBox(width: 10),
            Expanded(
              child: Text('Please check your internet connection and try again.'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _checkInternetConnection();
            },
            child: Text('Retry'),
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
