import 'package:flutter/material.dart';
import 'package:text_editor/text_editor.dart';

class TextEditorHandler {
  void openTextEditor(BuildContext context, Function(String, TextStyle, TextAlign) setText) {
    List<String> fonts = [
      'Poppins', 'Oswald', 'Billabong', 'Quicksand', 'Anton', 'Antonella', 'Antonellie Callygraphy Demo',
      'Antonine Personal Use', 'Badgear Script DEMO', 'Badrudin-Script', 'BebasNeue-Regular', 'Julia Antonio',
      'Latton', 'Pacifico', 'Sacramento', 'Lobster 1.4', 'Miss Antonia', 'Naishila Dancing Script', 'Rick Lobster',
      'San Antonio Charros_personal_use_only', 'Spiny Lobster DEMO', 'Yakuza Lobster'
    ];

    TextStyle initialTextStyle = TextStyle(
      fontSize: 30,
      color: Colors.white,
      fontFamily: 'Poppins',
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return Scaffold(
          backgroundColor: Colors.black.withOpacity(0.4),
          body: SafeArea(
            child: Stack(
              children: [
                // Aquí colocamos el video u otro contenido en el fondo

                DraggableTextEditor(
                  fonts: fonts,
                  initialTextStyle: initialTextStyle,
                  onTextEditCompleted: (style, align, text) {
                    setText(text, style, align);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DraggableTextEditor extends StatefulWidget {
  final List<String> fonts;
  final TextStyle initialTextStyle;
  final void Function(TextStyle, TextAlign, String) onTextEditCompleted;

  DraggableTextEditor({
    required this.fonts,
    required this.initialTextStyle,
    required this.onTextEditCompleted,
  });

  @override
  _DraggableTextEditorState createState() => _DraggableTextEditorState();
}

class _DraggableTextEditorState extends State<DraggableTextEditor> {
  Offset _offset = Offset.zero;
  String _text = '';
  late TextStyle _textStyle;

  @override
  void initState() {
    super.initState();
    _textStyle = widget.initialTextStyle;
  }

  void _updateTextPosition(Offset newOffset) {
    setState(() {
      _offset = newOffset;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Stack(
      children: [
        Positioned(
          left: _offset.dx,
          top: _offset.dy,
          child: GestureDetector(
            onPanUpdate: (details) {
              final newOffset = Offset(
                (_offset.dx + details.delta.dx).clamp(0, screenSize.width - 100),
                (_offset.dy + details.delta.dy).clamp(0, screenSize.height - 100),
              );
              _updateTextPosition(newOffset);
            },
            child: Container(
              padding: EdgeInsets.all(8),
              color: Colors.transparent,
              child: Text(
                _text,
                style: _textStyle,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: TextEditor(
            fonts: widget.fonts,
            text: _text,
            textStyle: _textStyle,
            textAlingment: TextAlign.center,
            minFontSize: 10,
            onEditCompleted: (style, align, newText) {
              setState(() {
                _text = newText;
                _textStyle = style;
              });
              widget.onTextEditCompleted(style, align, newText);
            },
          ),
        ),
      ],
    );
  }
}
