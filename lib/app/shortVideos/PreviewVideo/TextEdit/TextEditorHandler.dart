import 'package:flutter/material.dart';
import 'package:text_editor/text_editor.dart';

class TextEditorHandler {
  void openTextEditor(BuildContext context, Function(String, TextStyle, TextAlign) setText) {
    List<String> fonts = [
      'OpenSans',
      'Billabong',
      'GrandHotel',
      'Oswald',
      'Quicksand',
      'BeautifulPeople',
      'BeautyMountains',
      'BiteChocolate',
      'BlackberryJam',
      'BunchBlossoms',
      'CinderelaRegular',
      'Countryside',
      'Halimun',
      'LemonJelly',
      'QuiteMagicalRegular',
      'Tomatoes',
      'TropicalAsianDemoRegular',
      'VeganStyle',
    ];

    TextStyle initialTextStyle = TextStyle(
      fontSize: 30,
      color: Colors.white,
      fontFamily: 'OpenSans', // Fuente predeterminada
    );

    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return Container(
          color: Colors.black.withOpacity(0.4),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Container(
                child: TextEditor(
                  fonts: fonts,
                  text: '', // Texto inicial
                  textStyle: initialTextStyle,
                  textAlingment: TextAlign.center, // Alineación predeterminada
                  minFontSize: 10,
                  onEditCompleted: (style, align, text) {
                    // Aplicar los cambios al texto y estilo
                    setText(text, style, align);
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
