import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app/Globales/estadoDark-White/DarkModeProvider.dart';
import '../app/Globales/estadoDark-White/Fuentes/FontSizeProvider.dart';
import '../app/home/chats/ChatsScreen.dart';
import '../app/home/chats/storys/LikeChatScreen.dart';
import '../app/home/friends/FriendsScreen.dart';
import '../app/home/notificaction/NotificationsScreen.dart';
import '../app/home/perfil/ProfileScreen.dart';
import '../app/home/shortVideos/ShortVideosScreen.dart';

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
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final backgroundColor = darkModeProvider.backgroundColor;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_selectedIndex == 0) // Mostrar LikeChatScreen solo cuando se selecciona la pestaña de chats
            LikeChatScreen(),
          Expanded(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.1)), // Borde gris en la parte superior
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.chat, color: _selectedIndex == 0 ? Colors.cyan : Colors.grey),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group, color: _selectedIndex == 1 ? Colors.cyan : Colors.grey),
              label: 'Amigos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_collection_rounded, color: _selectedIndex == 2 ? Colors.cyan : Colors.grey),
              label: 'Snippets',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications, color: _selectedIndex == 3 ? Colors.cyan : Colors.grey ),
              label: 'Avisos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, color: _selectedIndex == 4 ? Colors.cyan : Colors.grey ),
              label: 'Perfil',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.cyan,
          unselectedItemColor: Colors.grey,
          backgroundColor: backgroundColor,
          iconSize: 28.0,
          onTap: _onItemTapped,
          selectedLabelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), // Usa el tamaño de fuente global
                 //fontSize: fontSizeProvider.fontSize,
        ),
      ),
    );
  }
}
