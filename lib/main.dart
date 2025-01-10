import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'LikePrincipal/LikeChatApp.dart';
import 'app/Globales/Connections/NetworkProvider.dart';
import 'app/Globales/FontApp/AppThemeProvider.dart';
import 'app/Globales/estadoDark-White/DarkModeProvider.dart';
import 'app/Globales/estadoDark-White/Fuentes/FontSizeProvider.dart';
import 'app/home/perfil/configuration/clasesImpl/idioma/AppTranslations.dart';
import 'app/registros/providers/AuthProvider.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => DarkModeProvider()),
        ChangeNotifierProvider(create: (context) => FontSizeProvider()),
        ChangeNotifierProvider(create: (context) => LocalizationProvider()),
        ChangeNotifierProvider(create: (context) => NetworkProvider()),
        ChangeNotifierProvider(create: (context) => AppThemeProvider()),
      ],
      child: LikeChatApp(),
    ),
  );
}
