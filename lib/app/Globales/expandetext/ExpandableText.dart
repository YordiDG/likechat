import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../FontApp/AppTypography.dart';
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

    // Obtenemos el TextTheme desde AppTypography
    final textTheme = AppTypography().getTextTheme(
      fontSize: fontSizeProvider.fontSize,
      isDarkMode: darkModeProvider.isDarkMode,  // Suponiendo que 'isDarkMode' es un bool que determina si es modo oscuro
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.text,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: AppTypography.light, // Establecemos el peso 'light'
                color: textColor,
                height: 1.3,
              ),
              maxLines: _isExpanded ? null : 2,
              overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
            if (widget.text.length > 100)
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    _isExpanded ? 'ver menos' : 'ver más',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.cyan,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
