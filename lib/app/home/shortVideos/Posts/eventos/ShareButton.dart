import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:device_apps/device_apps.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';

class ShareButton extends StatelessWidget {
  void _showFriendsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.5,
        // Ajustado a 2/4 de la pantalla (50%)
        builder: (context, scrollController) {
          return FriendsModal(scrollController: scrollController);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        FontAwesomeIcons.paperPlane,
        color: Colors.grey,
        size: 23,
      ),
      onPressed: () => _showFriendsModal(context),
    );
  }
}

class FriendsModal extends StatefulWidget {
  final ScrollController scrollController;

  FriendsModal({required this.scrollController});

  @override
  _FriendsModalState createState() => _FriendsModalState();
}

class _FriendsModalState extends State<FriendsModal> {
  List<Map<String, String>> friends = [];
  List<ApplicationWithIcon> installedApps = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFriends();
    fetchInstalledApps();
  }

  Future<void> fetchFriends() async {
    try {
      final response =
          await http.get(Uri.parse('https://randomuser.me/api/?results=50'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          friends = (data['results'] as List).map<Map<String, String>>((user) {
            return {
              "name": "${user['name']['first']} ${user['name']['last']}",
              "image": user['picture']['medium'],
            };
          }).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load friends');
      }
    } catch (error) {
      print('Error: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchInstalledApps() async {
    try {
      final apps = await DeviceApps.getInstalledApplications(
        includeAppIcons: true,
        includeSystemApps: false,
      );

      print("Apps instaladas: ${apps.map((app) => app.appName).toList()}");

      setState(() {
        installedApps = apps.cast<ApplicationWithIcon>();
      });
    } catch (error) {
      print("Error al obtener las apps instaladas: $error");
    }
  }

  void _copyLink() {
    Clipboard.setData(ClipboardData(text: "https://likechat.com.pe/user01"));
    Fluttertoast.showToast(
      msg: "¡Enlace copiado al portapapeles!",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _shareLink() {
    Share.share("https://likechat.com.pe/user12", subject: "Mira este enlace");
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: widget.scrollController,
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _FixedHeaderDelegate(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.vertical(
                    top: Radius.circular(10)), // Rounded corners
              ),
              padding: EdgeInsets.all(16),
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      "Compartir con",
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Icon(FontAwesomeIcons.close, size: 17),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            color: Colors.white, // Color de fondo
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 4),
                isLoading
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          // Padding alrededor del círculo
                          child: SizedBox(
                            height: 25,
                            width: 25,
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.cyan),
                              strokeWidth: 2.6,
                            ),
                          ),
                        ),
                      )
                    : CarouselSlider.builder(
                        itemCount: friends.length,
                        options: CarouselOptions(
                          height: 98,
                          // Altura del carrusel
                          viewportFraction: 0.2,
                          // Reducido aún más para unir los elementos
                          enableInfiniteScroll: true,
                          autoPlayInterval: Duration(seconds: 3),
                          padEnds: false, // Sin padding en los extremos
                        ),
                        itemBuilder: (context, index, realIndex) {
                          final friend = friends[index];
                          return Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                    width: 0.3,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 27,
                                  backgroundImage:
                                      NetworkImage(friend['image']!),
                                ),
                              ),
                              SizedBox(height: 5),
                              SizedBox(
                                width: 60, // Limita el ancho del texto
                                child: Text(
                                  friend['name']!,
                                  style: TextStyle(fontSize: 10, ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                Divider(
                  height: 1, // Altura total
                  thickness: 0.2, // Grosor real de la línea
                  color: Colors.grey,
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    "Herramientas de Interacción",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade500),
                  ),
                ),
                SizedBox(height: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildAppIconEvent(
                            FontAwesomeIcons.solidFlag,
                            Colors.grey.withOpacity(0.2),
                            "Denunciar",
                            _reportPost,
                          ),
                          _buildAppIconEvent(
                            FontAwesomeIcons.solidHeart,
                            Colors.grey.withOpacity(0.2),
                            "Me gusta",
                            _likePost,
                          ),
                          _buildAppIconEvent(
                            FontAwesomeIcons.solidBookmark,
                            Colors.grey.withOpacity(0.2),
                            "Guardar contenido",
                            _savePost,
                          ),
                          _buildAppIconEvent(
                            FontAwesomeIcons.solidStar,
                            Colors.grey.withOpacity(0.2),
                            "Agregar a favoritos",
                            _favoritePost,
                          ),
                          _buildAppIconEvent(
                            FontAwesomeIcons.retweet,
                            Colors.grey.withOpacity(0.2),
                            "Reaccionar",
                            _reactToPost,
                          ),
                          _buildAppIconEvent(
                            FontAwesomeIcons.userPlus,
                            Colors.grey.withOpacity(0.2),
                            "Seguir",
                            _followUser,
                          ),
                          _buildAppIconEvent(
                            FontAwesomeIcons.solidBell,
                            Colors.grey.withOpacity(0.2),
                            "Notificacion",
                            _toggleNotifications,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8),
                Divider(
                  height: 1,
                  thickness: 0.2, // Grosor real de la línea
                  color: Colors.grey,
                ),
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    "Más opciones",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade500),
                  ),
                ),
                SizedBox(height: 10),
                Wrap(
                  alignment: WrapAlignment.start, // Alinea los íconos al inicio
                  spacing: 10,  // Ajusta el espacio entre los íconos
                  runSpacing: 10, // Espacio entre filas
                  children: [
                    _buildAppIconLink(FontAwesomeIcons.link, Colors.cyan, "Copiar Enlace", _copyLink),
                    _buildAppIconLink(FontAwesomeIcons.shareAlt, Colors.blue, "Compartir", _shareLink),
                    ...installedApps.map((app) {
                      return _buildAppIcon(
                        null,
                        Colors.transparent, // Sin fondo
                        app.appName,
                            () {
                          DeviceApps.openApp(app.packageName);
                        },
                        iconData: MemoryImage(app.icon!),
                      );
                    }).toList(),
                  ],
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppIconEvent(
      IconData? icon,
      Color color,
      String label,
      VoidCallback onTap,
      {ImageProvider? iconData}
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3.0), // Separación horizontal
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start, // Mantiene la alineación al inicio
          crossAxisAlignment: CrossAxisAlignment.center, // Centra los iconos horizontalmente
          children: [
            // Contenedor para el icono
            Container(
              height: 50, // Altura fija para el contenedor del icono
              width: 50, // Ancho fijo para mantener la proporción
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.all(10), // Relleno alrededor del icono
              child: iconData == null
                  ? Icon(icon, color: Colors.grey.shade900, size: 24)
                  : ClipOval(
                child: Image(
                  image: iconData,
                  fit: BoxFit.cover,
                  width: 50,
                  height: 50,
                ),
              ),
            ),
            SizedBox(height: 2),

            Container(
              width: 60,
              constraints: BoxConstraints(maxHeight: 40),
              child: Center(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppIconLink(
      IconData? icon, Color color, String label, VoidCallback onTap,
      {ImageProvider? iconData}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),  // Menos padding
        child: Container(
          width: 70,  // Asegura que todos los íconos tengan el mismo tamaño
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: color,
                radius: 26,  // Aumentado para un tamaño más grande
                child: iconData == null
                    ? Icon(icon, color: Colors.white, size: 24) // Aumentado para mejor proporción
                    : ClipOval(
                  child: Image(
                    image: iconData,
                    fit: BoxFit.cover,
                    width: 50,
                    height: 50,
                  ),
                ),
              ),
              SizedBox(height: 5),
              SizedBox(
                width: 70,
                child: Text(
                  label,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppIcon(
      IconData? icon, Color color, String label, VoidCallback onTap,
      {ImageProvider? iconData}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0), // Menos padding
        child: Container(
          width: 70,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Colors.transparent, // Sin color de fondo
                radius: 28, // Aumentado para un tamaño más grande
                child: iconData == null
                    ? Icon(icon, color: color, size: 24) // Aumentado para mejor proporción
                    : ClipOval(
                  child: Image(
                    image: iconData,
                    fit: BoxFit.cover,
                    width: 60,
                    height: 60,
                  ),
                ),
              ),
              SizedBox(height: 5),
              SizedBox(
                width: 70,
                child: Text(
                  label,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //metodos

  void _reportPost() {
    print('Publicación reportada');
  }

  void _sharePost() {
    print('Publicación compartida');
  }

  void _likePost() {
    print('Te ha gustado la publicación');
  }

  void _savePost() {
    print('Publicación guardada');
  }

  void _favoritePost() {
    print('Publicación agregada a favoritos');
  }

  void _reactToPost() {
    print('Reaccionar Contenido');
  }

  void _followUser() {
    print('Seguir');
  }

  void _toggleNotifications() {
    print('Notificar Publicaciones');
  }

  void _commentOnPost() {
    print('Comentar en la publicación');
  }
}

class _FixedHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _FixedHeaderDelegate({required this.child});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
