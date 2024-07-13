import 'package:contacts_service/contacts_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:permission_handler/permission_handler.dart';
import 'package:lottie/lottie.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';


import 'call/CallScreen.dart';
import 'call/VideoCall.dart';
import 'mesaage/MessageBubble.dart';

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
              backgroundColor: Colors.cyan, // Verde WhatsApp
              child: Text(
                'E', // Ejemplo de avatar
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
                      ChatScreen(chatTitle: 'Contacto $index', contactName: '', phoneNumber: '',),
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
        backgroundColor: Colors.cyan, // Verde WhatsApp
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
                          ChatScreen(chatTitle: appContacts[index], contactName: '', phoneNumber: '',),
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
  final String contactName;
  final String phoneNumber;

  const ChatScreen({Key? key, required this.chatTitle, required this.contactName,required this.phoneNumber}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<dynamic> _messages = [];
  List<Map<String, dynamic>> message = [];
  late IO.Socket socket;
  File? _imageFile;

  FocusNode _focusNode = FocusNode();


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

    _focusNode.dispose();
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

  void _startVoiceCall() {
    String phoneNumber = '+51935400894'; // Reemplaza esto con el número de tu contacto

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallScreen(
          contactName: widget.chatTitle,
          phoneNumber: phoneNumber,
        ),
      ),
    );
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
                border: Border.all(color: Colors.blue, width: 2.0),
              ),
              child: CircleAvatar(
                radius: 16,
                backgroundColor: Colors.cyan,
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoCall(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.phone, color: Colors.white),
            onPressed: _startVoiceCall,
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onSelected: (String value) {
              // Handle menu actions
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(value: 'Ver perfil', child: Text('Ver perfil')),
                PopupMenuItem(value: 'Archivar chat', child: Text('Archivar chat')),
                // Add more menu items here...
              ];
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.black,
        child: Stack(
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
                GestureDetector(
                  onTap: () {
                    if (!_focusNode.hasFocus) {
                      FocusScope.of(context).requestFocus(_focusNode);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SizedBox(width: 1),
                        Expanded(
                          child: Container(
                            constraints: BoxConstraints(maxHeight: 80),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.cyan,
                                    ),
                                    child: IconButton(
                                      iconSize: 20,
                                      icon: Icon(Icons.camera_alt),
                                      color: Colors.white,
                                      onPressed: _openCamera,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        FocusScope.of(context).requestFocus(_focusNode);
                                      },
                                      child: Container(
                                        color: Colors.black,
                                        child: Theme(
                                          data: ThemeData(hintColor: Colors.grey[100]),
                                          child: TextField(
                                            focusNode: _focusNode,
                                            controller: _textController,
                                            maxLines: null,
                                            style: TextStyle(color: Colors.white),
                                            decoration: InputDecoration(
                                              hintText: 'Mensaje...',
                                              hintStyle: TextStyle(color: Colors.grey[100]),
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.symmetric(vertical: 10),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    iconSize: 24,
                                    icon: Icon(Icons.attach_file),
                                    color: Colors.cyan,
                                    onPressed: _showAttachmentOptions, // Abrir el modal
                                  ),
                                  IconButton(
                                    iconSize: 24,
                                    icon: Icon(Icons.send),
                                    color: Colors.cyan,
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
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 17,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildJsonWithTitle('lib/assets/heart.json'),
                    _buildJsonWithTitle('lib/assets/Haja.json'),
                    _buildJsonWithTitle('lib/assets/like.json'),
                    _buildJsonWithTitle('lib/assets/sorpresa.json'),
                    _buildJsonWithTitle('lib/assets/enamo.json'),
                    _buildJsonWithTitle('lib/assets/angry.json'),
                    _buildJsonWithTitle('lib/assets/aplausos.json'),
                    _buildJsonWithTitle('lib/assets/ultima.json'),
                    _buildImageWithTitle('lib/assets/perro.png'), // Displaying image
                    _buildJsonWithTitle('lib/assets/emoticon.json'),
                    _buildJsonWithTitle('lib/assets/emoticon2.json'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[850], // Fondo gris oscuro
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          height: 200,
          child: GridView.count(
            crossAxisCount: 3,
            children: [
              _buildAttachmentOption(Icons.camera_alt, 'Cámara', Colors.green, () {
                _openCamera();
                Navigator.of(context).pop();
              }),
              _buildAttachmentOption(Icons.image, 'Imágenes', Colors.blue, () {
                _openGallery();
                Navigator.of(context).pop();
              }),
              _buildAttachmentOption(Icons.videocam, 'Videos', Colors.orange, () {
                _openVideoPicker();
                Navigator.of(context).pop();
              }),
              _buildAttachmentOption(Icons.insert_drive_file, 'Archivos', Colors.purple, () {
                _openFilePicker();
                Navigator.of(context).pop();
              }),
              _buildAttachmentOption(Icons.contacts, 'Contactos', Colors.red, () {
                _openContacts();
                Navigator.of(context).pop();
              }),
              _buildAttachmentOption(Icons.call, 'Llamadas', Colors.yellow, () {
                _openCallLogs();
                Navigator.of(context).pop();
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttachmentOption(IconData icon, String label, Color color, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            padding: EdgeInsets.all(8),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold, // Texto en negrita
            ),
          ),
        ],
      ),
    );
  }

  void _showContactSelectionDialog(Iterable<Contact> contacts) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[850], // Fondo gris oscuro
          title: Text(
            'Seleccionar Contacto',
            style: TextStyle(color: Colors.white), // Título en blanco
          ),
          content: Container(
            width: double.maxFinite,
            child: ListView(
              children: contacts.map((contact) {
                return ListTile(
                  title: Text(
                    contact.displayName ?? '',
                    style: TextStyle(color: Colors.white), // Texto en blanco
                  ),
                  onTap: () {
                    // Handle contact selection
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancelar',
                style: TextStyle(color: Colors.white), // Texto en blanco
              ),
            ),
          ],
        );
      },
    );
  }

  void _openGallery() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Handle the selected image file
      _addImageToChat(File(pickedFile.path));
    }
  }

  void _openVideoPicker() async {
    final pickedFile = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Handle the selected video file
      _addVideoToChat(File(pickedFile.path));
    }
  }

  void _openFilePicker() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      // Handle the selected file
      _addFileToChat(File(result.files.single.path!));
    }
  }

  void _addFileToChat(File? file) {
    if (file != null) {
      print('Archivo agregado al chat: ${file.path}');

      setState(() {
        _messages.add(ChatMessage(
          type: MessageType.file,
          file: file,
          videoFile: null, // Set to null if not applicable
        ));
      });
    } else {
      print('No se ha seleccionado ningún archivo.');
    }
  }


  void _addVideoToChat(File videoFile) {
    // Lógica para agregar el video al chat
    // Esto podría incluir enviar el video a un servidor, actualizar el estado local, etc.
    print('Video agregado al chat: ${videoFile.path}');

    // Ejemplo de actualización del estado
    setState(() {
      // Agrega el video a la lista de mensajes o algo similar
      _messages.add(ChatMessage(
        type: MessageType.video,
        videoFile: videoFile,
        // Otros parámetros que necesites
      ));
    });
  }

  void _openContacts() async {
    // Pedir permiso de contactos
    var status = await Permission.contacts.request();
    if (status.isGranted) {
      // Si se concede el permiso, obtener contactos
      Iterable<Contact> contacts = await ContactsService.getContacts();
      _showContactSelectionDialog(contacts);
    } else {
      // Manejar el caso en que no se concede el permiso
      _showPermissionDeniedDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Permiso Denegado'),
          content: Text('Por favor, permite el acceso a los contactos en la configuración de la aplicación.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }


  void _openCallLogs() async {
    // Implement logic to access call logs (requires additional permissions)
    // You may need to use a plugin or custom method to access call logs
  }


// Function to build an image widget
  Widget _buildImageWithTitle(String assetPath) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Image.asset(
            assetPath,
            width: 60, // Adjust the size as needed
            height: 60,
          ),
          SizedBox(height: 5),
          Text(
            'Imagen',
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  void _openCamera() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      showDialog(
        context: context,
        barrierColor: Colors.black54,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color(0xFF1F1F1F),
            title: Center(
              child: Text(
                'Previsualización',
                style: TextStyle(color: Colors.white),
              ),
            ),
            content: Container(
              width: 450,
              height: 450,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 450,
                    height: 400,
                    child: Image.file(
                      _imageFile!,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '¿Enviar esta imagen?',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _iconButtonWithLabel(Icons.filter, 'Filtrar'),
                      _iconButtonWithLabel(Icons.text_fields, 'Texto'),
                      _iconButtonWithLabel(Icons.brush, 'Dibujar'),
                      _iconButtonWithLabel(Icons.delete, 'Eliminar', color: Colors.red),
                      _iconButtonWithLabel(
                        Icons.crop,
                        'Recortar',
                        onPressed: () async {
                          try {
                            final croppedFile = await ImageCropper().cropImage(
                              sourcePath: _imageFile!.path,
                              uiSettings: [
                                AndroidUiSettings(
                                  toolbarTitle: 'Recortar Imagen',
                                  toolbarColor: Colors.deepOrange,
                                  toolbarWidgetColor: Colors.white,
                                  initAspectRatio: CropAspectRatioPreset.original,
                                  lockAspectRatio: false,
                                ),
                                IOSUiSettings(
                                  title: 'Recortar Imagen',
                                  minimumAspectRatio: 1.0,
                                ),
                              ],
                            );

                            if (croppedFile != null) {
                              setState(() {
                                _imageFile = File(croppedFile.path); // Actualiza la imagen recortada
                              });
                            }
                          } catch (e) {
                            print("Error durante el recorte: $e");
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error al recortar la imagen.')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _styledTextButton('Cancelar', Colors.white, () {
                        Navigator.of(context).pop();
                      }),
                      _styledTextButton('Enviar', Colors.cyan, () {
                        if (_imageFile != null) {
                          _addImageToChat(_imageFile!);
                          Navigator.of(context).pop();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('No hay imagen para enviar.')),
                          );
                        }
                      }),
                    ],
                  ),
                ],
              ),
            ],
          );
        },
      );
    } else {
      print('No se seleccionó ninguna imagen.');
    }
  }

  Widget _iconButtonWithLabel(IconData icon, String label, {VoidCallback? onPressed, Color? color}) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Color(0xFF494949),
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            icon: Icon(icon, color: color ?? Colors.white),
            onPressed: onPressed,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }

  Widget _iconButton(IconData icon, {VoidCallback? onPressed}) {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }

  Widget _styledTextButton(String label, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
          color: Color(0xFF494949),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextButton(
        child: Text(label, style: TextStyle(color: color)),
        onPressed: onPressed,
      ),
    );
  }


