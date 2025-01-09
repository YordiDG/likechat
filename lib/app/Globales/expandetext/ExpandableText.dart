import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../estadoDark-White/DarkModeProvider.dart';
import '../estadoDark-White/Fuentes/FontSizeProvider.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  const ExpandableText({required this.text, Key? key}) : super(key: key);

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final textColor = darkModeProvider.textColor;

    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    int? _maxLines = _isExpanded ? null : 2;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              textAlign: TextAlign.justify,  // Justificar el texto
              text: TextSpan(
                style: TextStyle(
                  fontSize: fontSizeProvider.fontSize,
                  color: textColor,
                  height: 1.5,
                ),
                children: [
                  TextSpan(
                    text: _isExpanded
                        ? widget.text
                        : widget.text.length > 100
                        ? widget.text.substring(0, 100) + '... '
                        : widget.text,
                  ),
                  if (widget.text.length > 100)
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _isExpanded = !_isExpanded;
                          });
                        },
                        child: Text(
                          _isExpanded ? 'ver menos' : 'ver más',
                          style: TextStyle(
                            color: Colors.cyan,
                            fontSize: fontSizeProvider.fontSize - 1,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              maxLines: _maxLines,
              overflow: TextOverflow.clip,
            ),
          ],
        );
      },
    );
  }
}
