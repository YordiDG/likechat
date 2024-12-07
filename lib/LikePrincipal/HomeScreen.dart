import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import '../app/Globales/estadoDark-White/DarkModeProvider.dart';
import '../app/Globales/estadoDark-White/Fuentes/FontSizeProvider.dart';
import '../app/home/camara/VideoCaptureScreen.dart';
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
  int _selectedIndex = 0;
  bool _isVideoCaptureScreen = false; // Estado para ocultar/mostrar los botones de navegación

  DateTime? _lastPressedAt;

  // Lista de pantallas para la navegación
  static List<Widget> _widgetOptions = <Widget>[
    ShortVideosScreen(), // Índice 0
    FriendsScreen(), // Índice 1
    VideoCaptureScreen(), // Índice 2
    ChatsScreen(), // Índice 3
    ProfileScreen(), // Índice 4
  ];

  // Método para manejar la selección de ítems en la barra de navegación
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _isVideoCaptureScreen =
      (index == 2); // Si estamos en VideoCaptureScreen, ocultar botones
    });
  }

  Future<bool> _onWillPop() async {
    DateTime now = DateTime.now();

    // Manejar la navegación si estamos en la pantalla de captura de video
    if (_isVideoCaptureScreen) {
      setState(() {
        _selectedIndex = 0; // Cambiar a ShortVideosScreen
        _isVideoCaptureScreen = false; // Mostrar barra de navegación
      });
      return false; // Evitar la navegación hacia atrás
    }

    // Manejar la doble pulsación para salir de la app
    if (_lastPressedAt == null || now.difference(_lastPressedAt!) > Duration(seconds: 2)) {
      // Si no hay un toque reciente o fue hace más de 2 segundos
      _lastPressedAt = now;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: EdgeInsets.symmetric(horizontal: 21, vertical: 12), 
            decoration: BoxDecoration(
              color: Colors.grey.shade800.withOpacity(0.7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "Presiona nuevamente para salir",
              style: TextStyle(
                fontSize: 12,  
                color: Colors.white,  
              ),
              textAlign: TextAlign.center,  
            ),
          ),
          behavior: SnackBarBehavior.floating,  
          margin: EdgeInsets.only(bottom: 30, left: 40, right: 40),  
          duration: Duration(seconds: 2), 
          backgroundColor: Colors.transparent,  
          elevation: 0, // Sin sombra
        ),
      );
      return false; // No salir de la app
    }

    // Si el toque es el segundo en menos de 2 segundos
    if ((await Vibration.hasVibrator()) == true) {
      Vibration.vibrate(duration: 100); // Vibra el dispositivo
    }

    return true; // Permitir salir de la app
  }


  @override
  Widget build(BuildContext context) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final backgroundColor = darkModeProvider.backgroundColor;

    return WillPopScope(
      onWillPop: _onWillPop, // Manejo del botón de retroceso
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_selectedIndex == 3) // Mostrar LikeChatScreen solo cuando se selecciona la pestaña de chats
              LikeChatScreen(),
            Expanded(
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
          ],
        ),
        // Mostrar barra de navegación solo si no estamos en VideoCaptureScreen
        bottomNavigationBar: !_isVideoCaptureScreen
            ? BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: _buildNavItemHome(0),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: _buildNavItemFriend(1),
              label: 'Amigos',
            ),
            BottomNavigationBarItem(
              icon: _buildNavAdd(FontAwesomeIcons.add, 2),
              label: '', // Se puede dejar vacío si no se desea etiqueta
            ),
            BottomNavigationBarItem(
              icon: _buildNavItemMessage(3),
              label: 'Mensaje',
            ),
            BottomNavigationBarItem(
              icon: _buildNavItemProfile(4),
              label: 'Perfil',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.cyan,
          unselectedItemColor: Colors.grey,
          backgroundColor: backgroundColor,
          iconSize: 18.0,
          onTap: _onItemTapped,
          selectedLabelStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 11, // Tamaño de fuente para la etiqueta no seleccionada
            fontWeight: FontWeight.bold,
          ),

        )
            : null, // No mostrar barra de navegación en VideoCaptureScreen
      ),
    );
  }



