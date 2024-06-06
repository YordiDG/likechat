import 'package:flutter/material.dart';
import 'app/camera/UserAvatar.dart';
import 'app/camera/filtros/EditMediaScreen.dart';
import 'app/storys/LikeChatScreen.dart';
import 'package:video_player/video_player.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:volume_controller/volume_controller.dart';


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
        body:
            HomeScreen(), // Solo muestra el contenido principal en el cuerpo del Scaffold
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
          if (_selectedIndex ==
              0) // Mostrar LikeChatScreen solo cuando se selecciona la pestaña de chats
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

class ShortVideosScreen extends StatefulWidget {
  @override
  _ShortVideosScreenState createState() => _ShortVideosScreenState();
}

class _ShortVideosScreenState extends State<ShortVideosScreen> {
  final List<dynamic> _videos = [];
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;
  int _likes = 0;
  int _comments = 0;
  double _volumeListenerValue = 0;
  double _getVolume = 0;
  double _setVolumeValue = 0;
  int  _videoDuration = 0;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    if (_videos.isNotEmpty) {
      _initializeVideoPlayer(_videos[_currentIndex]);
    }
    VolumeController().listener((volume) {
      setState(() => _volumeListenerValue = volume);
    });

    VolumeController().getVolume().then((volume) => _setVolumeValue = volume);
  }

  void _initializeVideoPlayer(dynamic video) {
    if (_controller != null) {
      _controller!.dispose();
    }

    if (video is String) {
      _controller = VideoPlayerController.network(video);
    } else if (video is File) {
      _controller = VideoPlayerController.file(video);
    }

    _initializeVideoPlayerFuture = _controller!.initialize().then((_) {
      setState(() {
        _videoDuration = _controller!.value.duration.inSeconds;
        _controller!.setLooping(true);
        _controller!.play();
      });
    });

    _controller!.addListener(() {
      setState(() {
        _videoDuration = _controller!.value.duration.inSeconds;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _videos.isEmpty
          ? _buildPlaceholder()
          : FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return PageView.builder(
              scrollDirection: Axis.vertical,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                  _initializeVideoPlayer(_videos[_currentIndex]);
                });
              },
              itemCount: _videos.length,
              itemBuilder: (context, index) {
                return GestureDetector( // Agrega un GestureDetector para detectar el clic en el video
                  onTap: _toggleVideoPlayback, // Llama al método para pausar/activar el video al hacer clic
                  child: Stack(
                    children: [
                      Center(
                        child: AspectRatio(
                          aspectRatio: _controller!.value.aspectRatio,
                          child: VideoPlayer(_controller!),
                        ),
                      ),
                      _buildIcons(),
                    ],
                  ),
                );
              },
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.video_library,
            color: Colors.white,
            size: 80.0,
          ),
          SizedBox(height: 20),
          Text(
            'No videos available. Add a new video!',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _showVideoOptions(context);
            },
            child: Text('Add Video'),
          ),
        ],
      ),
    );
  }

  Widget _buildIcons() {
    return Positioned(
      bottom: 90.0, // Ajusta el valor según sea necesario
      right: 19.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Positioned(
            top: MediaQuery.of(context).size.height * 0.30,
            right: 20.0,
            child: UserAvatar(
              isOwner: true, // O false, según corresponda
              addFriendCallback: (List<String> friendsList) {
                // Lógica para agregar amigos si no eres el propietario del video
              },
            ),
          ),
          IconButton(
            icon: SvgPicture.asset(
              'lib/assets/favorite.svg',
              width: 34.0,
              height: 34.0,
              color: Colors.white,
            ),
            onPressed: () {
              // Acción al presionar el botón de "Compartir"
            },
          ),
          Text(
            '$_likes',
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 12.0),
          IconButton(
            icon: SvgPicture.asset(
              'lib/assets/mesage.svg',
              width: 34.0,
              height: 34.0,
              color: Colors.white,
            ),
            onPressed: () {
              // Acción al presionar el botón de "Compartir"
            },
          ),
          Text(
            '$_comments',
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(height: 12.0),
          IconButton(
            icon: SvgPicture.asset(
              'lib/assets/shared.svg',
              width: 34.0,
              height: 34.0,
              color: Colors.white,
            ),
            onPressed: () {
              // Acción al presionar el botón de "Compartir"
            },
          ),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white, size: 30.0), // Icono de tres puntos
            onPressed: () {
              // Acción al presionar el botón de tres puntos
            },
          ),
        ],
      ),

    );
  }

  Widget _buildFloatingActionButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FloatingActionButton(
          onPressed: () {
            _showVideoOptions(context);
          },
          child: Icon(
            Icons.camera_alt_rounded,
            size: 33, // Tamaño del icono
            color: Colors.red, // Color del icono
          ),
        ),
      ],
    );
  }



  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: Duration(seconds: 20),
    );
    if (pickedFile != null) {
      setState(() {
        _videos.add(File(pickedFile.path));
        _currentIndex = _videos.length - 1;
        _initializeVideoPlayer(_videos[_currentIndex]);
      });
    }
  }

  void _showVideoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Record Video'),
              onTap: () {
                Navigator.pop(context); // Utiliza Navigator.pop para regresar
                _recordVideo();
              },
            ),
            ListTile(
              leading: Icon(Icons.video_library),
              title: Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context); // Utiliza Navigator.pop para regresar
                _pickVideo();
              },
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text('Choose Image'),
              onTap: () {
                Navigator.pop(context); // Utiliza Navigator.pop para regresar
                _pickImage();
              },
            ),
            // Agrega más opciones según sea necesario
          ],
        );
      },
    );
  }

  // Método para pausar/activar el video al hacer clic en él
  void _toggleVideoPlayback() {
    if (_controller!.value.isPlaying) {
      _controller!.pause(); // Pausar el video si está reproduciéndose
    } else {
      _controller!.play(); // Reanudar la reproducción si el video está pausado
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Aplicar filtro a la imagen seleccionada
      await _applyImageFilter(File(pickedFile.path));
    }
  }

  Future<void> _recordImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      // Aplicar filtro a la imagen grabada desde la cámara
      await _applyImageFilter(File(pickedFile.path));
    }
  }

  Future<void> _applyImageFilter(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final imagen = img.decodeImage(bytes);
    final filtroSepia = img.grayscale(imagen!);
    final filtroCartoon = _aplicarCartoon(imagen);
    final filtroAcuarela = _aplicarAcuarela(imagen);
    final filtroEspejo = img.flipHorizontal(imagen);

    // Actualizar la imagen en la lista de videos
    setState(() {
      _videos.add(imagen);
      _videos.add(filtroSepia);
      _videos.add(filtroCartoon);
      _videos.add(filtroAcuarela);
      _videos.add(filtroEspejo);
    });
  }

  img.Image _aplicarCartoon(img.Image imagen) {
    final grayscale = img.grayscale(imagen);
    final sobel = img.sobel(grayscale);
    return img.invert(sobel);
  }

  img.Image _aplicarAcuarela(img.Image imagen) {
    final blur = img.gaussianBlur(imagen, radius: 20);
    return img.colorOffset(blur, red: 30, green: 30, blue: 30);
  }


  void _recordVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: Duration(seconds: 20),
    );

    if (pickedFile != null) {
      setState(() {
        _videos.add(File(pickedFile.path));
        _currentIndex = _videos.length - 1;
        _initializeVideoPlayer(_videos[_currentIndex]);
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    VolumeController().removeListener();
    super.dispose();
  }
}



class FriendsScreen extends StatelessWidget {
  // Simulación de datos de sugerencias de amigos
  final List<String> friendSuggestions = ['User1', 'User2', 'User3'];

  // Algoritmo de recomendación para sugerir amigos
  List<String> recommendFriends() {
    // Implementa aquí tu algoritmo de recomendación
    // Puedes utilizar Machine Learning o cualquier otro método para calcular las sugerencias de amigos
    // Por ahora, retornamos una lista de amigos simulada
    return ['User4', 'User5', 'User6'];
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos las sugerencias de amigos recomendadas
    final recommendedFriends = recommendFriends();

    return ListView(
      children: [
        // Sección de sugerencias de amigos recomendadas
        for (var friend in recommendedFriends)
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(Icons.person_add, color: Colors.white),
            ),
            title: Text(friend),
            trailing: ElevatedButton(
              onPressed: () {
                // Lógica para agregar al amigo sugerido
                // Aquí puedes implementar la lógica para seguir al usuario sugerido
              },
              child: Text('Add Friend'),
            ),
          ),

        Divider(),

        // Sección de amigos actuales
        for (var friend in friendSuggestions)
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.green,
              child: Text('F'),
            ),
            title: Text(friend),
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
