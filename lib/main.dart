import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/chats/ChatsScreen.dart';
import 'app/friends/FriendsScreen.dart';
import 'app/notificaction/NotificationsScreen.dart';
import 'app/perfil/ProfileScreen.dart';
import 'app/registros/login/ForgotPasswordScreen.dart';
import 'app/registros/login/LoginScreen.dart';
import 'app/registros/providers/AuthProvider.dart';
import 'app/registros/providers/CodeVerificationScreen.dart';
import 'app/registros/register/RegisterScreen.dart';
import 'app/registros/splash/SplashScreen.dart';
import 'app/shortVideos/ShortVideosScreen.dart';
import 'app/storys/LikeChatScreen.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(

      create: (context) => AuthProvider(),
      child: MaterialApp(
        title: 'LikeChat',
        theme: ThemeData(
          primaryColor: Color(0xFFD9F103),
          scaffoldBackgroundColor: Colors.white,
          textTheme: TextTheme(
            bodyText1: TextStyle(color: Colors.white),
            bodyText2: TextStyle(color: Colors.white),
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
        initialRoute: '/',
        routes: {
          '/': (context) => SplashScreen(),
          '/login': (context) => LoginScreen(),
          '/recover_password': (context) => RecoverPasswordScreen(),
          '/register': (context) => RegisterScreen(),
          '/verification': (context) => CodeVerificationScreen(email: '',),
          '/home': (context) => HomeScreen(),
        },
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2;

  static List<Widget> _widgetOptions = <Widget>[
    ChatsScreen(),
    FriendsScreen(),
    ShortVideosScreen(),
    NotificationsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_selectedIndex ==
              0) // Mostrar LikeChatScreen solo cuando se selecciona la pestaña de chats
            LikeChatScreen(),
          Expanded(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        color: Color(0xFF5D3FD3), // Púrpura oscuro
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: 'Amigos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_collection_rounded),
              label: 'Snippets',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notification',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Color(0xFFD9F103),
          unselectedItemColor: Colors.white,
          backgroundColor: Color(0xFF0D0D55),
          iconSize: 30.0,
          onTap: _onItemTapped,
        ),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                // Abrir nueva pantalla de chat
              },
              child: Icon(Icons.message, color: Colors.white),
              backgroundColor: Color(0xFF8A960A), // Púrpura oscuro
            )
          : null,
    );
  }
}