// botones de navegacion
  Widget _buildNavItemHome(int index) {
    // Cambiar el ícono de mensaje por el ícono de casa
    IconData icon = _selectedIndex == index
        ? FontAwesomeIcons.home
        : FontAwesomeIcons.house;

    return Container(
      width: 50, // Ancho fijo
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10),
        color: _selectedIndex == index
            ? Colors.cyan.withOpacity(0.2)
            : Colors.transparent,
      ),
      padding: EdgeInsets.symmetric(vertical: 5.0), // Solo vertical
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Centrar verticalmente
        children: [
          Icon(
            icon,
            color: _selectedIndex == index ? Colors.cyan : Colors.grey,
            size: 21, // Tamaño consistente
          ),
        ],
      ),
    );
  }

  //boton de amigos
  Widget _buildNavItemFriend(int index) {
    // Cambiar el ícono de mensaje por el ícono de casa
    IconData icon = _selectedIndex == index
        ? FontAwesomeIcons.users
        : FontAwesomeIcons.users;

    return Container(
      width: 50, // Ancho fijo
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10),
        color: _selectedIndex == index
            ? Colors.cyan.withOpacity(0.2)
            : Colors.transparent,
      ),
      padding: EdgeInsets.symmetric(vertical: 5.0), // Solo vertical
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Centrar verticalmente
        children: [
          Icon(
            icon,
            color: _selectedIndex == index ? Colors.cyan : Colors.grey,
            size: 21, // Tamaño consistente
          ),
        ],
      ),
    );
  }

  Widget _buildNavAdd(IconData icon, int index) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final backgroundColor = darkModeProvider.backgroundColor;

    return Padding(
      padding: const EdgeInsets.only(top: 9.0),
      child: Container(
        width: 40,
        height: 37,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: isDarkMode ? Colors.grey.shade600 : Colors.grey,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isDarkMode ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 4,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Borde superior cyan
            Positioned(
              top: 0,
              left: 4,
              right: 4,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  color: Colors.cyan,
                ),
              ),
            ),
            // Borde inferior cyan
            Positioned(
              bottom: 0,
              left: 4,
              right: 4,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  color: Colors.cyan,
                ),
              ),
            ),
            Center(
              child: Icon(
                icon,
                color: iconColor,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //boton de mensale
  Widget _buildNavItemMessage(int index) {
    IconData icon = _selectedIndex == index
        ? FontAwesomeIcons.solidComment
        : FontAwesomeIcons.solidComment;

    //FontAwesomeIcons.solidComment
    return Container(
      width: 50, // Ancho fijo
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10),
        color: _selectedIndex == index
            ? Colors.cyan.withOpacity(0.2)
            : Colors.transparent,
      ),
      padding: EdgeInsets.symmetric(vertical: 5.0), // Solo vertical
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Centrar verticalmente
        children: [
          Icon(
            icon,
            color: _selectedIndex == index ? Colors.cyan : Colors.grey,
            size: 21, // Tamaño consistente
          ),
        ],
      ),
    );
  }

  //boton de perfil
  Widget _buildNavItemProfile(int index) {

    IconData icon = _selectedIndex == index
        ? FontAwesomeIcons.solidUser
        : FontAwesomeIcons.solidUser;

    return Container(
      width: 50, // Ancho fijo
      decoration: BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(10),
        color: _selectedIndex == index
            ? Colors.cyan.withOpacity(0.2) // Color de fondo si está seleccionado
            : Colors.transparent,
      ),
      padding: EdgeInsets.symmetric(vertical: 5.0), // Solo vertical
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // Centrar verticalmente
        children: [
          Icon(
            icon,
            color: _selectedIndex == index ? Colors.cyan : Colors.grey, // Color del ícono
            size: 21, // Tamaño consistente
          ),
        ],
      ),
    );
  }
}
