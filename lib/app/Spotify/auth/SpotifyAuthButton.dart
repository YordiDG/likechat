import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SpotifyAuthButton extends StatelessWidget {
  final String clientId = '46bfa1aafb0c4f649b0c88d081b1d037';
  final String redirectUri = 'myapp://callback';
  final String scopes = 'user-read-private user-read-email user-library-read playlist-read-private';

  Future<void> _launchAuthURL() async {
    final authUrl = Uri.parse(
      'https://accounts.spotify.com/authorize'
          '?client_id=$clientId'
          '&response_type=token'
          '&redirect_uri=$redirectUri'
          '&scope=$scopes',
    );

    if (await canLaunchUrl(authUrl)) {
      await launchUrl(authUrl);
    } else {
      throw 'Could not launch $authUrl';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _launchAuthURL,
      child: Text('Login with Spotify'),
    );
  }
}
