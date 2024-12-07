import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../Globales/estadoDark-White/DarkModeProvider.dart';

class ComentariosPost extends StatefulWidget {
  @override
  _CommentButtonState createState() => _CommentButtonState();
}

class _CommentButtonState extends State<ComentariosPost> {
  int commentCount = 9999; // Contador inicial de comentarios
  List<Comment> comments = [
    Comment(username: 'usuario1', text: 'Comentario increíble', likes: 12),
    Comment(username: 'usuario2', text: 'Me encanta esto', likes: 5),
    Comment(username: 'usuario3', text: 'Excelente contenido', likes: 8),
  ];

  void openCommentsModal(BuildContext context) {
    final textController = TextEditingController();
    final darkModeProvider =
        Provider.of<DarkModeProvider>(context, listen: false);
    final isDarkMode = darkModeProvider.isDarkMode;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[900] : Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  // Encabezado con contador de comentarios
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              FontAwesomeIcons.commentDots,
                              size: 20,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Comentarios',
                              style: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.grey[800]
                                    : Colors.grey[200],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$commentCount',
                                style: TextStyle(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    thickness: 0.4, // Grosor real de la línea
                    color: Colors.grey,
                  ),
                  // Lista de comentarios
                  Expanded(
                    child: ListView.builder(
                      controller: controller,
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                child: Text(comment.username[0].toUpperCase()),
                                backgroundColor: Colors.blue[200],
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '${comment.username} ',
                                            style: GoogleFonts.roboto(
                                              fontWeight: FontWeight.bold,
                                              color: isDarkMode
                                                  ? Colors.white
                                                  : Colors.black,
                                            ),
                                          ),
                                          TextSpan(
                                            text: comment.text,
                                            style: GoogleFonts.roboto(
                                              color: isDarkMode
                                                  ? Colors.grey[300]
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Text(
                                          'Hace 2h',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        GestureDetector(
                                          onTap: () {},
                                          child: Text(
                                            'Responder',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        Spacer(),
                                        Icon(
                                          Icons.favorite_border,
                                          size: 16,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          '${comment.likes}',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 8,
                        bottom: MediaQuery.of(context).viewInsets.bottom + 16, // Ajuste del padding cuando el teclado está visible
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start, // Alinea todo hacia la izquierda
                        crossAxisAlignment: CrossAxisAlignment.center, // Centra los elementos verticalmente
                        children: [
                          CircleAvatar(
                            radius: 17,
                            backgroundColor: Colors.grey[400], // Avatar gris por defecto
                            child: Icon(Icons.person, size: 20, color: Colors.white),
                          ),
                          SizedBox(width: 8), // Espacio entre el avatar y el TextField
                          Flexible(
                            child: Container(
                              height: textController.text.isEmpty ? 40 : null, // Establece una altura de 40 cuando está vacío
                              constraints: BoxConstraints(
                                maxHeight: 120, // Limita la altura a un máximo de 4 líneas
                              ),
                              child: TextField(
                                controller: textController,
                                minLines: 1,
                                maxLines: 4,
                                cursorColor: Colors.cyan,
                                keyboardType: TextInputType.multiline, // Permite la entrada multilinea
                                decoration: InputDecoration(
                                  hintText: 'Añadir un comentario...',
                                  hintStyle: TextStyle(
                                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(13),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(13),
                                    borderSide: BorderSide(color: Colors.cyan, width: 1),
                                  ),
                                ),
                                onSubmitted: (value) {
                                  if (value.isNotEmpty) {
                                    setState(() {
                                      comments.add(Comment(username: 'Tu', text: value, likes: 0));
                                      commentCount++;
                                    });
                                    textController.clear();
                                  }
                                },
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Container(
                              padding: EdgeInsets.all(10), // Añade padding alrededor del ícono
                              decoration: BoxDecoration(
                                color: Colors.cyan, // Fondo cyan
                                shape: BoxShape.circle, // Forma circular
                              ),
                              child: Icon(
                                Icons.send,
                                color: Colors.white, // Ícono blanco
                                size: 20, // Tamaño del ícono
                              ),
                            ),
                            onPressed: () {
                              if (textController.text.isNotEmpty) {
                                setState(() {
                                  comments.add(Comment(username: 'Tu', text: textController.text, likes: 0));
                                  commentCount++;
                                });
                                textController.clear();
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    String formatCommentCount(int count) {
      if (count < 1000) return count.toString();
      if (count < 1000000) return '${(count / 1000).toStringAsFixed(1)}k';
      return '${(count / 1000000).toStringAsFixed(1)}M';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon:
              Icon(FontAwesomeIcons.commentDots, size: 23, color: Colors.grey),
          onPressed: () => openCommentsModal(context),
          padding: EdgeInsets.only(left: 12),
        ),
        Text(
          formatCommentCount(commentCount),
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}

class Comment {
  final String username;
  final String text;
  int likes;

  Comment({required this.username, required this.text, this.likes = 0});
}
