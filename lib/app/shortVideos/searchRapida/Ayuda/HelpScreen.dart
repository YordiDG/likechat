import 'package:flutter/material.dart';

class HelpScreen extends StatefulWidget {
  @override
  _HelpScreenState createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  String _selectedOption = '';
  TextEditingController _commentController = TextEditingController();
  bool _showCommentField = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Preguntas frecuentes',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.deepPurple[600],
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '¿Con qué problema te encontraste?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildHelpOption('Error de conexión'),
                  _buildHelpOption('No encuentro resultados'),
                  _buildHelpOption('Problema al cargar datos'),
                  _buildHelpOption('El historial de búsqueda no se puede ver'),
                  _buildHelpOption('Las búsquedas sugeridas no me interesan o no están personalizadas'),
                  _buildHelpOption('La búsqueda sugerida contiene términos ilegales'),
                  _buildHelpOption('Otro problema'),
                ],
              ),
            ),
            SizedBox(height: 16),
            if (_showCommentField)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Describe tu problema',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Escribe aquí tu comentario...',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black), // Borde negro
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black), // Borde negro cuando está deshabilitado
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black), // Borde negro cuando está enfocado
                      ),
                      fillColor: Colors.grey[200],
                      filled: true,
                    ),
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.done,
                    style: TextStyle(color: Colors.black),
                    onChanged: (value) {
                      setState(() {
                        // El estado del botón de enviar no depende del texto del comentario
                      });
                    },
                    onSubmitted: (_) => _submitFeedback(context),
                  ),
                  SizedBox(height: 16),
                ],
              ),
            ElevatedButton(
              onPressed: _selectedOption.isNotEmpty
                  ? () {
                _submitFeedback(context);
              }
                  : null,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple),
                textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(color: Colors.white)),
                padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.all(16)),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              child: Text(
                'Enviar',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitFeedback(BuildContext context) {
    String comment = _commentController.text.trim();
    if (_selectedOption == 'Otro problema' && comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, escribe un comentario antes de enviar.'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else {
      // Aquí implementar la lógica para enviar el comentario o la opción seleccionada
      _commentController.clear();
      _showCommentField = false; // Ocultar el campo de comentario
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Comentario enviado correctamente',
                    style: TextStyle(fontSize: 18, color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cerrar el diálogo
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.deepPurple),
                      textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(color: Colors.white)),
                      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.all(12)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                    child: Text(
                      'Aceptar',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }

  Widget _buildHelpOption(String option) {
    return InkWell(
      onTap: () {
        setState(() {
          _selectedOption = option;
          _showCommentField = option == 'Otro problema';
        });
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: _selectedOption == option ? Colors.purple : Colors.blue),
                color: _selectedOption == option ? Colors.deepPurple : Colors.transparent,
              ),
              child: _selectedOption == option ? Icon(Icons.check, color: Colors.white, size: 18) : null,
            ),
            SizedBox(width: 12),
            Flexible(
              child: Text(
                option,
                style: TextStyle(fontSize: 16, color: Colors.black),
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
