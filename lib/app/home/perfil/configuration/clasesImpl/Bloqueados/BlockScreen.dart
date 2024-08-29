import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../Globales/estadoDark-White/DarkModeProvider.dart';

class BlockScreen extends StatefulWidget {
  final Color tileColor;
  final Color textColor;
  final double fontSize;

  BlockScreen({
    required this.tileColor,
    required this.textColor,
    required this.fontSize,
  });

  @override
  _BlockScreenState createState() => _BlockScreenState();
}

class _BlockScreenState extends State<BlockScreen> {
  List<Map<String, String>> blockedUsers = [
    {'name': 'Usuario1', 'imageUrl': 'assets/user1.jpg'},
    {'name': 'Usuario2', 'imageUrl': 'assets/user2.jpg'},
    {'name': 'Usuario3', 'imageUrl': 'assets/user3.jpg'},
    {'name': 'Usuario4', 'imageUrl': 'assets/user4.jpg'},
    {'name': 'Usuario5', 'imageUrl': 'assets/user5.jpg'},
    {'name': 'Usuario6', 'imageUrl': 'assets/user6.jpg'},
    {'name': 'Usuario7', 'imageUrl': 'assets/user7.jpg'},
    {'name': 'Usuario8', 'imageUrl': 'assets/user8.jpg'},
  ];

  List<Map<String, String>> _blockedUsers = [];

