import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../../../../../../Globales/estadoDark-White/DarkModeProvider.dart';

class FriendsModales extends StatefulWidget {
  @override
  _FriendsModalState createState() => _FriendsModalState();
}

class _FriendsModalState extends State<FriendsModales> {
  List<Map<String, String>> friends = [];
  List<Map<String, String>> selectedFriends = [];
  TextEditingController searchController = TextEditingController();
  bool showMessage = false; // Controla la visibilidad del mensaje
  Timer? _timer; // Temporizador para ocultar el mensaje

  @override
  void initState() {
    super.initState();
    fetchFriends(); // Llamar a la función para obtener amigos
  }

  Future<void> fetchFriends() async {
    try {
      final response = await http.get(Uri.parse('https://randomuser.me/api/?results=50'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          friends = (data['results'] as List).map<Map<String, String>>((dynamic user) {
            return {
              "name": "${user['name']['first']} ${user['name']['last']}",
              "username": user['login']['username'], // Nombre de usuario
              "image": user['picture']['medium'], // URL de la imagen
            };
          }).toList();
        });
      } else {
        throw Exception('Failed to load friends');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void toggleSelection(Map<String, String> friend) {
    setState(() {
      if (selectedFriends.contains(friend)) {
        selectedFriends.remove(friend);
      } else {
        if (selectedFriends.length < 5) {
          selectedFriends.add(friend);
        } else {
          // Si ya hay 5 amigos seleccionados, muestra el mensaje
          showMessage = true;
          //  ocultar el mensaje después de 4 segundos
          _timer?.cancel();
          _timer = Timer(Duration(seconds: 4), () {
            setState(() {
              showMessage = false; // Oculta el mensaje
            });
          });
        }
      }
    });
  }

  List<Map<String, String>> get filteredFriends {
    if (searchController.text.isEmpty || searchController.text.startsWith('@')) {
      return friends;
    }
    return friends.where((friend) {
      return friend['name']!.toLowerCase().contains(searchController.text.toLowerCase()) ||
          friend['username']!.toLowerCase().contains(searchController.text.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final background = darkModeProvider.backgroundColor;

    return Material(
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          color: background,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Encabezado con el botón de añadir
            Container(
              padding: EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios_new, color: iconColor),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Text(
                        'Etiquetar Amigos',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      padding: EdgeInsets.symmetric(horizontal: 27.0, vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.white, width: 1.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Añadir',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Barra de búsqueda
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13.0, vertical: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 37,
                      child: TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {});
                        },
                        style: TextStyle(color: textColor, fontSize: 14),
                        cursorColor: Colors.cyan,
                        decoration: InputDecoration(
                          hintText: 'Buscar amigos...',
                          hintStyle: TextStyle(color: textColor, fontSize: 14),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.5), // Borde gris claro
                              width: 1.5, // Ancho del borde
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.cyan, width: 1.5),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            color: iconColor,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),

                  if (searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        searchController.clear();
                        setState(() {});
                      },
                      child: Container(
                        margin: EdgeInsets.only(left: 8.0),
                        padding: EdgeInsets.all(3.0),
                        decoration: BoxDecoration(
                          color: Colors.pink,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Lista de amigos
            Expanded(
              child: ListView.builder(
                itemCount: filteredFriends.length,
                itemBuilder: (context, index) {
                  final friend = filteredFriends[index];
                  final isSelected = selectedFriends.contains(friend);
                  return SizedBox(
                    height: 58,
                    child: ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 12),
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: background,
                          border: Border.all(
                            color: Colors.grey.withOpacity(0.5),
                            width: 0.3, // Grosor del borde
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 23, // Tamaño del avatar
                          backgroundImage: NetworkImage(friend["image"]!),
                        ),
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min, // Reduce el espacio entre los elementos
                        children: [
                          Text(
                            friend["name"]!,
                            style: TextStyle(color: textColor, fontSize: 15, fontWeight: FontWeight.w500),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 1.0), // Ajusta la separación al mínimo
                            child: Text(
                              friend["username"]!,
                              style: TextStyle(color: textColor, fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          isSelected ? Icons.remove_circle : Icons.add_circle,
                          color: isSelected ? Colors.red : Colors.cyan,
                        ),
                        onPressed: () {
                          toggleSelection(friend);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            // Mensaje de advertencia sobre el límite de amigos
            if (showMessage)
              Positioned(
                top: 20, // Ajusta la posición según sea necesario
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[700]?.withOpacity(0.8), // Fondo gris con opacidad
                    borderRadius: BorderRadius.circular(8), // Bordes redondeados
                  ),
                  padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0), // Padding interno
                  child: Text(
                    "Solo se permiten etiquetar como máximo 5 amigos.",
                    style: TextStyle(
                      color: Colors.white, // Letra blanca
                      fontSize: 12, // Tamaño de letra pequeña
                      fontWeight: FontWeight.bold, // Texto en negrita
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

            // Carrusel de amigos seleccionados
            if (selectedFriends.isNotEmpty)
              Container(
                height: 100,
                color: isDarkMode ? Color.fromRGBO(79, 78, 78, 0.5) : Colors.grey[300],
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: selectedFriends.length,
                  itemBuilder: (context, index) {
                    final selectedFriend = selectedFriends[index];
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(selectedFriend["image"]!),
                            radius: 30,
                          ),
                          SizedBox(height: 4),
                          SizedBox(
                            width: 65,
                            child: Text(
                              selectedFriend["name"]!,
                              style: TextStyle(color: textColor, fontSize: 12),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1, // Limita a una línea
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancela el temporizador al eliminar el widget
    super.dispose();
  }
}
