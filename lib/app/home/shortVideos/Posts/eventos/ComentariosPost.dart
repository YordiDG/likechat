import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../../Globales/estadoDark-White/DarkModeProvider.dart';

class ComentariosPost extends StatelessWidget {
  final int commentCount;

  ComentariosPost({this.commentCount = 999999});

  String formatCommentCount(int count) {
    if (count >= 1000000) {
      return '${(count ~/ 1000000)} mill.';
    } else if (count >= 1000) {
      return '${(count ~/ 1000)} mil';
    }
    return count.toString();
  }

  void _showCommentsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        minChildSize: 0.65,
        maxChildSize: 0.65,
        builder: (context, scrollController) {
          return ComentariosPostModal(commentCount: commentCount);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCommentsModal(context),
      // Detecta toques en toda el área
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            FontAwesomeIcons.commentDots,
            color: Colors.grey.shade200,
            size: 29,
          ),
          SizedBox(width: 5), // Espacio mínimo entre el icono y el texto
          Text(
            formatCommentCount(commentCount),
            style: TextStyle(
              color: Colors.grey.shade200,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class ComentariosPostModal extends StatefulWidget {
  final int commentCount;

  ComentariosPostModal({required this.commentCount});

  @override
  _ComentariosPostModalState createState() => _ComentariosPostModalState();
}

class _ComentariosPostModalState extends State<ComentariosPostModal> {
  bool isLiked = false;
  bool isDisliked = false;
  late int commentCount;
  final textController = TextEditingController();

  List<Comment> comments = [
    Comment(username: 'Yordi Diaz', text: 'Comentario increíble', likes: 12),
    Comment(username: 'Esmeralda Aliaga', text: 'Beatifull', likes: 5),
    Comment(
        username: 'Maruja Gonzales',
        text:
            'Me gusta el paisaje j dnc sdcbs csd csd cds cdjscds n csjdbcs c sjdcs',
        likes: 8),
  ];

  @override
  void initState() {
    super.initState();
    commentCount = widget.commentCount;
  }

  String formatCommentCount(int count) {
    if (count >= 1000000) {
      return '${(count ~/ 1000000)} mill.';
    } else if (count >= 1000) {
      return '${(count ~/ 1000)} mil';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider =
        Provider.of<DarkModeProvider>(context, listen: false);
    final isDarkMode = darkModeProvider.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        color:
            isDarkMode ? Colors.grey.shade800.withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Barra de arrastre
          Center(
            child: Container(
              margin: EdgeInsets.only(top: 8.0),
              width: 45.0,
              height: 3.0,
              decoration: BoxDecoration(
                color: Colors.grey.shade500,
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
          ),
          // Encabezado
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  FontAwesomeIcons.commentDots,
                  size: 25,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                SizedBox(width: 8),
                Text(
                  'Comentarios',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    formatCommentCount(commentCount),
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(thickness: 0.2, color: Colors.grey),
          // Lista de comentarios
          Expanded(
            child: ListView.builder(
              itemCount: comments.length,
              itemBuilder: (context, index) {
                final comment = comments[index];
                return CommentItem(
                  comment: comment,
                  isDarkMode: isDarkMode,
                  onLikePressed: () {
                    setState(() {
                      isLiked = !isLiked;
                      if (isLiked) isDisliked = false;
                    });
                  },
                  onDislikePressed: () {
                    setState(() {
                      isDisliked = !isDisliked;
                      if (isDisliked) isLiked = false;
                    });
                  },
                  isLiked: isLiked,
                  isDisliked: isDisliked,
                );
              },
            ),
          ),
          // Campo de comentario
          CommentInputField(
            textController: textController,
            isDarkMode: isDarkMode,
            onSubmitted: (text) {
              if (text.isNotEmpty) {
                setState(() {
                  comments.add(Comment(
                    username: 'Tu',
                    text: text,
                    likes: 0,
                  ));
                  commentCount++;
                });
                textController.clear();
              }
            },
          ),
        ],
      ),
    );
  }
}

// Widget para cada comentario individual
class CommentItem extends StatelessWidget {
  final Comment comment;
  final bool isDarkMode;
  final VoidCallback onLikePressed;
  final VoidCallback onDislikePressed;
  final bool isLiked;
  final bool isDisliked;

  const CommentItem({
    required this.comment,
    required this.isDarkMode,
    required this.onLikePressed,
    required this.onDislikePressed,
    required this.isLiked,
    required this.isDisliked,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
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
          FractionallySizedBox(
            widthFactor: 0.8, // Establece el ancho al 80% de la pantalla
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${comment.username} ',
                      style: GoogleFonts.roboto(
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 13,
                      ),
                    ),
                    Spacer(),
                    LikeButton(
                      isLiked: isLiked,
                      onPressed: onLikePressed,
                    ),
                    SizedBox(width: 8),
                    DislikeButton(
                      isDisliked: isDisliked,
                      onPressed: onDislikePressed,
                    ),
                  ],
                ),
                Text(
                  comment.text,
                  style: GoogleFonts.roboto(
                    color: isDarkMode ? Colors.grey[300] : Colors.black87,
                    fontSize: 13,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      'Hace 2h',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
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
  }

}

// Campo de entrada de comentarios
class CommentInputField extends StatefulWidget {
  final TextEditingController textController;
  final bool isDarkMode;
  final Function(String) onSubmitted;

  const CommentInputField({
    super.key,
    required this.textController,
    required this.isDarkMode,
    required this.onSubmitted,
  });

  @override
  State<CommentInputField> createState() => _CommentInputFieldState();
}

class _CommentInputFieldState extends State<CommentInputField>
    with SingleTickerProviderStateMixin {
  bool _isTextFieldFocused = false;
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _heightAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _heightAnimation = Tween<double>(begin: 48, end: 120).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleFocus(bool hasFocus) {
    setState(() {
      _isTextFieldFocused = hasFocus;
      if (hasFocus) {
        _isExpanded = true;
        _animationController.forward();
      } else if (widget.textController.text.isEmpty) {
        _isExpanded = false;
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: widget.isDarkMode
            ? Colors.grey.shade900.withOpacity(0.95)
            : Colors.grey.shade200,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            MediaQuery.of(context).viewInsets.bottom + 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _heightAnimation,
                builder: (context, child) {
                  return Container(
                    constraints: BoxConstraints(
                      maxHeight: _heightAnimation.value,
                    ),
                    decoration: BoxDecoration(
                      color: widget.isDarkMode
                          ? Colors.grey.shade800
                          : Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: _isExpanded
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(6),
                          child: CircleAvatar(
                            radius: 16,
                            backgroundColor: widget.isDarkMode
                                ? Colors.grey.shade700
                                : Colors.grey.shade200,
                            child: Icon(
                              Icons.person,
                              size: 24,
                              color: widget.isDarkMode
                                  ? Colors.grey.shade300
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: widget.textController,
                            maxLines: _isExpanded ? 5 : 1,
                            minLines: 1,
                            cursorColor: Colors.cyan,
                            style: TextStyle(
                              fontSize: 14,
                              color: widget.isDarkMode
                                  ? Colors.grey.shade100
                                  : Colors.grey.shade900,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Añadir comentario...',
                              hintStyle: TextStyle(
                                color: widget.isDarkMode
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade500,
                                fontSize: 15,
                              ),
                              border: InputBorder.none, // Esto elimina el borde
                              focusedBorder: InputBorder.none, // Asegura que no haya borde cuando tenga el foco
                              enabledBorder: InputBorder.none, // También elimina el borde cuando el campo no tiene foco
                              fillColor: Colors.transparent, // Fondo transparente
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 8,
                                horizontal: 8,
                              ),
                            ),
                          ),
                        ),
                        if (!_isTextFieldFocused) ...[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            // Ocupa solo el espacio necesario
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // Llamar a una clase o evento específico
                                  print('Ícono de Alternar Email presionado');
                                },
                                child: Icon(
                                  Icons.alternate_email,
                                  color: widget.isDarkMode
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                  size: 30,
                                ),
                              ),
                              SizedBox(width: 13),
                              GestureDetector(
                                onTap: () {
                                  // Llamar a una clase o evento específico
                                  print('Ícono de Emojis presionado');
                                },
                                child: Icon(
                                  Icons.emoji_emotions_outlined,
                                  color: widget.isDarkMode
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                  size: 30,
                                ),
                              ),
                              SizedBox(width: 12,),
                              GestureDetector(
                                onTap: () {
                                  // Llamar a una clase o evento específico
                                  print('Ícono de Fotos presionado');
                                },
                                child: Icon(
                                  Icons.photo,
                                  color: widget.isDarkMode
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                  size: 30,
                                ),
                              ),
                              SizedBox(width: 12,),
                            ],
                          ),
                        ] else
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: IconButton(
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.cyan,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.send_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                              onPressed: () {
                                if (widget.textController.text
                                    .trim()
                                    .isNotEmpty) {
                                  widget
                                      .onSubmitted(widget.textController.text);
                                  widget.textController.clear();
                                  setState(() {
                                    _isExpanded = false;
                                    _animationController.reverse();
                                  });
                                }
                              },
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    IconButton.filled(
                      icon: const Icon(Icons.photo_camera_rounded, size: 20),
                      onPressed: () {
                        // Implementar captura de foto
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.cyan.withOpacity(0.1),
                        foregroundColor: Colors.cyan,
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton.filled(
                      icon: const Icon(Icons.image_rounded, size: 20),
                      onPressed: () {
                        // Implementar selector de imagen
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.cyan.withOpacity(0.1),
                        foregroundColor: Colors.cyan,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class LikeButton extends StatelessWidget {
  final bool isLiked;
  final VoidCallback onPressed;

  const LikeButton({
    required this.isLiked,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: TweenAnimationBuilder(
        tween: ColorTween(
          begin: Colors.grey,
          end: isLiked ? Colors.red : Colors.grey,
        ),
        duration: Duration(milliseconds: 300),
        builder: (context, color, child) {
          return Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            size: 17,
            color: color as Color?,
          );
        },
      ),
    );
  }
}

class DislikeButton extends StatelessWidget {
  final bool isDisliked;
  final VoidCallback onPressed;

  const DislikeButton({
    required this.isDisliked,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: TweenAnimationBuilder(
        tween: ColorTween(
          begin: Colors.grey,
          end: isDisliked ? Colors.cyan : Colors.grey,
        ),
        duration: Duration(milliseconds: 300),
        builder: (context, color, child) {
          return Icon(
            isDisliked ? Icons.thumb_down_alt : Icons.thumb_down_alt_outlined,
            size: 17,
            color: color as Color?,
          );
        },
      ),
    );
  }
}

class Comment {
  final String username;
  final String text;
  int likes;
  int dislikes;

  Comment({
    required this.username,
    required this.text,
    this.likes = 0,
    this.dislikes = 0,
  });
}
