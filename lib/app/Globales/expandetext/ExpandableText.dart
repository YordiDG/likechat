import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../estadoDark-White/DarkModeProvider.dart';

class ExpandableText extends StatefulWidget {
  final String text;
  const ExpandableText({required this.text, required TextStyle style});

  @override
  _ExpandableTextState createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final textColor = darkModeProvider.textColor;

    int? _maxLines = _isExpanded ? null : 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          style: TextStyle(fontSize: 14.0, color: textColor),
          maxLines: _maxLines,
          overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        if (widget.text.length > 100) // Mostrar botón si la descripción es larga
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isExpanded ? 'ver menos' : 'ver más',
                  style: TextStyle(
                    color: Colors.cyan,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  color: Colors.cyan,
                  size: 17.0,
                ),
              ],
            ),
          ),
      ],
    );
  }
}
