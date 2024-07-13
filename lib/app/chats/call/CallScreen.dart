import 'package:flutter/material.dart';

class CallScreen extends StatefulWidget {
  final String contactName;
  final String phoneNumber;

  CallScreen({required this.contactName, required this.phoneNumber});

  @override
  _CallScreenState createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool isMuted = false;
  bool isSpeakerOn = false;
  bool isOnHold = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contactName),
        backgroundColor: Colors.green, // Cambiar color de fondo del app bar a verde
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF075E54), Color(0xFF128C7E)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCircleIconButton(
                    icon: isMuted ? Icons.mic_off : Icons.mic,
                    color: Colors.white,
                    onPressed: () {
                      setState(() {
                        isMuted = !isMuted;
                        // Lógica para silenciar o reanudar el micrófono
                      });
                    },
                    tooltip: isMuted ? 'Activar micrófono' : 'Silenciar micrófono',
                  ),
                  _buildCircleIconButton(
                    icon: isSpeakerOn ? Icons.volume_up : Icons.volume_mute,
                    color: Colors.white,
                    onPressed: () {
                      setState(() {
                        isSpeakerOn = !isSpeakerOn;
                        // Lógica para activar o desactivar el altavoz
                      });
                    },
                    tooltip: isSpeakerOn ? 'Altavoz activado' : 'Activar altavoz',
                  ),
                  _buildCircleIconButton(
                    icon: isOnHold ? Icons.play_arrow : Icons.pause,
                    color: Colors.white,
                    onPressed: () {
                      setState(() {
                        isOnHold = !isOnHold;
                        // Lógica para poner en pausa o reanudar la llamada
                      });
                    },
                    tooltip: isOnHold ? 'Reanudar llamada' : 'Pausar llamada',
                  ),
                  _buildCircleIconButton(
                    icon: Icons.call_end,
                    color: Colors.red,
                    iconColor: Colors.white,
                    onPressed: () {
                      Navigator.pop(context); // Cerrar la pantalla de llamada
                    },
                    tooltip: 'Finalizar llamada',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
    Color? iconColor,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                size: 28,
                color: iconColor ?? Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
