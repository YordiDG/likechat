import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DeezerAPI extends StatefulWidget {
  @override
  _DeezerExampleState createState() => _DeezerExampleState();
}

class _DeezerExampleState extends State<DeezerAPI> {
  List<dynamic>? songData; // Cambiado a List<dynamic> para múltiples canciones

  @override
  void initState() {
    super.initState();
    fetchSongs(); // Cambia a fetchSongs
  }

  Future<void> fetchSongs() async {
    final response = await http.get(Uri.parse('https://api.deezer.com/chart'));
    if (response.statusCode == 200) {
      setState(() {
        songData = json.decode(response.body)['data']; // Obtiene todos los resultados
      });
    } else {
      // Manejo de errores
      print('Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Deezer API Example')),
      body: songData == null
          ? Center(child: CircularProgressIndicator()) // Muestra el círculo de carga
          : ListView.builder(
        itemCount: songData!.length, // Muestra todas las canciones
        itemBuilder: (context, index) {
          final song = songData![index];
          return ListTile(
            leading: Image.network(song['album']['cover'], width: 50),
            title: Text(song['title']),
            subtitle: Text(song['artist']['name'], style: TextStyle(color: Colors.grey)),
            trailing: IconButton(
              icon: Icon(Icons.play_arrow),
              onPressed: () {
                // Lógica para reproducir la canción
              },
            ),
          );
        },
      ),
    );
  }
}
