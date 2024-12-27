import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../Globales/estadoDark-White/DarkModeProvider.dart';

class MasOpcionesModal extends StatefulWidget {
  @override
  _MasOpcionesModalState createState() => _MasOpcionesModalState();
}

class _MasOpcionesModalState extends State<MasOpcionesModal>
    with SingleTickerProviderStateMixin {
  bool allowOthersToUpload = true;
  bool allowStickers = false;
  bool allowDuos = true;

  bool isPromoting = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final backgroundColor = darkModeProvider.backgroundColor;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(13.0), // Borde redondeado
      ),
      backgroundColor: backgroundColor,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Línea decorativa en la parte superior
            Container(
              width: 50,
              height: 6,
              margin: EdgeInsets.only(bottom: 16.0),
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent,
                borderRadius: BorderRadius.circular(3.0),
              ),
            ),

            // Título del modal
            Text(
              'Más opciones',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: textColor,
              ),
            ),

            SizedBox(height: 20.0),

            // Opciones del modal
            _buildOption(
              icon: Icons.more_time,
              title: 'Permitir que otros lo suban a su historia',
              switchValue: allowOthersToUpload,
              onChanged: (value) {
                setState(() {
                  allowOthersToUpload = value;
                });
              },
            ),
            _buildOption(
              icon: Icons.emoji_emotions,
              title: 'Permitir stickers',
              switchValue: allowStickers,
              onChanged: (value) {
                setState(() {
                  allowStickers = value;
                });
              },
            ),
            _buildOption(
              icon: Icons.all_inclusive,
              title: 'Permitir duos',
              switchValue: allowDuos,
              onChanged: (value) {
                setState(() {
                  allowDuos = value;
                });
              },
            ),

            SizedBox(height: 20.0),

            // Botón para promocionar contenido
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _controller.value * 10),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        isPromoting = !isPromoting;
                      });
                    },
                    icon: Icon(
                      Icons.campaign,
                      size: 28,
                      color: Colors.white,
                    ),
                    label: Text(
                      'Promocionar Contenido',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13.0),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                    ),
                  ),
                );
              },
            ),

            SizedBox(height: 10.0),
          ],
        ),
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required bool switchValue,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.lightBlueAccent,
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          SizedBox(width: 16.0),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600),
            ),
          ),
          Switch(
            value: switchValue,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: Colors.lightBlueAccent,
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}
