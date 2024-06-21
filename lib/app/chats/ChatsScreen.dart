import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

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
  late IO.Socket socket;

  @override
  void initState() {
    super.initState();
    // Conectar al servidor de Socket.IO
    socket = IO.io('http://emulator-5556:3000', IO.OptionBuilder()
        .setTransports(['websocket']) // Solo usar WebSocket
        .build());

    // Escuchar el evento de conexión
    socket.onConnect((_) {
      print('Conectado al servidor de sockets');
    });

    // Escuchar mensajes entrantes
    socket.on('message', (data) {
      setState(() {
        _messages.add(data);
      });
    });

    // Conectar al servidor
    socket.connect();
  }

  @override
  void dispose() {
    // Desconectar del servidor de Socket.IO
    socket.disconnect();
    super.dispose();
  }

  void _sendMessage(String message) {
    // Enviar el mensaje al servidor
    socket.emit('message', message);
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
                  isRead: true,
                  time: DateTime.now(),
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
                    // Abrir selector de emojis
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
                    // Abrir opciones de adjuntar archivos
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