  @override
  void initState() {
    super.initState();
    _blockedUsers = List.from(blockedUsers);
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final backgroundColor = isDarkMode ? Colors.black : Colors.grey.shade100;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          'Lista de Bloqueados',
          style: TextStyle(fontSize: 18, color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: backgroundColor,
        elevation: 1,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: TextButton(
              onPressed: _blockedUsers.isNotEmpty ? () {
                _showClearAllDialog(context);
              } : null,
              child: Text(
                'Eliminar Todo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 9.0, vertical: 4.0),
                ),
                minimumSize: MaterialStateProperty.all<Size>(
                  Size(0, 30),
                ),
                side: MaterialStateProperty.all<BorderSide>(
                  BorderSide(
                      color: Colors.pink.withOpacity(0.7),
                      width: 1.6),
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.pink),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(1.0),
        child: _blockedUsers.isNotEmpty
            ? ListView.builder(
          itemCount: _blockedUsers.length,
          itemBuilder: (context, index) {
            final user = _blockedUsers[index];
            return _buildBlockItem(
              userName: user['name']!,
              imageUrl: user['imageUrl']!,
              onUnblock: () {
                _showUnblockDialog(context, user['name']!);
              },
              onDelete: () {
                _showDeleteDialog(context, user['name']!);
              },
            );
          },
        )
            : Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_off,
                color: Colors.grey.shade400,
                size: 180,
              ),
              SizedBox(height: 4),
              Text(
                'No hay usuarios bloqueados',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBlockItem({
    required String userName,
    required String imageUrl,
    required VoidCallback onUnblock,
    required VoidCallback onDelete,
  }) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 1),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        leading: CircleAvatar(
          backgroundImage: AssetImage(imageUrl),
          radius: 24.0,
        ),
        title: Text(
          userName,
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        subtitle: Text(
          'Fecha: 01/01/2024\nHora: 12:00 PM',
          style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 10.0),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: onUnblock,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
                backgroundColor: Colors.grey.shade600,
                minimumSize: Size(70, 30),
                padding: EdgeInsets.symmetric(horizontal: 8.0),
              ),
              child: Text(
                'Desbloquear',
                style: TextStyle(fontSize: 10.0, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 8.0),
            ElevatedButton(
              onPressed: onDelete,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6.0),
                ),
                minimumSize: Size(70, 30),
                padding: EdgeInsets.symmetric(horizontal: 8.0),
              ),
              child: Text(
                'Borrar',
                style: TextStyle(fontSize: 12.0, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUnblockDialog(BuildContext context, String userName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          backgroundColor: Colors.grey.shade800,
          title: Align(
            alignment: Alignment.center,
            child: Text(
              'Desbloquear $userName',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
              ),
            ),
          ),
          content: Text(
            '¿Estás seguro de que quieres desbloquear a $userName?',
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 9.0, vertical: 4.0),
                ),
                minimumSize: MaterialStateProperty.all<Size>(
                  Size(0, 30),
                ),
                side: MaterialStateProperty.all<BorderSide>(
                  BorderSide(
                      color: Colors.grey.withOpacity(0.7),
                      width: 1),
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.transparent),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _blockedUsers.removeWhere((user) => user['name'] == userName);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$userName', // Nombre de usuario en negrita
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold, // Negrita
                            ),
                          ),
                          TextSpan(
                            text: ' ha sido desbloqueado', // Resto del texto en normal
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins',
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal, // Normal
                            ),
                          ),
                        ],
                      ),
                    ),
                    backgroundColor: Color(0xFF333030), // Fondo gris profesional en hexadecimal
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), // Borde redondeado de 8 píxeles
                    ),
                    behavior: SnackBarBehavior.floating, // Hace que el SnackBar flote
                    margin: EdgeInsets.only(
                      bottom: 20.0, // Margen inferior de 20 píxeles
                      left: 10.0,
                      right: 10.0,
                    ),
                  ),
                );
              },
              child: Text(
                'Desbloquear',
                style: TextStyle(
                  color: Colors.pink,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 9.0, vertical: 4.0),
                ),
                minimumSize: MaterialStateProperty.all<Size>(
                  Size(0, 30),
                ),
                side: MaterialStateProperty.all<BorderSide>(
                  BorderSide(
                      color: Colors.pink.withOpacity(0.7),
                      width: 1.6),
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.transparent),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, String userName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          backgroundColor: Colors.grey.shade800,
          title: Align(
            alignment: Alignment.center,
            child: Text(
              'Eliminar $userName',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
              ),
            ),
          ),
          content: Text(
            '¿Estás seguro de que quieres eliminar a $userName de la lista de bloqueados?',
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 9.0, vertical: 4.0),
                ),
                minimumSize: MaterialStateProperty.all<Size>(
                  Size(0, 30),
                ),
                side: MaterialStateProperty.all<BorderSide>(
                  BorderSide(
                      color: Colors.grey.withOpacity(0.7),
                      width: 1),
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.transparent),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _blockedUsers.removeWhere((user) => user['name'] == userName);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: '$userName', // Nombre de usuario en negrita
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins', // Fuente redondita y bonita
                              fontSize: 14.0,
                              fontWeight: FontWeight.bold, // Negrita
                            ),
                          ),
                          TextSpan(
                            text: ' ha sido eliminado', // Resto del texto en normal
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Poppins', // Fuente redondita y bonita
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal, // Normal
                            ),
                          ),
                        ],
                      ),
                    ),
                    backgroundColor: Color(0xFF333030), // Fondo gris profesional en hexadecimal
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), // Borde redondeado de 8 píxeles
                    ),
                    behavior: SnackBarBehavior.floating, // Hace que el SnackBar flote
                    margin: EdgeInsets.only(
                      bottom: 20.0, // Margen inferior de 20 píxeles
                      left: 10.0,
                      right: 10.0,
                    ),
                  ),
                );
              },
              child: Text(
                'Eliminar',
                style: TextStyle(
                  color: Colors.pink,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 9.0, vertical: 4.0),
                ),
                minimumSize: MaterialStateProperty.all<Size>(
                  Size(0, 30),
                ),
                side: MaterialStateProperty.all<BorderSide>(
                  BorderSide(
                      color: Colors.pink.withOpacity(0.7),
                      width: 1.6),
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.transparent),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          backgroundColor: Colors.grey.shade800,
          title: Align(
            alignment: Alignment.center,
            child: Text(
              'Eliminar Todos los Usuarios',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white
              ),
            ),
          ),
          content: Text(
            '¿Estás seguro de que quieres eliminar todos los usuarios bloqueados?',
            style: TextStyle(fontSize: 14, color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 9.0, vertical: 4.0),
                ),
                minimumSize: MaterialStateProperty.all<Size>(
                  Size(0, 30),
                ),
                side: MaterialStateProperty.all<BorderSide>(
                  BorderSide(
                      color: Colors.grey.withOpacity(0.7),
                      width: 1),
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.transparent),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _blockedUsers.clear();
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Todos los usuarios han sido eliminados',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins', // Fuente redondita y bonita
                        fontSize: 12.0, // Tamaño de letra
                        fontWeight: FontWeight.w500, // Normal
                      ),
                    ),
                    backgroundColor: Color(0xFF333030), // Fondo gris profesional en hexadecimal
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), // Borde redondeado de 8 píxeles
                    ),
                    behavior: SnackBarBehavior.floating, // Hace que el SnackBar flote
                    margin: EdgeInsets.only(
                      bottom: 20.0, // Margen inferior de 20 píxeles
                      left: 10.0,
                      right: 10.0,
                    ),
                  ),
                );
              },
              child: Text(
                'Eliminar Todo',
                style: TextStyle(
                  color: Colors.pink,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              style: ButtonStyle(
                padding: MaterialStateProperty.all<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 9.0, vertical: 4.0),
                ),
                minimumSize: MaterialStateProperty.all<Size>(
                  Size(0, 30),
                ),
                side: MaterialStateProperty.all<BorderSide>(
                  BorderSide(
                      color: Colors.pink.withOpacity(0.7),
                      width: 1.6),
                ),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.transparent),
              ),
            ),
          ],
        );
      },
    );
  }
}

