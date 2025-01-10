import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:provider/provider.dart';
import '../../../../../../../Globales/estadoDark-White/DarkModeProvider.dart';
import '../../../../../../../Globales/estadoDark-White/Fuentes/FontSizeProvider.dart';

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

  double _modalHeightFactor = 0.7; // Altura inicial: mitad de la pantalla

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

  void toggleSelection(Map<String, String> friend, {bool isRemove = false}) {
    setState(() {
      if (isRemove) {
        // Elimina solo si la acción proviene del ícono de menos
        selectedFriends.remove(friend);
      } else {
        // Agrega si no está ya seleccionado
        if (!selectedFriends.contains(friend)) {
          if (selectedFriends.length < 5) {
            selectedFriends.add(friend);
          } else {
            // Muestra el mensaje si se superan los 5 amigos
            showMessage = true;
            _timer?.cancel();
            _timer = Timer(Duration(seconds: 4), () {
              setState(() {
                showMessage = false;
              });
            });
          }
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


  void _expandModal() {
    setState(() {
      _modalHeightFactor = _modalHeightFactor == 0.7 ? 0.8 : 0.7;
    });
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final background = darkModeProvider.backgroundColor;

    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return DraggableScrollableSheet(
      initialChildSize: _modalHeightFactor, // Altura inicial
      minChildSize: 0.7, // Altura mínima (50% de la pantalla)
      maxChildSize: 0.8, // Altura máxima (75% de la pantalla)
      expand: false,
      builder: (context, scrollController) {
        return Material(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade300,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                // Barra de encabezado con botón de expansión
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back_ios_new,size: 20, color: iconColor),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          Text(
                            'Etiquetar Amigos',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
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
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Añadir',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: fontSizeProvider.fontSize,
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
                        child: SizedBox(
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
                              hintStyle: TextStyle(color: textColor, fontSize: 12),
                              filled: true,
                              fillColor: Colors.transparent,
                              contentPadding:
                              EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: Colors.grey.withOpacity(0.5),
                                  width: 1.5,
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
                              color: Colors.grey.shade500,
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
                    controller: scrollController,
                    itemCount: filteredFriends.length,
                    itemBuilder: (context, index) {
                      final friend = filteredFriends[index];
                      final isSelected = selectedFriends.contains(friend);

                      return GestureDetector(
                        onTap: () {
                          toggleSelection(friend); // Agrega al tocar cualquier parte de la fila
                        },
                        child: SizedBox(
                          height: 58,
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(vertical: 2.0, horizontal: 12),
                            leading: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 0.5,
                                ),
                              ),
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(friend["image"]!),
                                radius: 24,
                              ),
                            ),
                            title: Text(
                              friend["name"]!,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              friend["username"]!,
                              style: TextStyle(color: textColor, fontSize: 11),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                isSelected ? Icons.remove_circle : Icons.add_circle,
                                color: isSelected ? Colors.red : Colors.cyan,
                              ),
                              onPressed: () {
                                if (isSelected) {
                                  toggleSelection(friend, isRemove: true); // Solo elimina al tocar el ícono
                                }
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Mensaje de advertencia sobre el límite de amigos
                _messageOfLimit(showMessage),

                // Carrusel de amigos seleccionados
                if (selectedFriends.isNotEmpty)
                  Container(
                    height: 120,
                    color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: selectedFriends.length,
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      itemBuilder: (context, index) {
                        final selectedFriend = selectedFriends[index];
                        return Container(
                          width: 80,
                          margin: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: NetworkImage(selectedFriend["image"]!),
                                    radius: 30,
                                  ),
                                  Positioned(
                                    right: 1,
                                    top: 2,
                                    child: GestureDetector(
                                      onTap: () => toggleSelection(selectedFriend, isRemove: true),
                                      child: Container(
                                        padding: EdgeInsets.all(1),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.4),
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12,
                                              spreadRadius: 1,
                                              blurRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: Icon(Icons.close, size: 14, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 4),
                              Expanded(
                                child: Text(
                                  selectedFriend["name"]!,
                                  style: TextStyle(
                                    color: textColor,
                                    fontSize: 10,
                                    height: 1.2, fontWeight: FontWeight.w500
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
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
      },
    );
  }

  Widget _messageOfLimit(bool showMessage) {
    if (showMessage) {
      Fluttertoast.showToast(
        msg: "Máximo 5 amigos permitidos",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM, // Posición del toast
        backgroundColor: Colors.grey.shade900,
        textColor: Colors.white,
        fontSize: 11.0,
      );
    }
    return SizedBox.shrink(); // Retorna un widget vacío si no hay mensaje
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancela el temporizador al eliminar el widget
    super.dispose();
  }
}
