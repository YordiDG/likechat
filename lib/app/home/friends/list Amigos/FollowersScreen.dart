import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../Globales/estadoDark-White/DarkModeProvider.dart';

class FollowersScreen extends StatefulWidget {
  @override
  _FollowersScreenState createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  List<Map<String, String>> friends = [];
  final Set<String> following = {};
  bool _isSearching = false; // Para saber si estamos buscando
  TextEditingController _searchController =
      TextEditingController(); // Controlador para el campo de búsqueda
  List<Map<String, String>> filteredFriends = []; // Lista de amigos filtrados

  @override
  void initState() {
    super.initState();
    fetchFriends();
  }

  Future<void> fetchFriends() async {
    try {
      final response =
          await http.get(Uri.parse('https://randomuser.me/api/?results=50'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          friends = (data['results'] as List)
              .map<Map<String, String>>((dynamic user) {
            return {
              "name": "${user['name']['first']} ${user['name']['last']}",
              "username": user['login']['username'],
              "image": user['picture']['medium'],
              "id": user['login']['uuid'],
            };
          }).toList();
          filteredFriends = friends; // Al principio, mostrar todos los amigos
        });
      } else {
        throw Exception('Failed to load friends');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void toggleFollow(String followerId) {
    setState(() {
      if (following.contains(followerId)) {
        following.remove(followerId);
      } else {
        following.add(followerId);
      }
    });
  }

  // Método para filtrar los resultados según la búsqueda
  void _filterSearchResults(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredFriends = friends; // Restablecer a la lista completa
      });
    } else {
      setState(() {
        filteredFriends = friends
            .where((friend) =>
                friend['name']!.toLowerCase().contains(query.toLowerCase()) ||
                friend['username']!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  InputDecoration customDecoration(String hint) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;

    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
          color: isDarkMode ? Colors.white54 : Colors.black54,
          fontSize: 12,
          fontWeight: FontWeight.w500),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.cyan),
        borderRadius: BorderRadius.circular(10.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.cyan),
        borderRadius: BorderRadius.circular(10.0),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final backgroundColor = darkModeProvider.backgroundColor;

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? Container(
                height: 34,
                // Reduced height
                width: double.infinity,
                // Full width
                margin: EdgeInsets.symmetric(horizontal: 1),
                // Horizontal margin
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                  // Background color based on mode
                  borderRadius: BorderRadius.circular(6), // Rounded corners
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    textSelectionTheme: TextSelectionThemeData(
                      cursorColor: Colors.cyan,
                      // Cursor color
                      selectionColor: Colors.cyan.withOpacity(0.3),
                      // Selection background color
                      selectionHandleColor: Colors.cyan, // Handle color
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: _filterSearchResults,
                    style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.w500 // Reduced font size
                        ),
                    decoration: InputDecoration(
                      hintText: 'Buscar seguidores...',
                      hintStyle: TextStyle(
                        color: isDarkMode ? Colors.white54 : Colors.black54,
                      ),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    ),
                  ),
                ),
              )
            : Text(
                'Seguidores',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
        backgroundColor: backgroundColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDarkMode ? Colors.white : Colors.black,
            size: 22,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          _isSearching
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _isSearching = false; // Exit search mode
                      _searchController.clear();
                      filteredFriends =
                          friends; // Reset the list to all friends
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.pink,
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(3),
                    child: Icon(
                      Icons.clear_outlined,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                )
              : IconButton(
                  icon: Icon(
                    Icons.search,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                  onPressed: () {
                    setState(() {
                      _isSearching = true; // Activate search mode
                    });
                  },
                ),
          SizedBox(width: 10), // Extra spacing for better layout
        ],
      ),
      body: filteredFriends.isEmpty
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.cyan), // Set the color to cyan
              ),
            )
          : ListView.builder(
              itemCount: filteredFriends.length,
              itemBuilder: (context, index) {
                var friend = filteredFriends[index];
                bool isFollowing = following.contains(friend['id']);

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    children: [
                      // Imagen de perfil con borde
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: NetworkImage(friend['image']!),
                        ),
                      ),
                      SizedBox(width: 10),
                      // Contenido principal con nombre y username
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              friend['name']!,
                              style: TextStyle(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                  fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '@${friend['username']}',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 11,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 10),
                      // Botón y tres puntos al final de la fila
                      Container(
                        constraints: BoxConstraints(
                          minWidth: 100, // Ajustar según el diseño requerido
                          maxWidth: double.infinity,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 30,
                              width: 70,
                              child: ElevatedButton(
                                onPressed: () {
                                  toggleFollow(friend['id']!);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isFollowing
                                      ? Colors.transparent
                                      : Colors.cyan,
                                  padding: EdgeInsets.symmetric(vertical: 5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    side: isFollowing
                                        ? BorderSide(
                                            color: Colors.grey.shade200,
                                            width: 1.5)
                                        : BorderSide.none,
                                  ),
                                ),
                                child: Text(
                                  isFollowing ? 'Mensaje' : 'Seguir',
                                  style: TextStyle(
                                      fontSize: 13, color: Colors.white),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.more_vert, color: iconColor),
                              onPressed: () {
                                _showOptionsModal(context, friend['id']!);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _showOptionsModal(BuildContext context, String followerId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[850],
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Encabezado con icono
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.settings,
                    color: Colors.white,
                    size: 24,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Configuración',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.grey[700]),
              SizedBox(height: 20),
              // Botón de eliminar
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Lógica para eliminar aquí
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Eliminar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 11),
                  minimumSize: Size(double.infinity, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 10),
              // Botón de cancelar
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Cancelar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600],
                  padding: EdgeInsets.symmetric(vertical: 11),
                  minimumSize: Size(double.infinity, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}
