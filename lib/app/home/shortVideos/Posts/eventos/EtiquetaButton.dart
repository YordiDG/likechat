import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EtiquetaButton extends StatefulWidget {
  @override
  _EtiquetaButtonState createState() => _EtiquetaButtonState();
}

class _EtiquetaButtonState extends State<EtiquetaButton> {
  bool isBookmarked = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  void toggleBookmark() async {
    setState(() {
      isBookmarked = !isBookmarked;
    });

    // Intentar reproducir el sonido
    try {
      // Reproduce el sonido
      await _audioPlayer.play(
        AssetSource('lib/assets/sounds/toggle_sound.mp3'),
      );
      print('Sonido reproducido con éxito.');
    } catch (error) {
      print('Error al reproducir el sonido: $error');
    }

    // Mostrar el toast
    Fluttertoast.showToast(
      msg: isBookmarked ? "Etiqueta añadida" : "Etiqueta eliminada",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        isBookmarked ? Icons.bookmark : Icons.bookmark_border,
        color: isBookmarked ? Colors.orange : Colors.grey,
        size: 28,
      ),
      onPressed: toggleBookmark,
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Asegúrate de liberar recursos
    super.dispose();
  }
}
