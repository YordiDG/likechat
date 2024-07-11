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
        backgroundColor: Colors.white,
        title: Text(
          'Más opciones',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(height: 1.0, color: Colors.grey),
            ListTile(
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
                  activeColor: Colors.white, // Color de fondo cuando activado
                  activeTrackColor: Colors.lightBlueAccent, // Color del riel cuando activado
                  inactiveThumbColor: Colors.grey, // Color del pulgar cuando desactivado
                  inactiveTrackColor: Colors.grey.withOpacity(0.5), // Color del riel cuando desactivado
                ),
              ),
            ),

            ListTile(
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
                  activeColor: Colors.white, // Color de fondo cuando activado
                  activeTrackColor: Colors.lightBlueAccent, // Color del riel cuando activado
                  inactiveThumbColor: Colors.grey, // Color del pulgar cuando desactivado
                  inactiveTrackColor: Colors.grey.withOpacity(0.5), // Color del riel cuando desactivado
                ),
              ),
            ),
            ListTile(
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
                  activeTrackColor: Colors.lightBlueAccent, // Color del riel cuando activado
                  inactiveThumbColor: Colors.grey, // Color del pulgar cuando desactivado
                  inactiveTrackColor: Colors.grey.withOpacity(0.5), // Color del riel cuando desactivado
                ),
              ),
            ),

            SizedBox(height: 29.0),
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
            Divider(height: 1.0, color: Colors.grey),
            SizedBox(height: 20.0),
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _controller.value * 10),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isPromoting = !isPromoting; // Cambia el estado de la animación
                        });

                        // Aquí puedes manejar la lógica para promocionar contenido
                        // Por ejemplo, abrir otra pantalla o ejecutar alguna acción
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0), // Reducir el radio del borde
                        ),
                        padding:
                        EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                      ),
                      child: Text(
                        'Promocionar Contenido',
                        style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 12.0),
          ],
        ),
      ),
    );
  }
}