// Method to add the image to the chat
  void _addImageToChat(File imageFile) {
    setState(() {
      message.add({
        'type': 'image',
        'file': imageFile,
      });
    });
  }


  Widget _buildImageMessage(File imageFile) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(
                    imageFile,
                    height: 150.0,
                    width: 150.0,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: 4.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJsonWithTitle(String jsonPath) {
    return Container(
      width: 70, // Ancho del contenedor
      child: Column(
        children: [
          Container(
            height: 50, // Aumenta la altura del contenedor de la animación
            width: 50, // Aumenta el ancho del contenedor de la animación
            child: Lottie.asset(
              jsonPath,
              fit: BoxFit.cover,
            ),
          ),
          SizedBox(height: 8), // Espacio entre la animación y el texto
        ],
      ),
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String message;
  final bool isMe;
  final bool isRead;
  final DateTime time;

  MessageBubble(
      {required this.message,
      required this.isMe,
      required this.isRead,
      required this.time});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: isMe ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: TextStyle(color: isMe ? Colors.white : Colors.black),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment:
                  isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
              children: [
                if (isMe)
                  Icon(
                    isRead ? Icons.done_all : Icons.done,
                    size: 15,
                    color: isRead ? Colors.blue : Colors.black,
                  ),
                Text(
                  ' ${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

enum MessageType {
  text,
  image,
  video,
  file,
}

class ChatMessage {
  final MessageType type;
  final String? text;
  final File? file;
  final File? videoFile;

  ChatMessage({
    required this.type,
    this.text,
    this.file,
    this.videoFile,
  });
}




