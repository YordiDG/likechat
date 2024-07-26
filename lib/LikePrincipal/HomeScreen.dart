import 'package:flutter/material.dart';

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
          border: Border(top: BorderSide(color: Color(0xFF464545), width: 1.0)), // Borde gris en la parte superior
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.chat, color: _selectedIndex == 0 ? Colors.cyan : Colors.grey), // Ícono azul turquesa cuando seleccionado, gris cuando no
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group, color: _selectedIndex == 1 ? Colors.cyan : Colors.grey), // Ícono azul turquesa cuando seleccionado, gris cuando no
              label: 'Amigos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_collection_rounded, color: _selectedIndex == 2 ? Colors.cyan : Colors.grey), // Ícono azul turquesa cuando seleccionado, gris cuando no
              label: 'Snippets',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications, color: _selectedIndex == 3 ? Colors.cyan : Colors.grey), // Ícono azul turquesa cuando seleccionado, gris cuando no
              label: 'Notification',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, color: _selectedIndex == 4 ? Colors.cyan : Colors.grey), // Ícono azul turquesa cuando seleccionado, gris cuando no
              label: 'Perfil',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.cyan, // Color azul turquesa para ícono seleccionado (relleno y texto)
          unselectedItemColor: Colors.grey, // Color de ícono no seleccionado (gris sin relleno)
          backgroundColor: Colors.black, // Color de fondo del BottomNavigationBar (blanco)
          iconSize: 30.0,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

}
