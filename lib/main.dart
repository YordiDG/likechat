import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'LikePrincipal/LikeChatApp.dart';
import 'app/estadoDark-White/DarkModeProvider.dart';
import 'app/registros/providers/AuthProvider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider()),
        ChangeNotifierProvider(create: (context) => DarkModeProvider()),
      ],
      child: LikeChatApp(),
    ),
  );
}
