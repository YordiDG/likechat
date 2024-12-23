import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/APIS-Consumir/Deezer-API-Musica/MusicModal.dart';
import '../app/Globales/Connections/NetworkProvider.dart';
import '../app/Globales/estadoDark-White/DarkModeProvider.dart';
import '../app/Globales/estadoDark-White/Fuentes/FontSizeProvider.dart';
import '../app/home/notificaction/NotificationsScreen.dart';
import '../app/home/perfil/configuration/clasesImpl/idioma/AppTranslations.dart';
import '../app/home/shortVideos/ShortVideosScreen.dart';
import '../app/home/shortVideos/searchRapida/SearchScreen.dart';
import '../app/registros/login/ForgotPasswordScreen.dart';
import '../app/registros/login/LoginScreen.dart';
import '../app/registros/providers/CodeVerificationScreen.dart';
import '../app/registros/register/RegisterScreen.dart';
import '../app/registros/splash/SplashScreen.dart';
import 'HomeScreen.dart';

class LikeChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer4<DarkModeProvider, FontSizeProvider, LocalizationProvider, NetworkProvider>(
      builder: (context, darkModeProvider, fontSizeProvider, localizationProvider, networkProvider, child) {
        // Widget para mostrar cuando no hay conexión
        Widget noConnectionBanner = networkProvider.isConnected ? SizedBox() : Container(
          color: Colors.red,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top, bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.signal_wifi_off, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Sin conexión a Internet',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        );

        return MaterialApp(
          title: 'LikeChat',
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.cyan,
            scaffoldBackgroundColor: Colors.white,
            textTheme: TextTheme(
              bodyLarge: TextStyle(color: Colors.black, fontSize: fontSizeProvider.fontSize),
              bodyMedium: TextStyle(color: Colors.black, fontSize: fontSizeProvider.fontSize),
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
                borderSide: BorderSide(color: Colors.cyan),
              ),
              labelStyle: TextStyle(color: Colors.grey[700]),
            ),
            buttonTheme: ButtonThemeData(
              buttonColor: Colors.cyan,
              textTheme: ButtonTextTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: Colors.cyan,
              selectionColor: Colors.cyan.withOpacity(0.3),
              selectionHandleColor: Colors.cyan,
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.cyan,
            scaffoldBackgroundColor: Colors.black,
            textTheme: TextTheme(
              bodyLarge: TextStyle(color: Colors.white, fontSize: fontSizeProvider.fontSize),
              bodyMedium: TextStyle(color: Colors.white, fontSize: fontSizeProvider.fontSize),
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
                borderSide: BorderSide(color: Colors.cyan),
              ),
              labelStyle: TextStyle(color: Colors.grey[300]),
            ),
            buttonTheme: ButtonThemeData(
              buttonColor: Colors.cyan,
              textTheme: ButtonTextTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            textSelectionTheme: TextSelectionThemeData(
              cursorColor: Colors.cyan,
              selectionColor: Colors.cyan.withOpacity(0.3),
              selectionHandleColor: Colors.cyan,
            ),
          ),
          locale: localizationProvider.currentLocale,
          supportedLocales: AppTranslations.supportedLocales,
          themeMode: darkModeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          builder: (context, child) {
            // Envolver la app con un Stack para mostrar el banner de sin conexión
            return Stack(
              children: [
                child!,
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: noConnectionBanner,
                ),
              ],
            );
          },
          initialRoute: '/',
          routes: {
            '/': (context) => SplashScreen(),
            '/login': (context) => LoginScreen(),
            '/recover_password': (context) => RecoverPasswordScreen(),
            '/register': (context) => RegisterScreen(),
            '/verification': (context) => CodeVerificationScreen(email: ''),
            '/home': (context) => HomeScreen(),
            '/shortVideos': (context) => ShortVideosScreen(),
            '/search-rapida': (context) => SearchScreen(),
            '/musica-modal': (context) => MusicModal(),
            '/avisos': (context) => NotificationsScreen(),
          },
        );
      },
    );
  }
}