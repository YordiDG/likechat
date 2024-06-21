import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FriendsScreen extends StatefulWidget {
  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  List<dynamic> friends = [];
  List<dynamic> friendSuggestions = [];

  @override
  void initState() {
    super.initState();
    fetchFriends();
    fetchFriendSuggestions();
  }

  Future<void> fetchFriends() async {
    final response = await http.get(Uri.parse('http://192.168.0.10:8088/api/v1/auth/authenticate/all-users'));

    if (response.statusCode == 200) {
      setState(() {
        friends = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load friends');
    }
  }

  Future<void> fetchFriendSuggestions() async {
    final response = await http.get(Uri.parse('http://192.168.0.10:8088/api/friends/suggestions'));

    if (response.statusCode == 200) {
      setState(() {
        friendSuggestions = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load friend suggestions');
    }
  }

  void sendFriendRequest(String userId) async {
    final response = await http.post(
      Uri.parse('http://192.168.0.10:8088/api/friends/auth/friendships/{friendId}/follow'),
      body: {
        'userId': userId,
        // Puedes enviar otros datos necesarios para enviar la solicitud de amistad
      },
    );

    if (response.statusCode == 200) {
      // Actualizar la lista de sugerencias de amigos después de enviar la solicitud
      fetchFriendSuggestions();
    } else {
      throw Exception('Failed to send friend request');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friends'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Lógica para la barra de búsqueda
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Suggestions',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            // Sección de sugerencias de amigos recomendadas
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: friendSuggestions.length,
                itemBuilder: (context, index) {
                  var friend = friendSuggestions[index];
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(friend['photo']),
                        ),
                        SizedBox(height: 8),
                        Text(friend['name']),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            sendFriendRequest(friend['id'].toString());
                          },
                          child: Text('Add Friend'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Your Friends',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            // Sección de amigos actuales
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: friends.length,
              itemBuilder: (context, index) {
                var friend = friends[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(friend['photo']),
                  ),
                  title: Text(friend['name']),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // Lógica para eliminar amigo
                    },
                    child: Text('Remove'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
