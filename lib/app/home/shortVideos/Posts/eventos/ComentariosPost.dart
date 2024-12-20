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
  int commentCount = 998; // Contador inicial de comentarios
  bool isLiked = false;
  bool isDisliked = false;

  List<Comment> comments = [
    Comment(username: 'Yordi Diaz', text: 'Comentario increíble', likes: 12),
    Comment(username: 'Esmeralda Aliaga', text: 'Beatifull', likes: 5),
    Comment(
        username: 'Maruja Gonzales',
        text:
            'Me gusta el paisaje j dnc sdcbs csd csd cds cdjscds n csjdbcs c sjdcs',
        likes: 8),
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
          initialChildSize: 0.65,
          minChildSize: 0.65,
          maxChildSize: 0.65,
          builder: (_, controller) {
            return Container(
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.grey.shade800.withOpacity(0.5)
                    : Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      margin: EdgeInsets.only(top: 8.0), // Espaciado superior
                      width: 45.0,
                      height: 3.0,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade500,
                        borderRadius: BorderRadius.circular(2.0),
                      ),
                    ),
                  ),
                  // Encabezado con contador de comentarios

                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2.0),
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
                                    : Colors.grey[100],
                                borderRadius: BorderRadius.circular(7),
                              ),
                              child: Text(
                                formatCommentCount(commentCount),
                                // Usamos la función para formatear
                                style: TextStyle(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w600, fontSize: 13
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Divider(
                    thickness: 0.2, // Grosor real de la línea
                    color: Colors.grey,
                  ),
                  // Lista de comentarios
                  Expanded(
                    child: ListView.builder(
                      controller: controller,
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        bool isTextExpanded =
                            false; // Para gestionar el estado expandido del texto

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 6.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 14.0,
                                backgroundColor: Colors.cyan[200],
                                child: Text(
                                  comment.username[0].toUpperCase(),
                                  style: TextStyle(fontSize: 12),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '${comment.username} ',
                                          style: GoogleFonts.roboto(
                                            fontWeight: FontWeight.bold,
                                            color: isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Spacer(),
                                        // Íconos de interacción
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              isLiked = !isLiked;
                                              if (isLiked) {
                                                isDisliked =
                                                    false; // Desmarca dislike si hay like
                                              }
                                            });
                                          },
                                          child: TweenAnimationBuilder(
                                            tween: ColorTween(
                                              begin: Colors.grey,
                                              end: isLiked
                                                  ? Colors.red
                                                  : Colors.grey,
                                            ),
                                            duration:
                                                Duration(milliseconds: 300),
                                            builder: (context, color, child) {
                                              return Icon(
                                                isLiked
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                size: 17,
                                                color: color,
                                              );
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              isDisliked = !isDisliked;
                                              if (isDisliked) {
                                                isLiked =
                                                    false; // Desmarca like si hay dislike
                                              }
                                            });
                                          },
                                          child: TweenAnimationBuilder(
                                            tween: ColorTween(
                                              begin: Colors.grey,
                                              end: isDisliked
                                                  ? Colors.cyan
                                                  : Colors.grey,
                                            ),
                                            duration:
                                                Duration(milliseconds: 300),
                                            builder: (context, color, child) {
                                              return Icon(
                                                isDisliked
                                                    ? Icons.thumb_down_alt
                                                    : Icons
                                                        .thumb_down_alt_outlined,
                                                size: 17,
                                                color: color,
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Contenedor limitado para el texto
                                    Container(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.65, // Limita el ancho
                                        maxHeight: isTextExpanded
                                            ? double.infinity
                                            : 60,
                                      ),
                                      child: Text(
                                        comment.text,
                                        maxLines: isTextExpanded ? null : 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.roboto(
                                          color: isDarkMode
                                              ? Colors.grey[300]
                                              : Colors.black87,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    if (comment.text.length > 100)
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            isTextExpanded = !isTextExpanded;
                                          });
                                        },
                                        child: Text(
                                          isTextExpanded
                                              ? 'Ver menos'
                                              : 'Ver más',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    Row(
                                      children: [
                                        Text(
                                          'Hace 2h',
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        SizedBox(width: 12),
                                        GestureDetector(
                                          onTap: () {},
                                          child: Text(
                                            'Responder',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                            ),
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

                  Container(
                    color: isDarkMode
                        ? Colors.grey.shade900.withOpacity(0.8)
                        : Colors.grey.shade200, // Fondo gris claro
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 16,
                          right: 16,
                          top: 8,
                          bottom: MediaQuery.of(context).viewInsets.bottom +
                              16, // Ajuste del padding cuando el teclado está visible
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          // Centra los elementos verticalmente
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: Colors.grey[400],
                              // Avatar gris por defecto
                              child: Icon(Icons.person,
                                  size: 20, color: Colors.white),
                            ),
                            SizedBox(width: 8),
                            // Espacio entre el avatar y el TextField
                            Flexible(
                              child: Container(
                                height: textController.text.isEmpty ? 40 : null,
                                // Establece una altura de 40 cuando está vacío
                                constraints: BoxConstraints(
                                  maxHeight:
                                      120, // Limita la altura a un máximo de 4 líneas
                                ),
                                child: TextField(
                                  controller: textController,
                                  minLines: 1,
                                  maxLines: 4,
                                  cursorColor: Colors.cyan,
                                  keyboardType: TextInputType.multiline,
                                  decoration: InputDecoration(
                                    hintText: 'Añadir un comentario...',
                                    hintStyle: TextStyle(
                                      color: isDarkMode
                                          ? Colors.grey[400]
                                          : Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    filled: true,
                                    fillColor: isDarkMode
                                        ? Colors.grey[800]
                                        : Colors.white,
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.cyan.withOpacity(0.5),
                                        width: 0.8, // Grosor del borde
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                        color: Colors.grey.withOpacity(0.5),
                                        // Gris con opacidad del 50%
                                        width: 0.5, // Grosor del borde
                                      ),
                                    ),
                                  ),
                                  onSubmitted: (value) {
                                    if (value.isNotEmpty) {
                                      setState(() {
                                        comments.add(Comment(
                                            username: 'Tu',
                                            text: value,
                                            likes: 0));
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
                                padding: EdgeInsets.all(9),
                                // Añade padding alrededor del ícono
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
                                    comments.add(Comment(
                                        username: 'Tu',
                                        text: textController.text,
                                        likes: 0));
                                    commentCount++;
                                  });
                                  textController.clear();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String formatCommentCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).round()} mill.'; // Formato: "1 mill"
    } else if (count >= 100000) {
      return '${(count / 1000).round()} mil'; // Formato: "100 mil"
    } else if (count >= 1000) {
      return '${(count / 1000).round()} mil'; // Formato: "1 mil"
    }
    return count.toString(); // Si es menos de 1000, muestra el número original
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
          icon: Icon(FontAwesomeIcons.commentDots,
              size: 23, color: Colors.grey.shade200),
          onPressed: () => openCommentsModal(context),
          padding: EdgeInsets.only(left: 12),
        ),
        Text(
          formatCommentCount(commentCount),
          style: TextStyle(
              color: Colors.grey.shade200, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}

class Comment {
  final String username;
  final String text;
  int likes;
  int dislikes;

  Comment(
      {required this.username,
      required this.text,
      this.likes = 0,
      this.dislikes = 0});
}
