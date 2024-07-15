import 'package:flutter/material.dart';

class FollowersScreen extends StatefulWidget {
  @override
  _FollowersScreenState createState() => _FollowersScreenState();
}

class _FollowersScreenState extends State<FollowersScreen> {
  final List<Map<String, String>> followers = [
    {
      'id': '1',
      'name': 'Seguidor 1',
      'photo': 'https://example.com/photo1.jpg',
    },
    {
      'id': '2',
      'name': 'Seguidor 2',
      'photo': 'https://example.com/photo2.jpg',
    },
    {
      'id': '3',
      'name': 'Seguidor 3',
      'photo': 'https://example.com/photo2.jpg',
    },  {
      'id': '4',
      'name': 'Seguidor 4',
      'photo': 'https://example.com/photo2.jpg',
    },  {
      'id': '5',
      'name': 'Seguidor 5',
      'photo': 'https://example.com/photo2.jpg',
    },  {
      'id': '6',
      'name': 'Seguidor 6',
      'photo': 'https://example.com/photo2.jpg',
    },  {
      'id': '7',
      'name': 'Seguidor 7',
      'photo': 'https://example.com/photo2.jpg',
    },  {
      'id': '8',
      'name': 'Seguidor 8',
      'photo': 'https://example.com/photo2.jpg',
    },  {
      'id': '9',
      'name': 'Seguidor 9',
      'photo': 'https://example.com/photo2.jpg',
    },
  ];

  final Set<String> following = {}; // Set para rastrear quiénes están seguidos

  void toggleFollow(String followerId) {
    setState(() {
      if (following.contains(followerId)) {
        following.remove(followerId); // Dejar de seguir
      } else {
        following.add(followerId); // Seguir
      }
    });
  }

  void deleteFollower(String followerId) {
    setState(() {
      followers.removeWhere((f) => f['id'] == followerId); // Eliminar seguidor
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seguidores', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navegación de regreso
          },
        ),
      ),
      body: Container(
        color: Colors.black,
        child: ListView.builder(
          itemCount: followers.length,
          itemBuilder: (context, index) {
            var follower = followers[index];
            bool isFollowing = following.contains(follower['id']);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(follower['photo']!),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          follower['name']!,
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                        Text(
                          'Te sigue',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        height: 30,
                        width: 70,
                        child: ElevatedButton(
                          onPressed: () {
                            toggleFollow(follower['id']!);
                          },
                          child: Text(
                            isFollowing ? 'Mensaje' : 'Seguir',
                            style: TextStyle(fontSize: 13, color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFollowing ? Colors.transparent : Colors.pink,
                            padding: EdgeInsets.symmetric(vertical: 5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                              side: isFollowing
                                  ? BorderSide(color: Colors.grey, width: 1.5)
                                  : BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 5),
                      IconButton(
                        icon: Icon(Icons.more_vert, color: Colors.white),
                        onPressed: () {
                          _showOptionsModal(context, follower['id']!);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Configuración',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              SizedBox(height: 10),
              Divider(color: Colors.grey[700]),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  deleteFollower(followerId); // Lógica para eliminar
                  Navigator.pop(context); // Cerrar el modal
                },
                child: Text(
                  'Eliminar',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  minimumSize: Size(double.infinity, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Cerrar el modal
                },
                child: Text(
                  'Cancelar',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[600],
                  padding: EdgeInsets.symmetric(vertical: 12),
                  minimumSize: Size(double.infinity, 36),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
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
