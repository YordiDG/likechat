
import 'package:challengeflutter/storys/LikeChatScreen.dart';
import 'package:flutter/material.dart';


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
              color: Colors.white,
            ),
          ),
          backgroundColor: Color(0xFF5D3FD3), // Púrpura oscuro
          actions: [
            IconButton(
              icon: Icon(Icons.search),
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
  int _selectedIndex = 0;

  static List<Widget> _widgetOptions = <Widget>[
    ChatsScreen(),
    StatusScreen(),
    CallsScreen(),
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
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.chat),
              label: 'Chats',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_alt),
              label: 'Short Videos',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.call),
              label: 'Calls',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey[500], // Verde lima
          backgroundColor: Color(0xFF5D3FD3), // Púrpura oscuro
          onTap: _onItemTapped,
        ),
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
        onPressed: () {
          // Abrir nueva pantalla de chat
        },
        child: Icon(Icons.message),
        backgroundColor: Color(0xFF5D3FD3), // Púrpura oscuro
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
                  builder: (context) => ChatScreen(chatTitle: 'Contact $index')),
            );
          },
        );
      },
    );
  }
}

class ChatScreen extends StatelessWidget {
  final String chatTitle;

  ChatScreen({required this.chatTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Color(0xFFCDDC39), // Verde lima
              child: Text(
                chatTitle[0], // Example avatar
                style: TextStyle(color: Color(0xFF5D3FD3)), // Púrpura oscuro
              ),
            ),
            SizedBox(width: 8),
            Text(chatTitle),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () {
              // Open camera
            },
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // Perform search
            },
          ),
          PopupMenuButton(
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                child: Text('View profile'),
                value: 'view_profile',
              ),
              PopupMenuItem(
                child: Text('Block'),
                value: 'block',
              ),
              PopupMenuItem(
                child: Text('Report'),
                value: 'report',
              ),
            ],
            onSelected: (value) {
              // Handle popup menu actions
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages display
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Example message count
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Message $index'),
                );
              },
            ),
          ),
          // Message input
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.insert_emoticon),
                  onPressed: () {
                    // Open emoji picker
                  },
                ),
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.attach_file),
                  onPressed: () {
                    // Open attachment options
                  },
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    // Send message
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


