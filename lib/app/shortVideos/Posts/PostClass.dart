import 'package:flutter/material.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class PostClass extends StatefulWidget {
  @override
  _PostClassState createState() => _PostClassState();
}

class _PostClassState extends State<PostClass> {
  TextEditingController _searchController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  String? _imagePath;
  List<Post> _publishedPosts = [];

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
                  SizedBox(height: 12.0),
                  PostCard(
                    avatar: Icons.person,
                    onTapCamera: _selectImage,
                    imagePath: _imagePath,
                    descriptionController: _descriptionController,
                    onPressedPost: _publishPost,
                  ),
                  SizedBox(height: 20.0),
                  _buildPublishedPostCards(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _selectImage(source: ImageSource.camera); // Abre la cámara
        },
        child: Icon(Icons.camera_alt),
      ),
    );
  }

  void _selectImage({required ImageSource source}) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        _imagePath = pickedImage.path;
      });
    }
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
    }
  }

  Widget _buildPublishedPostCards() {
    return Column(
      children: _publishedPosts.map((post) {
        return Card(
          margin: EdgeInsets.all(10.0),
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Título del Post',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10.0),
                Text(
                  post.description,
                  style: TextStyle(fontSize: 18.0, color: Colors.black87),
                ),
                SizedBox(height: 10.0),
                post.imagePath != null
                    ? Container(
                  height: 200.0,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(File(post.imagePath!)),
                      fit: BoxFit.cover,
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                )
                    : Container(),
                SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () {
                        // Acción del botón para interactuar con el post
                      },
                      icon: Icon(Icons.thumb_up),
                      label: Text(
                        'Me gusta',
                        style: TextStyle(color: Colors.purple),
                      ),
                    ),
                    SizedBox(width: 10.0),
                    TextButton.icon(
                      onPressed: () {
                        // Acción del botón para compartir el post
                      },
                      icon: Icon(Icons.share),
                      label: Text(
                        'Compartir',
                        style: TextStyle(color: Colors.green),
                      ),
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

class PostCard extends StatelessWidget {
  final IconData avatar;
  final Function onTapCamera;
  final String? imagePath;
  final TextEditingController descriptionController;
  final Function onPressedPost;

  PostCard({
    required this.avatar,
    required this.onTapCamera,
    required this.imagePath,
    required this.descriptionController,
    required this.onPressedPost,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10.0),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25.0,
                  backgroundColor: Colors.grey[300],
                  child: Icon(
                    avatar,
                    size: 40.0,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(width: 10.0),
                Expanded(
                  child: TextField(
                    controller: descriptionController,
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                      hintText: '¿Vamos Postea una foto?',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide(color: Colors.black),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                    ),
                    maxLines: 1,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add_a_photo, color: Colors.deepPurple),
                  onPressed: () => onTapCamera(),
                ),
              ],
            ),
            SizedBox(height: 20.0),
            if (imagePath != null)
              Container(
                height: 300.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: FileImage(File(imagePath!)),
                    fit: BoxFit.cover,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
              )
            else
              Container(height: 0), // Espacio cero cuando no hay imagen
            SizedBox(height: 20.0),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onPressed: () => onPressedPost(),
              child: Text(
                'Publicar',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
