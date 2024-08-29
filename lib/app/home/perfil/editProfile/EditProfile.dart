import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../Globales/estadoDark-White/DarkModeProvider.dart';

class EditProfileScreen extends StatefulWidget {
  final String username;
  final String description;
  final String socialLink;
  final Function(String, String, String) onSave;

  EditProfileScreen({
    required this.username,
    required this.description,
    required this.socialLink,
    required this.onSave,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _usernameController;
  late TextEditingController _descriptionController;
  late TextEditingController _socialLinkController;

  final int maxLines = 3;
  String? socialPlatform;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.username);
    _descriptionController = TextEditingController(text: widget.description);
    _socialLinkController = TextEditingController(text: widget.socialLink);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _descriptionController.dispose();
    _socialLinkController.dispose();
    super.dispose();
  }

  bool isValidSocialLink(String url) {
    final RegExp facebookRegExp = RegExp(r'^https?:\/\/(www\.)?facebook.com\/.+$');
    final RegExp tiktokRegExp = RegExp(r'^https?:\/\/(www\.)?tiktok.com\/.+$');
    final RegExp youtubeRegExp = RegExp(r'^https?:\/\/(www\.)?youtube.com\/.+$');
    final RegExp whatsappRegExp = RegExp(r'^https?:\/\/(www\.)?wa.me\/.+$');
    final RegExp instagramRegExp = RegExp(r'^https?:\/\/(www\.)?instagram.com\/.+$');
    final RegExp linkedinRegExp = RegExp(r'^https?:\/\/(www\.)?linkedin.com\/.+$');

    if (facebookRegExp.hasMatch(url)) {
      socialPlatform = 'Facebook';
      return true;
    } else if (tiktokRegExp.hasMatch(url)) {
      socialPlatform = 'TikTok';
      return true;
    } else if (youtubeRegExp.hasMatch(url)) {
      socialPlatform = 'YouTube';
      return true;
    } else if (whatsappRegExp.hasMatch(url)) {
      socialPlatform = 'WhatsApp';
      return true;
    } else if (instagramRegExp.hasMatch(url)) {
      socialPlatform = 'Instagram';
      return true;
    } else if (linkedinRegExp.hasMatch(url)) {
      socialPlatform = 'LinkedIn';
      return true;
    } else {
      socialPlatform = null;
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {

    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final backgroundColor = darkModeProvider.backgroundColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(
          'Editar Perfil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDarkMode ? Colors.white : Colors.black,),
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
                labelStyle: TextStyle(color: Colors.cyan),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyan),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyan),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                prefixIcon: Icon(Icons.person, color: Colors.cyan),
              ),
              cursorColor: Colors.cyan,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black,),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              maxLength: 60,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              onChanged: (text) {
                if (text.split('\n').length > maxLines) {
                  _descriptionController.text = _descriptionController.text.substring(0, _descriptionController.text.lastIndexOf('\n'));
                  _descriptionController.selection = TextSelection.fromPosition(TextPosition(offset: _descriptionController.text.length));
                }
              },
              decoration: InputDecoration(
                labelText: 'Descripción',
                labelStyle: TextStyle(color: Colors.cyan,),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyan),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyan),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                prefixIcon: Icon(Icons.description, color: Colors.cyan),
              ),
              cursorColor: Colors.cyan,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black,),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _socialLinkController,
              decoration: InputDecoration(
                labelText: 'Enlace a otra red social',
                labelStyle: TextStyle(color: Colors.cyan),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyan),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.cyan),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                prefixIcon: Icon(Icons.link, color: Colors.cyan),
              ),
              cursorColor: Colors.cyan,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black,),
              onChanged: (text) {
                setState(() {
                  isValidSocialLink(text);
                });
              },
            ),
            if (socialPlatform != null) ...[
              SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    socialPlatform == 'Facebook' ? FontAwesomeIcons.facebook :
                    socialPlatform == 'TikTok' ? FontAwesomeIcons.tiktok :
                    socialPlatform == 'YouTube' ? FontAwesomeIcons.youtube :
                    socialPlatform == 'Instagram' ? FontAwesomeIcons.instagram :
                    socialPlatform == 'LinkedIn' ? FontAwesomeIcons.linkedin :
                    FontAwesomeIcons.whatsapp,
                    color: Colors.cyan,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Enlace válido para $socialPlatform',
                    style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
            SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                final socialLink = _socialLinkController.text;
                if (socialLink.isEmpty || isValidSocialLink(socialLink)) {
                  widget.onSave(
                    _usernameController.text,
                    _descriptionController.text,
                    socialLink,
                  );
                  Navigator.pop(context);
                } else {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        backgroundColor: Colors.grey[850], // Fondo gris oscuro
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0), // Bordes redondeados
                        ),
                        title: Text(
                          'Enlace no válido',
                          style: TextStyle(
                            color: Colors.white, // Letras blancas
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        content: Text(
                          'Por favor, ingrese un enlace válido de Facebook, TikTok, YouTube, WhatsApp, Instagram, o LinkedIn.',
                          style: TextStyle(
                            color: Colors.white70, // Letras blancas con menor opacidad
                          ),
                        ),
                        actions: [
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.cyan, // Color del texto del botón
                              textStyle: TextStyle(
                                fontWeight: FontWeight.bold, // Texto en negrita
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
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
