import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notificaciones"),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          _buildNotificationItem(
            context,
            'assets/user1.jpg',
            'Juan Pérez',
            'Hace 2 minutos',
            'Alguien le dio like a tu publicación',
          ),
          _buildNotificationItem(
            context,
            'assets/user2.jpg',
            'María López',
            'Hace 1 hora',
            'Nuevo comentario en tu publicación',
          ),
          _buildNotificationItem(
            context,
            'assets/user3.jpg',
            'Carlos Rodríguez',
            'Hace 3 horas',
            'Te enviaron una solicitud de amistad',
          ),
          _buildNotificationItem(
            context,
            'assets/user4.jpg',
            'Grupo de Amigos',
            'Hace 5 horas',
            'Nuevo grupo creado',
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(
      BuildContext context,
      String photoUrl,
      String userName,
      String timeAgo,
      String action,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.0, // Tamaño de la foto
            backgroundImage: AssetImage(photoUrl),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  action,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  timeAgo,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.message, color: Colors.cyan),
            onPressed: () {
              // Redirige a la pantalla de mensajes (asegúrate de tener la ruta definida)
              Navigator.pushNamed(context, "/messages");
            },
          ),
        ],
      ),
    );
  }
}
