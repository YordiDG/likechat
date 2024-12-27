import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../APIS-Consumir/Tenor API/StickerModal.dart';
import '../../../../Globales/estadoDark-White/DarkModeProvider.dart';
import '../OpenCamara/preview/configuracion/EtiquetasAmigos/FriendsModal.dart';

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
            color: Colors.grey,
            size: 24,
          ),
          SizedBox(width: 4), // Espacio mínimo entre el icono y el texto
          Text(
            formatCommentCount(commentCount),
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class Comment {
  final String username;
  final String text;
  int likes;
  bool isLiked;
  bool isDisliked;

  Comment({
    required this.username,
    required this.text,
    this.likes = 0,
    this.isLiked = false,
    this.isDisliked = false,
  });
}

class ComentariosPostModal extends StatefulWidget {
  final int commentCount;

  ComentariosPostModal({required this.commentCount});

  @override
  _ComentariosPostModalState createState() => _ComentariosPostModalState();
}

class _ComentariosPostModalState extends State<ComentariosPostModal> {
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

  void handleLikePressed(int index) {
    setState(() {
      comments[index].isLiked = !comments[index].isLiked;
      if (comments[index].isLiked) {
        comments[index].likes++;
        comments[index].isDisliked = false;
      } else {
        comments[index].likes--;
      }
    });
  }

  void handleDislikePressed(int index) {
    setState(() {
      comments[index].isDisliked = !comments[index].isDisliked;
      if (comments[index].isDisliked) {
        if (comments[index].isLiked) {
          comments[index].likes--;
        }
        comments[index].isLiked = false;
      }
    });
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
            child: Container(
              constraints: BoxConstraints.expand(),
              child: ListView.builder(
                shrinkWrap: true,
                physics: AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  final comment = comments[index];
                  return CommentItem(
                    comment: comment,
                    isDarkMode: isDarkMode,
                    onLikePressed: () => handleLikePressed(index),
                    onDislikePressed: () => handleDislikePressed(index),
                    isLiked: comment.isLiked,
                    isDisliked: comment.isDisliked,
                  );
                },
              ),
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
class CommentItem extends StatefulWidget {
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
  _CommentItemState createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minHeight: 50),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 14.0,
              backgroundColor: Colors.cyan[200],
              child: Text(
                widget.comment.username[0].toUpperCase(),
                style: TextStyle(fontSize: 12),
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              flex: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          '${widget.comment.username} ',
                          style: GoogleFonts.roboto(
                            fontWeight: FontWeight.bold,
                            color: widget.isDarkMode ? Colors.white : Colors.black,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      LikeButton(
                        isLiked: widget.isLiked,
                        onPressed: widget.onLikePressed,
                      ),
                      SizedBox(width: 8),
                      DislikeButton(
                        isDisliked: widget.isDisliked,
                        onPressed: widget.onDislikePressed,
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Text(
                      widget.comment.text,
                      style: GoogleFonts.roboto(
                        color: widget.isDarkMode ? Colors.grey[300] : Colors.black87,
                        fontSize: 13,
                      ),
                      maxLines: _isExpanded ? null : 3,
                      overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
                    ),
                  ),
                  if (widget.comment.text.length > 100)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      child: Text(
                        _isExpanded ? 'Ver menos' : 'Ver más',
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '2h',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 12),
                      GestureDetector(
                        onTap: () {
                          // Acción para responder
                        },
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
  late FocusNode _focusNode;

  final int _maxCharacters = 180;
  bool _hasShownToast = false;

  final GalleryPicker galleryPicker = GalleryPicker();

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      _handleFocus(_focusNode.hasFocus);
    });

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
    _focusNode.dispose();
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

  void _handleTextChanged(String text) {
    if (text.length > _maxCharacters) {
      if (!_hasShownToast) {
        Fluttertoast.showToast(
          msg: "Has alcanzado el máximo de caracteres",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.grey.shade800,
          textColor: Colors.white,
          fontSize: 13.0,
        );
        _hasShownToast = true;
      }
      // Evita que se sigan agregando caracteres
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.textController.text = text.substring(0, _maxCharacters);
        widget.textController.selection = TextSelection.fromPosition(
          TextPosition(offset: _maxCharacters),
        );
      });
    } else {
      _hasShownToast = false;
    }
  }

  @override
  Widget build(BuildContext context) {
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: AnimatedBuilder(
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
                                  focusNode: _focusNode,
                                  controller: widget.textController,
                                  onChanged: _handleTextChanged,
                                  maxLines: 4,
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
                                    border: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    fillColor: Colors.transparent,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 8,
                                    ),
                                  ),
                                ),
                              ),
                              if (!_isTextFieldFocused &&
                                  widget.textController.text.isEmpty) ...[
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (context) => FriendsModales(),
                                        );
                                      },
                                      child: Icon(
                                        Icons.alternate_email,
                                        color: widget.isDarkMode
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade600,
                                        size: 28,
                                      ),
                                    ),
                                    SizedBox(width: 13),
                                    GestureDetector(
                                      onTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          builder: (context) => StickerModal(),
                                        );
                                      },
                                      child: Icon(
                                        Icons.emoji_emotions_outlined,
                                        color: widget.isDarkMode
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade600,
                                        size: 28,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    GestureDetector(
                                      onTap: () async {
                                        await galleryPicker.openGallery(context);
                                      },
                                      child: Icon(
                                        Icons.photo,
                                        color: widget.isDarkMode
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade600,
                                        size: 28,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  if (_isTextFieldFocused ||
                      widget.textController.text.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Center(
                      child: Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: Colors.cyan,
                          shape: BoxShape.circle, // Hace que el contenedor sea circular.
                        ),
                        child: Material(
                          color: Colors.transparent, // Fondo transparente para el efecto de "ripple".
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24), // Asegura el borde redondeado del efecto ripple.
                            onTap: () {
                              if (widget.textController.text.trim().isNotEmpty) {
                                widget.onSubmitted(widget.textController.text);
                                widget.textController.clear();
                                setState(() {
                                  _isExpanded = false;
                                  _animationController.reverse();
                                });
                              }
                            },
                            child: Center(
                              child: Icon(
                                Icons.send_rounded,
                                color: Colors.white,
                                size: 24, // Tamaño del ícono.
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
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
            size: 21,
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
            size: 21,
            color: color as Color?,
          );
        },
      ),
    );
  }
}


//clase de galeria
class GalleryPicker {
  final ImagePicker _picker = ImagePicker();

  Future<void> openGallery(BuildContext context) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      print('Imagen seleccionada: ${image.path}');
      // Puedes agregar aquí la lógica para mostrar o procesar la imagen seleccionada
    } else {
      print('No se seleccionó ninguna imagen.');
    }
  }
}
