import 'package:flutter/material.dart';

class EditProfileScreen extends StatefulWidget {
  final String username;
  final String description;
  final Function(String, String) onSave;

  EditProfileScreen({
    required this.username,
    required this.description,
    required this.onSave,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _descriptionController;
  final int maxLines = 3;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username);
    _descriptionController = TextEditingController(text: widget.description);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple[600],
        title: Text(
          'Editar Perfil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              maxLength: 35,
              decoration: InputDecoration(
                labelText: 'Nombre',
                labelStyle: TextStyle(color: Colors.deepPurple[600]),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple[600]!),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple[800]!),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                prefixIcon: Icon(Icons.person, color: Colors.deepPurple[600]),
              ),
              cursorColor: Colors.deepPurple[800],
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLength: 60,
              maxLines: null, // Permitir cualquier número de líneas
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              onChanged: (text) {
                // Verificar si hay más de 3 líneas visibles
                if (text.split('\n').length > maxLines) {
                  // Si hay más de 3 líneas, eliminar la última línea agregada
                  _descriptionController.text = _descriptionController.text.substring(0, _descriptionController.text.lastIndexOf('\n'));
                  // Mover el cursor al final del texto
                  _descriptionController.selection = TextSelection.fromPosition(TextPosition(offset: _descriptionController.text.length));
                }
              },
              decoration: InputDecoration(
                labelText: 'Descripción',
                labelStyle: TextStyle(color: Colors.deepPurple[600]),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple[600]!),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.deepPurple[800]!),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                prefixIcon:
                Icon(Icons.description, color: Colors.deepPurple[600]),
              ),
              cursorColor: Colors.deepPurple[800],
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                widget.onSave(
                  _usernameController.text,
                  _descriptionController.text,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple[600],
                padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                textStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              child: Text(
                'Guardar',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
