import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../estadoDark-White/DarkModeProvider.dart';

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

    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final backgroundColor = darkModeProvider.backgroundColor;


    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Preguntas frecuentes',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: backgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: iconColor),
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
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: 'Escriba un comentario...',
                      hintStyle: TextStyle(color: Colors.grey[700]),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.cyan), // Borde negro
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.cyan), // Borde negro cuando está deshabilitado
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.cyan), // Borde negro cuando está enfocado
                      ),
                      fillColor: Colors.grey[300],
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
                backgroundColor: MaterialStateProperty.all<Color>(Colors.cyan),
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
                    style: TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cerrar el diálogo
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.cyan),
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
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final backgroundColor = darkModeProvider.backgroundColor;

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
                border: Border.all(
                  color: _selectedOption == option ? Colors.cyan : Colors.cyan,
                ),
                color: _selectedOption == option ? Colors.cyan : Colors.transparent,
              ),
              child: _selectedOption == option
                  ? Icon(Icons.check, color: Colors.white, size: 19)
                  : null,
            ),
            SizedBox(width: 12),
            Flexible(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 16,
                  color: textColor,
                ),
                softWrap: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

}
