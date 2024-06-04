import 'package:flutter/material.dart';
import 'app/camera/UserAvatar.dart';
import 'app/storys/LikeChatScreen.dart';import 'package:video_player/video_player.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';


void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            'LikeChat',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFD9F103),
            ),
          ),
          backgroundColor: Color(0xFF0D0D55),
          actions: [
            IconButton(
              icon: Icon(Icons.search, color: Colors.white),
              onPressed: () {
                // Acción de búsqueda
              },
            ),
            PopupMenuButton(
              itemBuilder: (BuildContext context) => [
                PopupMenuItem(
                  child: Text('Settings'),
                  value: 'settings',
                ),
                PopupMenuItem(
                  child: Text('Logout'),
                  value: 'logout',
                ),
              ],
              onSelected: (value) {
                // Manejar acciones del menú
              },
            ),
          ],
        ),
        body: HomeScreen(), // Solo muestra el contenido principal en el cuerpo del Scaffold
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;

  static List<Widget> _widgetOptions = <Widget>[
    ChatsScreen(),
    ShortVideosScreen(),
    FriendsScreen(),
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
        color: Color(0xFF5D3FD3), // Púrpura oscuro
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.video_collection_rounded),
              label: 'Short Videos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.group),
              label: 'Amigos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications),
              label: 'Notificaciones',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Perfil',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Color(0xFFD9F103),
          unselectedItemColor: Colors.white,
          backgroundColor: Color(0xFF0D0D55), // Púrpura oscuro
          onTap: _onItemTapped,
        ),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        onPressed: () {
          // Abrir nueva pantalla de chat
        },
        child: Icon(Icons.message, color: Colors.white),
        backgroundColor: Color(0xFF0D0D55), // Púrpura oscuro
      )
          : null,
    );
  }
}


class ChatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 10, // Example chat count
      itemBuilder: (context, index) {
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Color(0xFFCDDC39), // Verde lima
            child: Text(
              'A', // Example avatar
              style: TextStyle(color: Color(0xFF5D3FD3)), // Púrpura oscuro
            ),
          ),
          title: Text('Contact $index'),
          subtitle: Text('Last message'),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      ChatScreen(chatTitle: 'Contact $index')),
            );
          },
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final bool isRead;
  final DateTime time;

  const MessageBubble({
    required this.message,
    required this.isMe,
    required this.isRead,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(color: isMe ? Colors.white : Colors.black),
            ),
            SizedBox(height: 4.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: isMe ? Colors.white70 : Colors.black54,
                    fontSize: 12.0,
                  ),
                ),
                if (isMe)
                  Icon(
                    isRead ? Icons.done_all : Icons.done,
                    color: isRead ? Colors.blue : Colors.grey,
                    size: 16.0,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String chatTitle;

  const ChatScreen({Key? key, required this.chatTitle}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<String> _messages = [];

  void _sendMessage(String message) {
    setState(() {
      _messages.add(message);
    });
    _textController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0D0D55),
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFFD9F103),
              child: Text(
                widget.chatTitle[0],
                style: TextStyle(color: Colors.black),
              ),
            ),
            SizedBox(width: 8),
            Text(widget.chatTitle),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return MessageBubble(
                  message: _messages[index],
                  isMe: index % 2 == 0,
                  isRead: true, // Change as needed
                  time: DateTime.now(), // Change to DateTime.now()
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(4.0),
            color: Color(0xFF0D0D55),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.insert_emoticon),
                  color: Colors.white,
                  onPressed: () {
                    // Open emoji selector
                  },
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    constraints: BoxConstraints(maxHeight: 60),
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      style: TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey[400]),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 1),
                IconButton(
                  icon: Icon(Icons.send),
                  color: Color(0xFFD9F103),
                  onPressed: () {
                    String message = _textController.text;
                    if (message.isNotEmpty) {
                      _sendMessage(message);
                    }
                  },
                ),
                SizedBox(width: 2),
                IconButton(
                  icon: Icon(Icons.attach_file),
                  color: Color(0xFFD9F103),
                  onPressed: () {
                    // Open file attachment options
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class ShortVideosScreen extends StatefulWidget {
  @override
  _ShortVideosScreenState createState() => _ShortVideosScreenState();
}

class _ShortVideosScreenState extends State<ShortVideosScreen> {
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemPositionsListener itemPositionsListener =
  ItemPositionsListener.create();

  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  int _likes = 0;
  int _comments = 0;
  int _videoDuration = 0;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(
      'https://www.tiktok.com/@jas_jas33/video/7275047420218690848?is_from_webapp=1&sender_device=pc',
    );

    _initializeVideoPlayerFuture = _controller.initialize();

    _controller.setLooping(true);
    _controller.play();
    _controller.addListener(() {
      setState(() {
        _videoDuration = _controller.value.duration.inSeconds;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                GestureDetector(
                  onTap: () {
                    if (_controller.value.isPlaying) {
                      _controller.pause();
                    } else {
                      _controller.play();
                    }
                  },
                  child: AspectRatio(
                    aspectRatio: _controller.value.aspectRatio,
                    child: VideoPlayer(_controller),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.40,
                  right: 32.0,
                  bottom: 9.0,
                  child: UserAvatar(),
                ),
                Positioned(
                  top: MediaQuery.of(context).size.height * 0.46,
                  bottom: 8.0,
                  right: 16.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.favorite_border, color: Colors.white, size: 30.0),
                            onPressed: () {
                              setState(() {
                                _likes++;
                              });
                            },
                          ),
                          Text(
                            '$_likes',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.0), // Ajuste del espacio entre los iconos
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.comment, color: Colors.white, size: 30.0),
                            onPressed: () {
                              setState(() {
                                _comments++;
                              });
                            },
                          ),
                          Text(
                            '$_comments',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.0), // Ajuste del espacio entre los iconos
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_offer, color: Colors.white, size: 30.0),
                          SizedBox(width: 4.0),
                        ],
                      ),
                      SizedBox(height: 12.0), // Ajuste del espacio entre los iconos
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Icon(Icons.share, color: Colors.white, size: 30.0),
                            onPressed: () {
                              // Acción al presionar el botón de "Compartir"
                            },
                          ),
                          Text(
                            'Share',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Positioned(
                  bottom: MediaQuery.of(context).size.height * 0.0,
                  left: MediaQuery.of(context).size.width / 2 - 28.0,
                  child: FloatingActionButton(
                    onPressed: _pickVideo,
                    child: Icon(Icons.video_library),
                  ),
                ),
              ],
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery, maxDuration: Duration(seconds: 20));
    if (pickedFile != null) {
      _controller = VideoPlayerController.file(File(pickedFile.path));

      setState(() {
        _initializeVideoPlayerFuture = _controller.initialize();
      });

      _controller.setLooping(true);
      _controller.play();
      _controller.addListener(() {
        setState(() {
          _videoDuration = _controller.value.duration.inSeconds;
        });
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}


class FriendsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Icon(Icons.person_add, color: Colors.white),
          ),
          title: Text('Friend Suggestion 1'),
          trailing: ElevatedButton(
            onPressed: () {},
            child: Text('Add Friend'),
          ),
        ),
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blue,
            child: Icon(Icons.person_add, color: Colors.white),
          ),
          title: Text('Friend Suggestion 2'),
          trailing: ElevatedButton(
            onPressed: () {},
            child: Text('Add Friend'),
          ),
        ),
        Divider(),
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green,
            child: Text('F'),
          ),
          title: Text('Friend 1'),
        ),
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green,
            child: Text('F'),
          ),
          title: Text('Friend 2'),
        ),
        ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green,
            child: Text('F'),
          ),
          title: Text('Friend 3'),
        ),
      ],
    );
  }
}

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          leading: Icon(Icons.person, color: Colors.purple),
          title: Text('Friend request accepted'),
        ),
        ListTile(
          leading: Icon(Icons.thumb_up, color: Colors.purple),
          title: Text('Someone liked your post'),
        ),
        ListTile(
          leading: Icon(Icons.comment, color: Colors.purple),
          title: Text('New comment on your post'),
        ),
        ListTile(
          leading: Icon(Icons.group_add, color: Colors.purple),
          title: Text('New friend suggestion'),
        ),
      ],
    );
  }
}

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Profile Screen'),
    );
  }
}
