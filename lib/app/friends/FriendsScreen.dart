import 'package:flutter/material.dart';

import 'list Amigos/FollowersScreen.dart';


class FriendsScreen extends StatefulWidget {
  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {

  final List<Map<String, String>> friendSuggestions = [
    {
      'id': '1',
      'name': 'Sugerencia 1',
      'photo': 'https://example.com/photo1.jpg'
    },
    {
      'id': '2',
      'name': 'Sugerencia 2',
      'photo': 'https://example.com/photo2.jpg'
    },
    // Agrega más sugerencias aquí
  ];

  final Map<String, bool> followStatus = {};

  @override
  void initState() {
    super.initState();
    for (var suggestion in friendSuggestions) {
      if (suggestion['id'] != null) {
        followStatus[suggestion['id']!] = false; // Todos empiezan sin seguir
      }
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

  bool isFollowing(String friendId) {
    // Lógica para verificar si está siguiendo
    return true; // Ejemplo: siempre devuelve true
  }

  bool followsYou(String friendId) {
    // Lógica para verificar si te sigue
    return true; // Ejemplo: siempre devuelve true
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Amigos', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: IconButton(
              icon: Icon(Icons.group_add, size: 27, color: Colors.white),
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
      body: Container(
        color: Colors.black, // Background color for the entire container
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Container(
                            height: 43,
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Buscar',
                                hintStyle: TextStyle(
                                    color: Colors.white, fontSize: 15),
                                prefixIcon: Icon(Icons.search,
                                    color: Colors.white, size: 21),
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      height: 23,
                                      child: VerticalDivider(
                                        color: Colors.grey,
                                        thickness: 1,
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Lógica para el botón de búsqueda
                                      },
                                      child: Text('Buscar',
                                          style: TextStyle(
                                              color: Colors.pinkAccent,
                                              fontSize: 12)),
                                      style: TextButton.styleFrom(
                                        padding:
                                            EdgeInsets.symmetric(vertical: 2),
                                      ),
                                    ),
                                  ],
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: BorderSide(color: Colors.grey),
                                ),
                                filled: true,
                                fillColor: Colors.transparent,
                                contentPadding: EdgeInsets.symmetric(
                                    vertical: 5.0, horizontal: 10.0),
                              ),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(
                                'https://example.com/your_photo.jpg'),
                          ),
                          SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Juan V.',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Spacer(),
                          Row(
                            children: [
                              SizedBox(
                                height: 30,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.grey[600],
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8),
                                  ),
                                  onPressed: () {
                                    // Lógica para cancelar
                                  },
                                  child: Text('Cancelar',
                                      style: TextStyle(fontSize: 12,  color: Colors.white)),
                                ),
                              ),
                              SizedBox(width: 8),
                              SizedBox(
                                height: 30,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.pink,
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 8),
                                  ),
                                  onPressed: () {
                                    // Lógica para seguir
                                  },
                                  child: Text('Seguir',
                                      style: TextStyle(fontSize: 12, color: Colors.white)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Sugerencias de amigos',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4.0,
                        mainAxisSpacing: 4.0,
                      ),
                      itemCount: friendSuggestions.length,
                      itemBuilder: (context, index) {
                        var suggestion = friendSuggestions[index];

                        return GridTile(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: EdgeInsets.all(8),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundImage: NetworkImage(suggestion['photo'] ?? ''),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  suggestion['name'] ?? '',
                                  style: TextStyle(color: Colors.white),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 5),
                                Expanded(
                                  child: SizedBox(
                                    height: 30,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: followStatus[suggestion['id']] == true ? Colors.transparent : Colors.pink,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5),
                                          side: followStatus[suggestion['id']] == true
                                              ? BorderSide(color: Colors.grey, width: 1.5)
                                              : BorderSide.none,
                                        ),
                                        padding: EdgeInsets.symmetric(horizontal: 8),
                                      ),
                                      onPressed: () {
                                        if (suggestion['id'] != null) {
                                          toggleFollow(suggestion['id']!);
                                        }
                                      },
                                      child: Text(
                                        followStatus[suggestion['id']] == true ? 'Dejar de seguir' : 'Seguir',
                                        style: TextStyle(fontSize: 12, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

