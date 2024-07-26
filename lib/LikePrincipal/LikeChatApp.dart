import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/estadoDark-White/DarkModeProvider.dart';
import '../app/home/shortVideos/ShortVideosScreen.dart';
import '../app/registros/login/ForgotPasswordScreen.dart';
import '../app/registros/login/LoginScreen.dart';
import '../app/registros/providers/CodeVerificationScreen.dart';
import '../app/registros/register/RegisterScreen.dart';
import '../app/registros/splash/SplashScreen.dart';
import 'HomeScreen.dart';

class LikeChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<DarkModeProvider>(
      builder: (context, darkModeProvider, child) {
        return MaterialApp(
          title: 'LikeChat',
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: Color(0xFFD9F103),
            scaffoldBackgroundColor: Colors.white,
            textTheme: TextTheme(
              bodyLarge: TextStyle(color: Colors.black),
              bodyMedium: TextStyle(color: Colors.black),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(0xFFD9F103)),
              ),
              labelStyle: TextStyle(color: Colors.grey[700]),
            ),
            buttonTheme: ButtonThemeData(
              buttonColor: Color(0xFFD9F103),
              textTheme: ButtonTextTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Color(0xFFD9F103),
            scaffoldBackgroundColor: Colors.black,
            textTheme: TextTheme(
              bodyLarge: TextStyle(color: Colors.white),
              bodyMedium: TextStyle(color: Colors.white),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.black,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(0xFFD9F103)),
              ),
              labelStyle: TextStyle(color: Colors.grey[300]),
            ),
            buttonTheme: ButtonThemeData(
              buttonColor: Color(0xFFD9F103),
              textTheme: ButtonTextTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          themeMode: darkModeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: '/',
          routes: {
            '/': (context) => SplashScreen(),
            '/login': (context) => LoginScreen(),
            '/recover_password': (context) => RecoverPasswordScreen(),
            '/register': (context) => RegisterScreen(),
            '/verification': (context) => CodeVerificationScreen(email: ''),
            '/home': (context) => HomeScreen(),
            '/shortVideos': (context) => ShortVideosScreen(),
          },
        );
      },
    );
  }
}
