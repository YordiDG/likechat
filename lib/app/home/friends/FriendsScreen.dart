import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Globales/estadoDark-White/DarkModeProvider.dart';
import 'list Amigos/FollowersScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FriendsScreen extends StatefulWidget {
  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  bool isFollowing = false; // Si está siguiendo al usuario
  bool isVisible = true;

  bool _isExpanded = true;

  final Map<String, bool> followStatus = {};

  final List<Map<String, String>> friendSuggestions = [
    {
      'id': '1',
      'name': 'Shakira 🔰',
      'followers': '1 mill.',
      'photo':
          'https://aws-modapedia.vogue.es/prod/designs/v1/assets/640x853/2107.jpg'
    },
    {
      'id': '2',
      'name': 'Luis Miguel Sanches Vasques🔰',
      'followers': '390 mil',
      'photo':
          'https://luismigueloficial.com/themes/lm/assets/images/1990_s_2_mov.jpg'
    },
    {
      'id': '3',
      'name': 'Karla Valencia🔰',
      'followers': '450 mil',
      'photo':
          'https://i.pinimg.com/originals/fc/41/4e/fc414e7865671a12c2bc48bca6f853f8.jpg'
    },
    {
      'id': '4',
      'name': 'Ms. Beast🔰',
      'followers': '968 mil',
      'photo':
          'https://phantom-marca.unidadeditorial.es/e1f833f26f1aa2b4bf939023aa647318/resize/828/f/jpg/assets/multimedia/imagenes/2023/09/29/16960062923732.jpg'
    },
    {
      'id': '5',
      'name': 'Juan Salas🔰',
      'followers': '2,7 mill.',
      'photo':
          'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRrFy-8v9FKczW9fVVumfld08w34E-chItXwg&s'
    },
    {
      'id': '6',
      'name': 'Luis fonsi🔰',
      'followers': '3,1 mill.',
      'photo':
          'https://i.scdn.co/image/ab67616d0000b273ef0d4234e1a645740f77d59c'
    },
  ];

  List<Map<String, dynamic>> friends = [];
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();
    for (var suggestion in friendSuggestions) {
      if (suggestion['id'] != null) {
        followStatus[suggestion['id']!] = false;
      }
    }
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
              .map<Map<String, dynamic>>((dynamic user) {
            return {
              "name": "${user['name']['first']} ${user['name']['last']}",
              "username": user['login']['username'],
              "photoUrl": user['picture']['medium'],
              "id": user['login']['uuid'],
              "followers": (user['dob']['age'] * 10).toString(),
              // Mock followers count
              "isFollowing": false,
              // Initial follow state
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

  void toggleFollow(String friendId) {
    setState(() {
      if (followStatus[friendId] != null) {
        followStatus[friendId] = !followStatus[friendId]!;
        print('Estado cambiado para $friendId: ${followStatus[friendId]}');
      }
    });
  }

  void sendFriendRequest(String friendId) {
    // Lógica para enviar solicitud de amistad
  }

  void cancelFriendRequest(String friendId) {
    // Lógica para cancelar solicitud de amistad
  }

  bool isFollowingF(String friendId) {
    // Lógica para verificar si está siguiendo
    return true; // Ejemplo: siempre devuelve true
  }

  bool followsYou(String friendId) {
    // Lógica para verificar si te sigue
    return true; // Ejemplo: siempre devuelve true
  }


  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final backgroundColor = darkModeProvider.backgroundColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(
          'Amigos',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              icon: Icon(
                Icons.group_add,
                size: 27,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FollowersScreen()),
                );
              },
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSearchField(context, isDarkMode),

                // Más Populares Section
                _buildPopularSection(constraints, isDarkMode),

                SizedBox(height: 18),
                Container(
                  margin: EdgeInsets.only(left: 5.0),
                  padding: EdgeInsets.all(10.0),
                  child: Text(
                    'Sugerencias de Amistad',
                    style: TextStyle(
                      fontWeight: FontWeight.bold, // Texto en negrita
                    ),
                  ),
                ),

                // Sugerencias de Amistad Section
                buildFriendList(friends, isDarkMode),
              ],
            ),
          );
        },
      ),
    );
  }

  InputDecoration customDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.cyan),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.cyan),
        borderRadius: BorderRadius.circular(10.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.cyan),
        borderRadius: BorderRadius.circular(10.0),
      ),
    );
  }

  //metodo de search
  Widget buildSearchField(BuildContext context, bool isDarkMode) {
    return Theme(
      data: Theme.of(context).copyWith(
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: Colors.cyan, // Color del cursor
          selectionColor: Colors.cyan.withOpacity(0.3), // Color de selección
          selectionHandleColor: Colors.cyan, // Controlador de selección
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            SizedBox(
              height: 38,
              child: TextField(
                cursorColor: Colors.cyan, // Confirmación del color del cursor
                decoration: InputDecoration(
                  hintText: 'Buscar amigos',
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 12,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: isDarkMode ? Colors.white : Colors.black,
                    size: 21,
                  ),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 23,
                        child: VerticalDivider(
                          color: Colors.grey.shade400,
                          thickness: 1,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Lógica para el botón de búsqueda
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 2),
                        ),
                        child: Text(
                          'Buscar',
                          style: TextStyle(color: Colors.cyan, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
                ),
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //populares
  Widget _buildPopularSection(BoxConstraints constraints, bool isDarkMode) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final backgroundColor = darkModeProvider.backgroundColor;
    final textColor = darkModeProvider.textColor;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Más Populares',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                  SizedBox(width: 7),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDarkMode
                            ? Colors.grey.shade800.withOpacity(0.8)
                            : Colors.grey.shade200.withOpacity(0.8),
                        shape: BoxShape.circle,
                      ),
                      padding: EdgeInsets.all(3),
                      child: Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: isDarkMode ? Colors.white : Colors.cyan,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                height: 28,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade900.withOpacity(0.9) : Colors.grey.shade200.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    foregroundColor: isDarkMode ? Colors.white : Colors.black,
                  ),
                  icon: Icon(Icons.visibility_outlined, size: 14),
                  label: Text(
                    'Ver Más',
                    style: TextStyle(fontSize: 11),
                  ),
                  onPressed: () {
                    // Acción del botón
                  },
                ),
              )
            ],
          ),
        ),
        SizedBox(height: 10), // Margen entre la fila superior y el contenido
        AnimatedSize(
          duration: Duration(milliseconds: 300),
          child: _isExpanded
              ? SizedBox(
            width: MediaQuery.of(context).size.width,
            height: calculateCarouselHeight(constraints),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: friendSuggestions.length,
              itemBuilder: (context, index) {
                return buildPopularUserCard(
                    friendSuggestions[index], constraints, index);
              },
            ),
          )
              : SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget buildPopularUserCard(
      Map<String, dynamic> suggestion,
      BoxConstraints constraints,
      int index, // Índice de la tarjeta
      ) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final backgroundColor = darkModeProvider.backgroundColor;
    final textColor = darkModeProvider.textColor;

    return Container(
      width: calculateCardWidth(constraints),
      height: calculateCarouselHeight(constraints), // Altura fija
      margin: EdgeInsets.only(
        left: index == 0 ? 10 : 1, // Margen izquierdo adicional para la primera tarjeta
        right: 3,
      ),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Centrado vertical
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 35,
                  backgroundImage: suggestion['photo'] != null
                      ? NetworkImage(suggestion['photo'])
                      : null,
                  backgroundColor: Colors.grey[200],
                  child: suggestion['photo'] == null
                      ? Icon(Icons.person, color: Colors.grey)
                      : null,
                ),
                SizedBox(height: 10),
                Text(
                  suggestion['name'] ?? 'Nombre',
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: 5),
                Text(
                  '${suggestion['followers'] ?? '0'} Seguidores',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                SizedBox(height: 10),
                buildFollowButton(suggestion),
              ],
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: GestureDetector(
              onTap: () {
                // Acción para cerrar o eliminar la tarjeta
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                padding: EdgeInsets.all(2),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


// Métodos de cálculo responsivo
  double calculateCardWidth(BoxConstraints constraints) {
    if (constraints.maxWidth > 600) return 200;
    if (constraints.maxWidth > 400) return 170;
    return 140;
  }

  double calculateCarouselHeight(BoxConstraints constraints) {
    if (constraints.maxWidth > 600) return 280;
    if (constraints.maxWidth > 400) return 240;
    return 220;
  }

  Widget buildFollowButton(Map<String, dynamic> suggestion) {
    bool isFollowing = followStatus[suggestion['id']] == true;

    return SizedBox(
      width: 110,
      height: 33,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isFollowing ? Colors.white : Colors.cyan,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
            side: isFollowing
                ? BorderSide(color: Colors.grey.shade300, width: 1.5)
                : BorderSide.none,
          ),
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.symmetric(horizontal: 12),
        ),
        onPressed: () {
          if (suggestion['id'] != null) {
            toggleFollow(suggestion['id']!);
          }
        },
        child: Text(
          isFollowing ? 'Siguiendo' : 'Seguir',
          style: TextStyle(
              fontSize: isFollowing ? 12 : 13,
              color: isFollowing ? Colors.black : Colors.white,
              fontWeight: FontWeight.w600
          ),
        ),
      ),
    );
  }

  //metodo de lista de friends
  Widget buildFriendList(List<Map<String, dynamic>> friends, bool isDarkMode) {
    return SingleChildScrollView(
      child: Column(
        children: friends.map((user) {
          return SizedBox(
            height: 65,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Fondo blanco
                    border: Border.all(
                      color: Colors.grey[300]!,
                      width: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: CircleAvatar(
                    radius: 26,
                    backgroundImage: NetworkImage(
                      user['photoUrl'] ??
                          'https://example.com/default_photo.jpg',
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        user['name'] ?? '',
                        style: TextStyle(
                          fontSize: 15,
                          color: isDarkMode ? Colors.white : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        '${user['followers']} seguidores',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDarkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                SizedBox(
                    height: 30,
                    width: 83,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: user['isFollowing']
                            ? Color(0xFFF2F2F2)
                            : Colors.cyan,
                        // Fondo gris claro cuando no está siguiendo
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          // Bordes redondeados de 8
                          side: BorderSide(
                            color: user['isFollowing']
                                ? Colors.grey
                                : Colors.transparent,
                            // Sin borde cuando no está siguiendo
                            width: 0.6,
                          ),
                        ),
                      ),
                      onPressed: () {
                        setState(() {
                          user['isFollowing'] = !user['isFollowing'];
                        });
                      },
                      child: Center(
                        child: Text(
                          user['isFollowing'] ? 'Siguiendo' : 'Seguir',
                          style: TextStyle(
                            fontSize: 12,
                            color: user['isFollowing']
                                ? Colors.black
                                : Colors.white,
                            // Blanco cuando está siguiendo, negro cuando no
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Roboto', // Fuente bonita
                          ),
                        ),
                      ),
                    )),
                SizedBox(width: 16),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
