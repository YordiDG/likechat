import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../../../Globales/estadoDark-White/DarkModeProvider.dart';

class EditProfileScreen extends StatefulWidget {
  final String fullname;
  final String usernameid;
  final String description;
  final List<String> socialLinks; // Cambié socialLink a una lista de enlaces
  final Function(String, String, String, List<String>)
      onSave; // Cambié el tipo de la función

  EditProfileScreen({
    required this.fullname,
    required this.usernameid,
    required this.description,
    required this.socialLinks,
    required this.onSave,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _fullnameController;
  late TextEditingController _usernameController;
  late TextEditingController _descriptionController;
  late TextEditingController _socialLinkController;

  final int maxLines = 3;
  String? socialPlatform;

  List<String> socialLinks = []; // Lista para almacenar los enlaces agregados

  @override
  void initState() {
    super.initState();
    _fullnameController = TextEditingController(text: widget.fullname);
    _usernameController = TextEditingController(text: widget.usernameid);
    _descriptionController = TextEditingController(text: widget.description);
    _socialLinkController = TextEditingController();
    socialLinks = List.from(
        widget.socialLinks); // Inicia la lista con los enlaces pasados
  }

  @override
  void dispose() {
    _fullnameController.dispose();
    _usernameController.dispose();
    _descriptionController.dispose();
    _socialLinkController.dispose();
    super.dispose();
  }

  bool isValidSocialLink(String url) {
    final RegExp facebookRegExp =
        RegExp(r'^https?:\/\/(www\.)?facebook.com\/.+$');
    final RegExp tiktokRegExp = RegExp(r'^https?:\/\/(www\.)?tiktok.com\/.+$');
    final RegExp youtubeRegExp =
        RegExp(r'^https?:\/\/(www\.)?youtube.com\/.+$');
    final RegExp whatsappRegExp = RegExp(r'^https?:\/\/(www\.)?wa.me\/.+$');
    final RegExp instagramRegExp =
        RegExp(r'^https?:\/\/(www\.)?instagram.com\/.+$');
    final RegExp linkedinRegExp =
        RegExp(r'^https?:\/\/(www\.)?linkedin.com\/.+$');

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
          icon: Icon(Icons.arrow_back_ios_new,
              color: isDarkMode ? Colors.white : Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: Colors.cyan,
            selectionColor: Colors.cyan.withOpacity(0.3),
            selectionHandleColor: Colors.cyan,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14),
            child: Column(
              children: [
                // Reemplazar el TextField de nombre con customDecoration
                TextField(
                  controller: _fullnameController,
                  maxLength: 35,
                  decoration: customDecoration('Nombre', Icons.person),
                  cursorColor: Colors.cyan,
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                ),
                SizedBox(height: 16),

                // Reemplazar el TextField de nombre de usuario con customDecoration
                TextField(
                  controller: _usernameController,
                  maxLength: 20,
                  decoration: customDecoration('Nombre de Usuario', Icons.person),
                  cursorColor: Colors.cyan,
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                ),
                SizedBox(height: 16),

                // Reemplazar el TextField de descripción con customDecoration
                TextField(
                  controller: _descriptionController,
                  maxLength: 60,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  onChanged: (text) {
                    if (text.split('\n').length > maxLines) {
                      _descriptionController.text = _descriptionController.text
                          .substring(
                          0, _descriptionController.text.lastIndexOf('\n'));
                      _descriptionController.selection =
                          TextSelection.fromPosition(TextPosition(
                              offset: _descriptionController.text.length));
                    }
                  },
                  decoration: customDecoration('Descripción', Icons.description),
                  cursorColor: Colors.cyan,
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                ),
                SizedBox(height: 16),

                // Reemplazar el TextField de enlace con customDecoration
                TextField(
                  controller: _socialLinkController,
                  decoration: customDecoration('Enlace a otra red social', Icons.link),
                  cursorColor: Colors.cyan,
                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                  onChanged: (text) {
                    setState(() {
                      isValidSocialLink(text);
                    });
                  },
                ),
                SizedBox(height: 8),

                // El resto del código sigue igual...
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_socialLinkController.text.isNotEmpty &&
                              isValidSocialLink(_socialLinkController.text)) {
                            if (socialLinks.length < 5) {
                              // Añadir enlace si el límite no ha sido alcanzado
                              socialLinks.add(_socialLinkController.text);
                              _socialLinkController.clear();
                            } else {
                              Fluttertoast.showToast(
                                msg: "Solo se permiten hasta 5 redes sociales.",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity.BOTTOM,
                                backgroundColor: Colors.grey.shade800,
                                textColor: Colors.white,
                                fontSize: 13.0,
                              );
                            }
                          }
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.cyan,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: EdgeInsets.all(6),
                        child: Icon(FontAwesomeIcons.add,
                            color: Colors.white, size: 16),
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Añadir más enlace',
                      style: TextStyle(
                        color: Colors.cyan,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Elras',
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Mostrar enlaces añadidos (igual)
                if (socialLinks.isNotEmpty)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: socialLinks.length,
                    itemBuilder: (context, index) {
                      String link = socialLinks[index];
                      IconData icon = Icons.link;

                      // Definir el ícono basado en la plataforma detectada
                      if (link.contains('facebook'))
                        icon = FontAwesomeIcons.facebook;
                      else if (link.contains('tiktok'))
                        icon = FontAwesomeIcons.tiktok;
                      else if (link.contains('youtube'))
                        icon = FontAwesomeIcons.youtube;
                      else if (link.contains('whatsapp'))
                        icon = FontAwesomeIcons.whatsapp;
                      else if (link.contains('instagram'))
                        icon = FontAwesomeIcons.instagram;
                      else if (link.contains('linkedin'))
                        icon = FontAwesomeIcons.linkedin;

                      return Container(
                        margin: EdgeInsets.symmetric(vertical: 2, horizontal: 8),
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: isDarkMode
                              ? Colors.grey.shade900
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(9),
                          boxShadow: [
                            BoxShadow(
                              color: isDarkMode
                                  ? Colors.white60
                                  : Colors.grey.withOpacity(0.2),
                              spreadRadius: 1,
                              blurRadius: 1,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(icon, color: Colors.cyan, size: 22),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                link,
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white : Colors.cyan,
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.remove_circle,
                                  color: Colors.red, size: 20),
                              onPressed: () {
                                setState(() {
                                  socialLinks.removeAt(index);
                                });
                              },
                              splashRadius: 20,
                            ),
                          ],
                        ),
                      );
                    },
                  ),

                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSave(
                        _fullnameController.text,
                        _usernameController.text,
                        _descriptionController.text,
                        socialLinks,
                      );
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      padding: EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text('Guardar Cambios',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration customDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.cyan),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.cyan),
        borderRadius: BorderRadius.circular(10.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.cyan),
        borderRadius: BorderRadius.circular(10.0),
      ),
      prefixIcon: Icon(icon, color: Colors.cyan),
    );
  }

}
