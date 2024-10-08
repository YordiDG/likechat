import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DeezerAPI extends StatefulWidget {
  @override
  _DeezerExampleState createState() => _DeezerExampleState();
}

class _DeezerExampleState extends State<DeezerAPI> {
  Map<String, dynamic>? songData;

  @override
  void initState() {
    super.initState();
    fetchSong();
  }

  Future<void> fetchSong() async {
    final response = await http.get(Uri.parse('https://api.deezer.com/search?q=Imagine+Dragons'));
    if (response.statusCode == 200) {
      setState(() {
        songData = json.decode(response.body)['data'][0]; // Primer resultado
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Deezer API Example')),
      body: songData == null
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Image.network(songData!['album']['cover']),
          Text(songData!['title'], style: TextStyle(fontSize: 24)),
          Text(songData!['artist']['name'], style: TextStyle(fontSize: 18, color: Colors.grey)),
          IconButton(
            icon: Icon(Icons.play_arrow),
            onPressed: () {
              // Lógica para reproducir la canción
            },
          ),
        ],
      ),
    );
  }
}
