import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EtiquetaButton extends StatefulWidget {
  @override
  _EtiquetaButtonState createState() => _EtiquetaButtonState();
}

class _EtiquetaButtonState extends State<EtiquetaButton> {
  bool isBookmarked = false;
  int bookmarkCount = 10500; // Contador inicial, representado como 10.5k
  final AudioPlayer _audioPlayer = AudioPlayer();

  void toggleBookmark() async {
    setState(() {
      isBookmarked = !isBookmarked;
      bookmarkCount += isBookmarked ? 1 : -1; // Incrementa o decrementa el contador
    });

    try {
      await _audioPlayer.play(
        AssetSource('lib/assets/sounds/togglesound.mp3'),
      );
    } catch (error) {
      print('Error al reproducir el sonido: $error');
    }

    Fluttertoast.showToast(
      msg: isBookmarked ? "Etiqueta añadida" : "Etiqueta eliminada",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey.shade700,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          padding: EdgeInsets.zero, // Eliminar padding en IconButton
          icon: Icon(
            isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            color: isBookmarked ? Colors.orange : Colors.grey,
            size: 20,
          ),
          onPressed: toggleBookmark,
        ),
      ],
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

//icono de dislike

class DislikeButtons extends StatefulWidget {
  final ValueChanged<bool>? onDislikeUpdated;

  const DislikeButtons({Key? key, this.onDislikeUpdated}) : super(key: key);

  @override
  _DislikeButtonState createState() => _DislikeButtonState();
}

class _DislikeButtonState extends State<DislikeButtons> {
  bool isDisliked = false;
  int dislikeCount = 39999; // Contador inicial, representado como 870 mil

  void toggleDislike() {
    setState(() {
      isDisliked = !isDisliked;
      dislikeCount += isDisliked ? 1 : -1;

      // Notifica si existe un callback
      widget.onDislikeUpdated?.call(isDisliked);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: toggleDislike,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            isDisliked ? Icons.thumb_down : Icons.thumb_down_alt_outlined,
            color: isDisliked ? Colors.cyan : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 4), // Espacio entre el icono y el texto
          Text(
            formatDislikeCount(dislikeCount),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  String formatDislikeCount(int count) {
    if (count >= 1000000) {
      // Redondea y elimina decimales para millones
      return '${count ~/ 1000000} mill.';
    } else if (count >= 1000) {
      // Redondea y elimina decimales para miles
      return '${count ~/ 1000} mil';
    }
    return count.toString(); // Devuelve el número entero para valores menores a 1000
  }
}

