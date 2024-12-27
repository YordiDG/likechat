import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../app/Globales/estadoDark-White/DarkModeProvider.dart';
import '../app/Globales/estadoDark-White/Fuentes/FontSizeProvider.dart';
import '../app/home/camara/VideoCaptureScreen.dart';
import '../app/home/chats/ChatsScreen.dart';
import '../app/home/chats/storys/HistorysLikeChatScreen.dart';
import '../app/home/friends/FriendsScreen.dart';
import '../app/home/notificaction/NotificationsScreen.dart';
import '../app/home/perfil/ProfileScreen.dart';
import '../app/home/shortVideos/ShortVideosScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _isVideoCaptureScreen = false;
  DateTime? _lastPressedAt;

  static final List<Widget> _widgetOptions = <Widget>[
    ShortVideosScreen(),
    FriendsScreen(),
    VideoCaptureScreen(),
    ChatsScreen(),
    ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _isVideoCaptureScreen = (index == 2);
    });
  }

  Future<bool> _onWillPop() async {
    DateTime now = DateTime.now();

    if (_isVideoCaptureScreen) {
      setState(() {
        _selectedIndex = 0;
        _isVideoCaptureScreen = false;
      });
      return false;
    }

    if (_lastPressedAt == null || now.difference(_lastPressedAt!) > Duration(seconds: 2)) {
      _lastPressedAt = now;
      Fluttertoast.showToast(
        msg: "Pulsa de nuevo para salir",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey.shade700,
        textColor: Colors.white,
        fontSize: 13.0,
      );
      return false;
    }

    if ((await Vibration.hasVibrator()) == true) {
      Vibration.vibrate(duration: 100);
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {

    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_selectedIndex == 3) // Mostrar LikeChatScreen solo cuando se selecciona la pestaña de chats
              HistorysLikeChatScreen(),
            Expanded(
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
          ],
        ),
        bottomNavigationBar: _isVideoCaptureScreen
            ? SizedBox.shrink()
            : Container(
          color: _selectedIndex == 0
              ? Colors.black
              : (isDarkMode ? Colors.black : Colors.white), // Validación de colores
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Divider(
                color: isDarkMode ? Colors.grey.shade200 : Colors.grey.shade700,
                thickness: 0.1,
                height: 0.1,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [ //Icons.hub icono de amigos, Icons.grid_view es cuadrados y este amigo wifi: Icons.connect_without_contact
                    _buildNavItem(icon: Icons.home_outlined, label: "Inicio", index: 0),
                    _buildNavItem(icon: Icons.grid_view, label: "Novedades", index: 1),
                    _buildCircleButton(),
                    _buildNavItemChat(icon: FontAwesomeIcons.comments, label: "Chats", index: 3),
                    _buildNavItem(icon: Icons.person_outlined, label: "Perfil", index: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context, listen: false);
    final isDarkMode = darkModeProvider.isDarkMode;

    final bool isSelected = _selectedIndex == index;

    // Verificación especial cuando _selectedIndex == 0
    final bool isSpecialSelected = _selectedIndex == 0;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Minimiza el tamaño vertical
        children: [
          Icon(
            isSelected ? _getSolidIcon(icon) : icon,
            color: isSpecialSelected && isSelected
                ? Colors.white // Blanco si _selectedIndex == 0 y seleccionado
                : (isSelected
                ? (isDarkMode ? Colors.white : Colors.black)
                : (isDarkMode ? Colors.grey : Colors.grey[500])),
            size: 32,
          ),
          Text(
            label,
            style: TextStyle(
              color: isSpecialSelected && isSelected
                  ? Colors.white // Blanco si _selectedIndex == 0 y seleccionado
                  : (isSelected
                  ? (isDarkMode ? Colors.white : Colors.black)
                  : (isDarkMode ? Colors.grey : Colors.grey[500])),
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton() {
    final darkModeProvider = Provider.of<DarkModeProvider>(context, listen: false);
    final isDarkMode = darkModeProvider.isDarkMode;

    final bool isSpecialSelected = _selectedIndex == 0; // Verificación especial

    return GestureDetector(
      onTap: () => _onItemTapped(2),
      child: Container(
        height: 39,
        width: 39,
        decoration: BoxDecoration(
          color: isSpecialSelected
              ? Colors.transparent
              : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSpecialSelected
                ? Colors.white // Borde gris cuando _selectedIndex == 0
                : (isDarkMode ? Colors.white : Colors.black), // Normal en otros casos
            width: 1.5,
          ),
        ),
        child: Center(
          child: Icon(
            FontAwesomeIcons.add,
            color: isSpecialSelected
                ? Colors.white // Icono gris si _selectedIndex == 0
                : (isDarkMode ? Colors.white : Colors.black),
            size: 21,
          ),
        ),
      ),
    );
  }


  Widget _buildNavItemChat({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context, listen: false);
    final isDarkMode = darkModeProvider.isDarkMode;
    final bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Minimiza el tamaño vertical
        children: [
          Icon(
            isSelected ? _getSolidIcon(icon) : icon,
            color: isSelected
                ? (isDarkMode ? Colors.white : Colors.black)
                : (isDarkMode ? Colors.grey : Colors.grey[500]),
            size: 28,
          ),
          SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? (isDarkMode ? Colors.white : Colors.black)
                  : (isDarkMode ? Colors.grey : Colors.grey[500]),
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }


  IconData _getSolidIcon(IconData icon) {
    switch (icon) {
      case Icons.home_outlined:
        return Icons.home;
      case Icons.grid_view:
        return Icons.grid_view_sharp;
      case FontAwesomeIcons.comments:
        return FontAwesomeIcons.solidComments;
      case Icons.person_outlined:
        return Icons.person;
      default:
        return icon;
    }
  }

}
