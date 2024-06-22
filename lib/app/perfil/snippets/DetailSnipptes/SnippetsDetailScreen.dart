import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ImageDetailScreen extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImageDetailScreen({
    Key? key,
    required this.imageUrls,
    required this.initialIndex,
  }) : super(key: key);

  /*emoticones*/
  void _showLikeOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.thumb_up, color: Colors.blue, size: 30),
              Icon(Icons.favorite, color: Colors.red, size: 30),
              Icon(Icons.sentiment_very_satisfied,
                  color: Colors.green, size: 30),
              Icon(Icons.thumb_down_rounded,
                  color: Colors.lightBlueAccent, size: 30),
              Icon(Icons.sentiment_satisfied, color: Colors.black, size: 30),
              Icon(Icons.sentiment_dissatisfied,
                  color: Colors.orange, size: 30),
            ],
          ),
        );
      },
    );
  }

  /*comentarios*/
  void _showComments(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              color: Colors.white,
              child: ListView(
                controller: scrollController,
                children: [
                  Container(
                    color: Colors.white, // Fondo blanco
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Comentarios',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: Colors.black),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  _buildComment(
                      'Usuario 1', 'Este es un comentario.', 'Hace 1 hora'),
                  _buildComment(
                      'Usuario 2', 'Este es otro comentario.', 'Hace 2 horas'),
                  _buildComment('Usuario 3', '¡Gran foto!', 'Hace 3 horas'),
                  // Agrega más comentarios aquí
                  SizedBox(height: 80),
                  // Espacio adicional para evitar que los últimos comentarios se oculten por el teclado
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildComment(String userName, String comment, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 3.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: AssetImage('lib/assets/placeholder_user.jpg'),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          userName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        SizedBox(width: 8),
                        Text(
                          time,
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(comment, style: TextStyle(color: Colors.black)),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Lógica para dar like al comentario
                          },
                          child: Icon(Icons.favorite_border,
                              size: 16, color: Colors.grey),
                        ),
                        SizedBox(width: 4),
                        Text('Me gusta',
                            style: TextStyle(color: Colors.grey, fontSize: 12)),
                        SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            // Lógica para responder al comentario
                          },
                          child: Text('Responder',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(color: Colors.grey),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            title: Text('Publicaciones'),
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            pinned: true,
            floating: true,
            snap: true,
            backgroundColor: Colors.white,
            elevation: 0,
          ),
          SliverToBoxAdapter(
            child: RefreshIndicator(
              color: Colors.green,
              onRefresh: () async {
                await Future.delayed(Duration(seconds: 2));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Actualizado')),
                );
              },
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: AssetImage(
                                    'lib/assets/placeholder_user.jpg'), // Aquí debe ser la imagen del usuario
                              ),
                              SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        'Nombre del Usuario',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(width: 88),
                                      // Espacio ajustable según necesites
                                      Container(
                                        child: PopupMenuButton<String>(
                                          icon: Icon(Icons.more_vert,
                                              color: Colors.black),
                                          itemBuilder: (context) => [
                                            PopupMenuItem<String>(
                                              value: 'editar',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.edit,
                                                      color: Colors.black),
                                                  SizedBox(width: 8),
                                                  Text('Editar'),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem<String>(
                                              value: 'eliminar',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.delete,
                                                      color: Colors.black),
                                                  SizedBox(width: 8),
                                                  Text('Eliminar'),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem<String>(
                                              value: 'privado',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.lock,
                                                      color: Colors.black),
                                                  SizedBox(width: 8),
                                                  Text('Cambiar a privado'),
                                                ],
                                              ),
                                            ),
                                            PopupMenuItem<String>(
                                              value: 'publico',
                                              child: Row(
                                                children: [
                                                  Icon(Icons.public,
                                                      color: Colors.black),
                                                  SizedBox(width: 8),
                                                  Text('Cambiar a público'),
                                                ],
                                              ),
                                            ),
                                          ],
                                          onSelected: (String value) {
                                            // Manejar la selección del menú
                                            switch (value) {
                                              case 'editar':
                                                // Lógica para editar la publicación
                                                break;
                                              case 'eliminar':
                                                // Lógica para eliminar la publicación
                                                break;
                                              case 'privado':
                                                // Lógica para cambiar a privado
                                                break;
                                              case 'publico':
                                                // Lógica para cambiar a público
                                                break;
                                              default:
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Hace 2 horas',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      // Ajuste según necesites
                                      Icon(Icons.public,
                                          color: Colors.black, size: 16),
                                    ],
                                  )
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          Image.asset(
                            imageUrls[index],
                            fit: BoxFit.cover,
                          ),
                          SizedBox(height: 12),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Row(
                              children: [
                                GestureDetector(
                                  onTap: () => _showLikeOptions(context),
                                  child: Icon(Icons.favorite_border),
                                ),
                                SizedBox(width: 4),
                                Text('100',
                                    style: TextStyle(color: Colors.black)),
                                SizedBox(width: 16),
                                GestureDetector(
                                  onTap: () => _showComments(context),
                                  child: SvgPicture.asset(
                                    'lib/assets/message.svg',
                                    height: 24,
                                    width: 24,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(width: 4),
                                Text('50',
                                    style: TextStyle(color: Colors.black)),
                                SizedBox(width: 16),
                                Icon(Icons.send),
                                SizedBox(width: 4),
                                Text('20',
                                    style: TextStyle(color: Colors.black)),
                                Spacer(),
                                Icon(Icons.bookmark_border),
                              ],
                            ),
                          ),
                          SizedBox(height: 8),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'Descripción de la imagen o comentario del usuario aquí.',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.black),
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
