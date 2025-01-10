import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../app/APIS-Consumir/Deezer-API-Musica/MusicModal.dart';
import '../app/Globales/Connections/NetworkProvider.dart';
import '../app/Globales/estadoDark-White/DarkModeProvider.dart';
import '../app/Globales/estadoDark-White/Fuentes/FontSizeProvider.dart';
import '../app/Globales/FontApp/AppThemeProvider.dart';
import '../app/Globales/FontApp/AppTypography.dart';
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
    return Consumer5<DarkModeProvider, FontSizeProvider, LocalizationProvider, NetworkProvider, AppThemeProvider>(
      builder: (context, darkModeProvider, fontSizeProvider, localizationProvider, networkProvider, appThemeProvider, child) {
        final isDarkMode = darkModeProvider.isDarkMode;
        final typography = AppTypography();

        // Cambiar el estilo del sistema según el modo oscuro o claro
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: isDarkMode ? Colors.black : Colors.white,
          systemNavigationBarIconBrightness: isDarkMode ? Brightness.light : Brightness.dark,
        ));

        Widget noConnectionBanner = networkProvider.isConnected
            ? SizedBox()
            : Container(
          color: Colors.grey.shade800,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top,
            bottom: 4,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.signal_wifi_off, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Sin conexión a Internet',
                style: typography.getTextTheme(
                  fontSize: fontSizeProvider.fontSize,
                  isDarkMode: isDarkMode,
                ).bodyMedium,
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
            textTheme: typography.getTextTheme(
              fontSize: fontSizeProvider.fontSize,
              isDarkMode: false,
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
            textTheme: typography.getTextTheme(
              fontSize: fontSizeProvider.fontSize,
              isDarkMode: true,
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

          // Configuraciones adicionales para mejorar la accesibilidad
          debugShowCheckedModeBanner: false,
          highContrastDarkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Colors.cyan,
            scaffoldBackgroundColor: Colors.black,
            textTheme: typography.getTextTheme(
              fontSize: fontSizeProvider.fontSize * 1.2,
              isDarkMode: true,
            ),
          ),
          highContrastTheme: ThemeData(
            brightness: Brightness.light,
            primaryColor: Colors.cyan,
            scaffoldBackgroundColor: Colors.white,
            textTheme: typography.getTextTheme(
              fontSize: fontSizeProvider.fontSize * 1.2,
              isDarkMode: false,
            ),
          ),
        );
      },
    );
  }
}