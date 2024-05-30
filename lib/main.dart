import 'package:flutter/material.dart';

import 'app/storys/LikeChatScreen.dart';

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
              //color: Colors.white,
            ),
          ),
          backgroundColor: Color(0xFF0D0D55), // Púrpura oscuro
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
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LikeChatScreen(),
            Expanded(
              child: HomeScreen(),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex =
      1; // Establecer 'Short Videos' como la pestaña predeterminada

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
      body: _widgetOptions.elementAt(_selectedIndex),
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
          backgroundColor: Color(0xFF0D0D55),
          // Púrpura oscuro
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



class StatusScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Status Screen'),
    );
  }
}

class CallsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Calls Screen'),
    );
  }
}

class ShortVideosScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Short Videos Screen'),
    );
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
