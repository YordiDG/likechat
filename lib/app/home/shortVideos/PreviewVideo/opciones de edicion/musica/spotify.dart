import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Reemplaza con tu Client ID y Client Secret
const String clientId = 'b33bcb8af56e4c89adf7c42828aaea4b';
const String clientSecret = '2e641302e4ca4da5ac2cd9e828e00921';
const String redirectUri = 'http://localhost:8888/callback';

// Clase para integrar Spotify
class SpotifyIntegration {
  static Future<String> getAccessToken(String code) async {
    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization': 'Basic ' + base64Encode(utf8.encode('$clientId:$clientSecret')),
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {
        'grant_type': 'authorization_code',
        'code': code,
        'redirect_uri': redirectUri,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['access_token'];
    } else {
      throw Exception('Failed to get access token');
    }
  }

  static Future<Map<String, dynamic>> searchTracks(String accessToken, String query) async {
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/search?q=$query&type=track'),
      headers: {
        'Authorization': 'Bearer $accessToken',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load tracks');
    }
  }

  static void showMusicModal(BuildContext context, List<Map<String, dynamic>> tracks) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16),
          child: ListView.builder(
            itemCount: tracks.length,
            itemBuilder: (context, index) {
              final track = tracks[index];
              final album = track['album'];
              final artist = track['artists'][0]['name'];
              final name = track['name'];
              final imageUrl = album['images'][0]['url'];

              return ListTile(
                leading: Image.network(imageUrl, width: 50, height: 50),
                title: Text(name),
                subtitle: Text(artist),
              );
            },
          ),
        );
      },
    );
  }
}
