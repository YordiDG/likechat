import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:permission_handler/permission_handler.dart';

import 'mesaage/MessageBubble.dart'; // Importa el paquete de permisos

class ChatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF232323),
      body: ListView.builder(
        padding: EdgeInsets.zero, // Elimina el padding superior
        itemCount: 10, // Ejemplo de cantidad de chats
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Color(0xFF25D366), // Verde WhatsApp
              child: Text(
                'A', // Ejemplo de avatar
                style: TextStyle(color: Colors.white),
              ),
            ),
            title:
                Text('Contacto $index', style: TextStyle(color: Colors.white)),
            subtitle: Text('Último mensaje',
                style: TextStyle(color: Colors.grey[500])),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ChatScreen(chatTitle: 'Contacto $index'),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Solicitar permiso de acceso a los contactos
          var status = await Permission.contacts.request();
          if (status.isGranted) {
            // Abrir pantalla para seleccionar amigos de la app
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SelectContactsScreen(),
              ),
            );
          } else {
            // Permiso denegado
            // Mostrar mensaje de que se requieren permisos de contactos
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Se requiere permiso para acceder a los contactos.'),
              ),
            );
          }
        },
        child: Icon(Icons.message, color: Colors.white),
        backgroundColor: Color(0xFF25D366), // Verde WhatsApp
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.endFloat, // Ajuste hacia arriba
    );
  }
}

// Pantalla para seleccionar amigos de la app
class SelectContactsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Lista de contactos simulada
    List<String> appContacts = [
      'Amigo 1',
      'Amigo 2',
      'Amigo 3',
      'Amigo 4',
      'Amigo 5',
      'Amigo 6',
      'Amigo 7',
      'Amigo 8',
      'Amigo 9',
      'Amigo 10',
      'Amigo 11',
      'Amigo 12',
      'Amigo 13',
      'Amigo 14',
      'Amigo 15',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de amigos', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Navegación de regreso
          },
        ),
      ),
      backgroundColor: Color(0xFF232323),
      body: ListView.builder(
        itemCount: appContacts.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ChatScreen(chatTitle: appContacts[index]),
                    ),
                  );
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 9.0),
                  padding: EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Color(0xFF1F1F1F),
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Color(0xFF25D366), // Verde WhatsApp
                        child: Text(
                          'A', // Iniciales o icono de amigo
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      SizedBox(width: 12.0),
                      Expanded(
                        child: Text(
                          appContacts[index],
                          style: TextStyle(color: Colors.white, fontSize: 18.0),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue, // Color profesional
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.0, vertical: 4.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Chatear',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600),
                            ),
                            Icon(Icons.chevron_right, color: Colors.white),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (index < appContacts.length - 1)
                Divider(color: Colors.grey[850], height: 1.0),
            ],
          );
        },
      ),
    );
  }
}

// Pantalla de chat
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
    socket = IO.io(
        'http://emulator-5556:3000',
        IO.OptionBuilder().setTransports(['websocket']) // Solo usar WebSocket
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
        backgroundColor: Color(0xFF1F1F1F),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.greenAccent,
                  width: 2.0,
                ),
              ),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFF25D366),
                child: Text(
                  widget.chatTitle[0],
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
            SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chatTitle,
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  'Activo ahora',
                  // Puedes personalizar este texto según tu lógica
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.videocam, color: Colors.white),
            onPressed: () {
              // Acción para llamar por videollamada
            },
          ),
          IconButton(
            icon: Icon(Icons.phone, color: Colors.white),
            onPressed: () {
              // Acción para llamar por voz
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              // Mostrar más opciones del chat
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
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
                color: Color(0xFF1F1F1F),
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        constraints: BoxConstraints(maxHeight: 100),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.blue,
                              ),
                              child: IconButton(
                                icon: Icon(Icons.camera_alt),
                                color: Colors.white,
                                onPressed: () {
                                  // Acción para abrir la cámara
                                },
                              ),
                            ),
                            Expanded(
                              child: TextField(
                                controller: _textController,
                                maxLines: null,
                                style: TextStyle(color: Colors.black),
                                decoration: InputDecoration(
                                  hintText: 'Mensaje...',
                                  border: InputBorder.none,
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                  contentPadding:
                                      EdgeInsets.symmetric(vertical: 10),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.attach_file),
                              color: Colors.black,
                              onPressed: () {
                                // Abrir opciones de adjuntar archivos
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.send),
                              color: Colors.black,
                              onPressed: () {
                                String message = _textController.text;
                                if (message.isNotEmpty) {
                                  _sendMessage(message);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 20, // Ajusta esta posición según sea necesario
            left: 0,
            right: 0,
            child: Container(
              height: 100, // Ajusta la altura del contenedor según sea necesario
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildIconWithTitle(Icons.favorite, Colors.red, "Me gusta"),
                  _buildIconWithTitle(Icons.sentiment_satisfied, Colors.yellowAccent, "Feliz"),
                  _buildIconWithTitle(Icons.favorite_border, Colors.green, "Favorito"),
                  _buildIconWithTitle(Icons.sticky_note_2, Colors.lightBlue, "Nota"),
                  _buildIconWithTitle(Icons.favorite, Colors.red, "Me gusta"),
                  _buildIconWithTitle(Icons.sentiment_satisfied, Colors.yellowAccent, "Feliz"),
                  _buildIconWithTitle(Icons.favorite_border, Colors.green, "Favorito"),
                  _buildIconWithTitle(Icons.sticky_note_2, Colors.lightBlue, "Nota"),
                  // Agrega más íconos según sea necesario
                ],
              ),
            ),
          ),

        ],
      ),
    );
  }

  Widget _buildIconWithTitle(IconData icon, Color iconColor, String title) {
    return Container(
      width: 90, // Ancho del contenedor
      margin: EdgeInsets.symmetric(horizontal: 4), // Espacio entre íconos
      child: Column(
        children: [
          Container(
            height: 35,
            width: 77,// Altura del contenedor del ícono
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(10), // Bordes redondeados
              color: Colors.grey[200], // Color de fondo gris
            ),
            child: IconButton(
              icon: Icon(icon, color: iconColor),
              onPressed: () {
                // Acción al presionar el ícono
              },
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.black), // Estilo del texto del título
          ),
        ],
      ),
    );
  }

}
