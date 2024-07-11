import 'package:flutter/material.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'OpenCamara/preview/PreviewScreen.dart';

class PostClass extends StatefulWidget {
  @override
  _PostClassState createState() => _PostClassState();
}

class _PostClassState extends State<PostClass> {
  TextEditingController _searchController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  String? _imagePath;
  List<Post> _publishedPosts = [];
  bool _permissionsDeniedMessageShown = false;

  @override
  void initState() {
    super.initState();
    // Solicitar permisos de cámara y abrir la cámara automáticamente cuando se carga la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestCameraPermission().then((granted) {
        if (granted) {
          _selectImage(source: ImageSource.camera);
        } else if (!_permissionsDeniedMessageShown) {
          _showPermissionDeniedMessage();
          _permissionsDeniedMessageShown = true;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
            child: TextField(
              controller: _searchController,
              cursorColor: Colors.white,
              decoration: InputDecoration(
                hintText: 'Buscar',
                hintStyle: TextStyle(color: Colors.white),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.white),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: BorderSide(color: Colors.white),
                ),
                filled: true,
                fillColor: Colors.transparent,
                contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white,
                ),
              ),
              style: TextStyle(color: Colors.white),
              onChanged: (value) {
                // Acción de búsqueda en tiempo real
              },
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 20.0),
                  _buildPublishedPostCards(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        width: 70.0, // Ancho del contenedor
        height: 70.0,
        margin: EdgeInsets.only(right: 25.0, bottom: 25.0), // Margen para separarlo del borde derecho y del botón inferior
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50), // Bordes redondeados
          color: Colors.deepPurple, // Color de fondo profesional
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.5), // Sombra suave
              spreadRadius: 4,
              blurRadius: 5,
              offset: Offset(0, 3), // Desplazamiento de la sombra
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () {
            _showImageSourceSelection();
          },
          backgroundColor: Colors.transparent, // Fondo transparente para el FAB principal
          elevation: 0, // Sin elevación para el FAB principal
          child: Icon(
            Icons.camera_alt,
            color: Colors.white, // Color del ícono blanco
            size: 35.0, // Tamaño del ícono aumentado
          ),
        ),
      ),
    );
  }

  Future<bool> _requestCameraPermission() async {
    // Solicitar permisos de cámara
    PermissionStatus cameraPermission = await Permission.camera.request();
    return cameraPermission.isGranted;
  }

  void _showImageSourceSelection() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20.0),
          decoration: BoxDecoration(
            color: Colors.grey[800], // Color de fondo profesional
            border: Border(
              top: BorderSide(width: 1.0, color: Colors.grey), // Borde blanco en la parte superior
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Seleccionar Imagen',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 10), // Espaciado entre el título y las opciones
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildImageSourceOption(
                    icon: Icons.camera_alt,
                    label: 'Cámara',
                    source: ImageSource.camera,
                    color: Colors.red,
                  ),
                  _buildImageSourceOption(
                    icon: Icons.photo,
                    label: 'Galería',
                    source: ImageSource.gallery,
                    color: Colors.green,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required ImageSource source,
    required Color color, // Cambiado a Color
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context); // Cerrar el BottomSheet
        _selectImage(source: source);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: color, // Color de fondo del círculo
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white, // Color del icono
              size: 30.0, // Tamaño reducido para hacerlo más profesional
            ),
          ),
          SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14, // Tamaño de texto reducido
            ),
          ),
        ],
      ),
    );
  }

  void _selectImage({required ImageSource source}) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _imagePath = pickedImage.path;
      });
      // Navegar a la pantalla de vista previa
      Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => PreviewScreen(
          imagePath: _imagePath!,
          descriptionController: _descriptionController,
          onPublish: _publishPost,
        ),
      ));
    }
  }

  void _showPermissionDeniedMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Permiso de cámara denegado. Por favor, habilite los permisos en la configuración.'),
      ),
    );
  }

  void _publishPost() {
    String description = _descriptionController.text;
    String? imagePath = _imagePath;

    if (description.isNotEmpty || imagePath != null) {
      // Crear un nuevo post
      Post newPost = Post(description: description, imagePath: imagePath);

      // Agregar el post publicado a la lista
      setState(() {
        _publishedPosts.add(newPost);
        _descriptionController.clear();
        _imagePath = null;
      });

      // Volver a la pantalla principal
      Navigator.of(context).pop();
    }
  }

  Widget _buildPublishedPostCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch, // Ocupar todo el ancho
      children: _publishedPosts.map((post) {
        return Card(
          color: Colors.grey, // Color de fondo gris plomo
          margin: EdgeInsets.only(bottom: 5.0), // Reducir el espacio entre publicaciones
          elevation: 0, // Eliminar elevación
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // Eliminar bordes en las esquinas
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Yordi Gonzales',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.access_time, size: 16.0, color: Colors.grey), // Icono de hora
                        SizedBox(width: 4.0),
                        Text(
                          'Hace 1 hora', // Ejemplo de texto de la hora
                          style: TextStyle(fontSize: 14.0, color: Colors.grey),
                        ),
                        SizedBox(width: 4.0),
                        Icon(Icons.public, size: 16.0, color: Colors.grey), // Icono de publicación
                      ],
                    ),
                    IconButton(
                      onPressed: () {
                        // Acción del botón para opciones adicionales
                      },
                      icon: Icon(Icons.more_vert, size: 32.0, color: Colors.grey), // Icono de tres puntos
                    ),
                  ],
                ),
                SizedBox(height: 10.0),
                Text(
                  post.description,
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
                SizedBox(height: 15.0),
                post.imagePath != null
                    ? Container(
                  height: 300.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0.0),
                    image: DecorationImage(
                      image: FileImage(File(post.imagePath!)),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
                    : Container(),
                SizedBox(height: 10.0), // Espaciado mayor ajustado
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, // Alinear a los extremos
                  children: [
                    IconButton(
                      onPressed: () {
                        // Acción del botón para interactuar con el post
                      },
                      icon: Icon(Icons.favorite, size: 32.0), // Icono más grande
                      color: Colors.red,
                    ),
                    IconButton(
                      onPressed: () {
                        // Acción del botón para interactuar con el post
                      },
                      icon: Icon(Icons.comment, size: 32.0), // Icono más grande
                      color: Colors.white,
                    ),
                    IconButton(
                      onPressed: () {
                        // Acción del botón para compartir el post
                      },
                      icon: Icon(Icons.share, size: 32.0), // Icono más grande
                      color: Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class Post {
  final String description;
  final String? imagePath;

  Post({required this.description, required this.imagePath});
}
