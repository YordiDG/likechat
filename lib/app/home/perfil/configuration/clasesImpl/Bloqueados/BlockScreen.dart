import 'package:flutter/material.dart';

class BlockScreen extends StatefulWidget {
  final Color tileColor;
  final Color textColor;
  final double fontSize;

  BlockScreen({
    required this.tileColor,
    required this.textColor,
    required this.fontSize,
  });

  @override
  _BlockScreenState createState() => _BlockScreenState();
}

class _BlockScreenState extends State<BlockScreen> {
  List<Map<String, String>> blockedUsers = [
    {'name': 'Usuario1', 'imageUrl': 'assets/user1.jpg'},
    {'name': 'Usuario2', 'imageUrl': 'assets/user2.jpg'},
    {'name': 'Usuario3', 'imageUrl': 'assets/user3.jpg'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bloqueos'),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () {
              _showClearAllDialog(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Usuarios Bloqueados',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: widget.textColor,
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: blockedUsers.length,
                itemBuilder: (context, index) {
                  final user = blockedUsers[index];
                  return _buildBlockItem(
                    userName: user['name']!,
                    imageUrl: user['imageUrl']!,
                    onUnblock: () {
                      _showUnblockDialog(context, user['name']!);
                    },
                    onDelete: () {
                      _showDeleteDialog(context, user['name']!);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockItem({
    required String userName,
    required String imageUrl,
    required VoidCallback onUnblock,
    required VoidCallback onDelete,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.grey.shade300, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16.0),
        leading: CircleAvatar(
          backgroundImage: AssetImage(imageUrl),
          radius: 24.0,
        ),
        title: Text(
          userName,
          style: TextStyle(
            fontSize: widget.fontSize,
            fontWeight: FontWeight.bold,
            color: widget.textColor,
          ),
        ),
        subtitle: Text(
          'Fecha: 01/01/2024\nHora: 12:00 PM',
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12.0),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.remove_circle, color: Colors.redAccent),
              onPressed: onUnblock,
            ),
            SizedBox(width: 8.0),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.redAccent),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }

  void _showUnblockDialog(BuildContext context, String userName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Desbloquear $userName'),
          content: Text('¿Estás seguro de que quieres desbloquear a $userName?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  blockedUsers.removeWhere((user) => user['name'] == userName);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$userName ha sido desbloqueado')),
                );
              },
              child: Text('Desbloquear'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, String userName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar $userName'),
          content: Text('¿Estás seguro de que quieres eliminar a $userName de los bloqueos?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  blockedUsers.removeWhere((user) => user['name'] == userName);
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$userName ha sido eliminado')),
                );
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  void _showClearAllDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar Todos los Bloqueos'),
          content: Text('¿Estás seguro de que quieres eliminar todos los usuarios bloqueados?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  blockedUsers.clear();
                });
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Todos los bloqueos han sido eliminados')),
                );
              },
              child: Text('Eliminar Todos'),
            ),
          ],
        );
      },
    );
  }
}
