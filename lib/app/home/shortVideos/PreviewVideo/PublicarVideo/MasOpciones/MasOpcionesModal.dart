import 'package:flutter/material.dart';

class MasOpcionesModal extends StatefulWidget {
  @override
  _MasOpcionesModalState createState() => _MasOpcionesModalState();
}

class _MasOpcionesModalState extends State<MasOpcionesModal>
    with SingleTickerProviderStateMixin {
  bool allowOthersToUpload = true;
  bool allowStickers = false;
  bool allowDuos = true;

  bool isPromoting = false; // Estado para la animación del botón
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[600], // Fondo del AppBar gris claro
        centerTitle: true, // Centra el título
        title: Text(
          'Más opciones',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontSize: 21,
          ),
        ),
        elevation: 0, // Elimina la línea de sombra debajo del AppBar
        automaticallyImplyLeading: false, // Elimina la flecha de retroceso
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(height: 1.0, color: Colors.grey),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.lightBlueAccent,
                // Fondo negro con poca opacidad
                child: Icon(Icons.more_time,
                    color: Colors.white, size: 23), // Icono más pequeño
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              title: Text(
                'Permitir que otros lo suban a su historia',
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600),
              ),
              trailing: Transform.scale(
                scale: 0.9, // Escala del Switch para ajustar tamaño
                child: Switch(
                  value: allowOthersToUpload,
                  onChanged: (value) {
                    setState(() {
                      allowOthersToUpload = value;
                    });
                  },
                  activeColor: Colors.white,
                  // Color de fondo cuando activado
                  activeTrackColor: Colors.lightBlueAccent,
                  // Color del riel cuando activado
                  inactiveThumbColor: Colors.grey,
                  // Color del pulgar cuando desactivado
                  inactiveTrackColor: Colors.grey
                      .withOpacity(0.5), // Color del riel cuando desactivado
                ),
              ),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.lightBlueAccent,
                child:
                    Icon(Icons.emoji_emotions, color: Colors.white, size: 23),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              title: Text(
                'Permitir stickers',
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600),
              ),
              trailing: Transform.scale(
                scale: 0.9, // Escala del Switch para ajustar tamaño
                child: Switch(
                  value: allowStickers,
                  onChanged: (value) {
                    setState(() {
                      allowStickers = value;
                    });
                  },
                  activeColor: Colors.white,
                  // Color de fondo cuando activado
                  activeTrackColor: Colors.lightBlueAccent,
                  // Color del riel cuando activado
                  inactiveThumbColor: Colors.grey,
                  // Color del pulgar cuando desactivado
                  inactiveTrackColor: Colors.grey
                      .withOpacity(0.5), // Color del riel cuando desactivado
                ),
              ),
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.lightBlueAccent,
                child: Icon(Icons.all_inclusive, color: Colors.white, size: 23),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
              title: Text(
                'Permitir duos',
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w600),
              ),
              trailing: Transform.scale(
                scale: 0.9, // Escala del Switch para ajustar tamaño
                child: Switch(
                  value: allowDuos,
                  onChanged: (value) {
                    setState(() {
                      allowDuos = value;
                    });
                  },
                  activeColor: Colors.white,
                  activeTrackColor: Colors.lightBlueAccent,
                  // Color del riel cuando activado
                  inactiveThumbColor: Colors.grey,
                  // Color del pulgar cuando desactivado
                  inactiveTrackColor: Colors.grey
                      .withOpacity(0.5), // Color del riel cuando desactivado
                ),
              ),
            ),
            SizedBox(height: 20.0),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Text(
                'Ajustes Avanzados',
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _controller.value * 10),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          isPromoting =
                              !isPromoting; // Cambia el estado de la animación
                        });

                        // Aquí puedes manejar la lógica para promocionar contenido
                        // Por ejemplo, abrir otra pantalla o ejecutar alguna acción
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
                          borderRadius: BorderRadius.circular(
                              8.0), // Reducir el radio del borde
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 24.0),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
