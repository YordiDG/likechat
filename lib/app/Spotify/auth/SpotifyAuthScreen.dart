import 'package:flutter/material.dart';
import 'package:uni_links2/uni_links.dart';

import 'SpotifyAuthButton.dart';

class SpotifyAuthScreen extends StatefulWidget {
  @override
  _SpotifyAuthScreenState createState() => _SpotifyAuthScreenState();
}

class _SpotifyAuthScreenState extends State<SpotifyAuthScreen> {
  String? _accessToken;

  @override
  void initState() {
    super.initState();
    //_handleIncomingLinks();
  }

  /*void _handleIncomingLinks() async {
    // Escucha el cambio de link
    getUriLinksStream().listen((Uri? uri) {
      if (uri != null && uri.toString().contains('access_token=')) {
        setState(() {
          _accessToken = uri.fragment.split('&')[0].split('=')[1];
        });
      }
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Spotify Authentication')),
      body: Center(
        child: _accessToken == null
            ? SpotifyAuthButton() // El botón de autenticación
            : Text('Authenticated with token: $_accessToken'),
      ),
    );
  }
}
