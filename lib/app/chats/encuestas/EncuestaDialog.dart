import 'package:flutter/material.dart';

class EncuestaDialog extends StatefulWidget {
  @override
  _EncuestaDialogState createState() => _EncuestaDialogState();
}

class _EncuestaDialogState extends State<EncuestaDialog> {
  List<String> opciones = [''];
  String titulo = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Crear Encuesta', style: TextStyle(color: Colors.white)),
      backgroundColor: Colors.grey[850],
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              onChanged: (value) {
                titulo = value;
              },
              decoration: InputDecoration(
                hintText: 'Título de la encuesta',
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[600]!),
                ),
              ),
            ),
            SizedBox(height: 10),
            Text('Opciones:', style: TextStyle(color: Colors.white)),
            SizedBox(height: 10),
            ...opciones.map((opcion) => _buildOpcionRow(opcion)).toList(),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  opciones.add('');
                });
              },
              child: Text('Agregar Opción'),
              style: ElevatedButton.styleFrom(
                 backgroundColor: Colors.cyan,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            // Manejar la lógica de creación de la encuesta
            Navigator.of(context).pop();
          },
          child: Text('Enviar', style: TextStyle(color: Colors.cyan)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancelar', style: TextStyle(color: Colors.cyan)),
        ),
      ],
    );
  }

  Widget _buildOpcionRow(String opcion) {
    int index = opciones.indexOf(opcion);
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (value) {
              setState(() {
                opciones[index] = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Opción ${index + 1}',
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[600]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[600]!),
              ),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.remove_circle, color: Colors.red),
          onPressed: () {
            setState(() {
              opciones.removeAt(index);
            });
          },
        ),
      ],
    );
  }
}
