import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:device_apps/device_apps.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../Globales/estadoDark-White/DarkModeProvider.dart';

class ShareButton extends StatelessWidget {
  final int shareCount = 99999;

  String formatShareCount(int count) {
    if (count >= 1000000) {
      return '${(count ~/ 1000000)} mill.';
    } else if (count >= 1000) {
      return '${(count ~/ 1000)} mil';
    }
    return count.toString();
  }

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
        builder: (context, scrollController) {
          return FriendsModal(scrollController: scrollController);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showFriendsModal(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            FontAwesomeIcons.paperPlane,
            color: Colors.grey ,
            size: 21,
          ),
          SizedBox(width: 4), // Espaciado entre el icono y el contador
          Text(
            formatShareCount(shareCount),
            style: TextStyle(
              color: Colors.grey ,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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
      // Obtenemos las apps pero manejamos los íconos de manera más segura
      final apps = await DeviceApps.getInstalledApplications(
        includeAppIcons: true,
        includeSystemApps: false,
        onlyAppsWithLaunchIntent: true, // Solo apps que se pueden lanzar
      );

      final socialMediaPackages = [
        // Facebook y apps relacionadas
        'com.facebook.katana',          // Facebook app principal
        'com.facebook.lite',            // Facebook Lite
        'com.facebook.orca',            // Messenger
        'com.facebook.mlite',           // Messenger Lite

        // Instagram
        'com.instagram.android',        // Instagram principal
        'com.instagram.lite',           // Instagram Lite

        // Twitter/X - Paquetes actualizados
        'twitter.com.android',          // Twitter formato alternativo
        'com.twitter.lite.android',     // Twitter Lite alternativo
        'com.twitter.london',           // Twitter/X nueva versión
        'twitter.x.android',            // X versión alternativa

        // WhatsApp
        'com.whatsapp',                // WhatsApp principal
        'com.whatsapp.w4b',            // WhatsApp Business principal
        'com.whatsapp.business',       // WhatsApp Business alternativo
        'com.whatsapp.business.lite',  // WhatsApp Business Lite

        // TikTok
        'com.zhiliaoapp.musically',    // TikTok versión global
        'com.ss.android.ugc.trill',    // TikTok versión alternativa
        'com.tiktok.musical.ly',       // TikTok nombre antiguo
        'com.tiktok.lite',             // TikTok Lite

        // Snapchat
        'com.snapchat.android',        // Snapchat

        // LinkedIn
        'com.linkedin.android',        // LinkedIn principal
        'com.linkedin.android.lite',   // LinkedIn Lite

        // Pinterest
        'com.pinterest',               // Pinterest principal
        'com.pinterest.twa',           // Pinterest Lite

        // Reddit
        'com.reddit.frontpage',        // Reddit oficial
        'com.reddit.lite',             // Reddit lite

        // Telegram
        'org.telegram.messenger',      // Telegram principal
        'org.telegram.messenger.web',  // Telegram Web
        'org.telegram.messenger.lite', // Telegram Lite

        // Twitch
        'tv.twitch.android.app',      // Twitch principal
        'tv.twitch.android.game',     // Twitch Gaming

        // Discord
        'com.discord',                // Discord

        // BeReal
        'com.bereal.ft',              // BeReal

        // Threads
        'com.instagram.barcelona',     // Threads de Meta
      ];

      final socialApps = apps.where((app) =>
          socialMediaPackages.contains(app.packageName)
      ).toList();

      // Verificamos que cada app tenga un ícono válido antes de hacer el cast
      final validSocialApps = socialApps.map((app) {
        if (app is ApplicationWithIcon) {
          try {
            // Verificamos que el ícono sea accesible
            final icon = app.icon;
            if (icon != null && icon.isNotEmpty) {
              return app;
            }
          } catch (e) {
            print('Error al procesar ícono para ${app.appName}: $e');
          }
        }
        // Si no hay ícono válido, aún incluimos la app pero marcamos que no tiene ícono
        return app;
      }).toList();

      print("Redes sociales instaladas: ${validSocialApps.map((app) => app.appName).toList()}");

      setState(() {
        // Solo hacemos cast de las apps que confirmamos que tienen ícono
        installedApps = validSocialApps.whereType<ApplicationWithIcon>().toList();
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
      backgroundColor: Colors.grey.shade800,
      textColor: Colors.white,
      fontSize: 13.0,
    );
  }

  void _shareLink() {
    Share.share("https://likechat.com.pe/user12", subject: "Mira este enlace");
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final backgroundColor = darkModeProvider.backgroundColor;

    return SizedBox(
      height: MediaQuery.of(context).size.height *
          0.8,
      child: CustomScrollView(
        controller: widget.scrollController,
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _FixedHeaderDelegate(
              child: Container(
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade900.withOpacity(0.9) : Colors.white,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                  border: Border(
                    bottom: BorderSide( // Línea ligera al final del contenedor
                      color: Colors.grey.shade300, // Color de la línea (ajústalo según el tema)
                      width: 0.2, // Grosor de la línea
                    ),
                  ),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    // Texto e icono "Compartir con" centrados
                    Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Compartir con",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          SizedBox(width: 3), // Espacio entre el texto y el icono
                          Icon(
                            Icons.arrow_drop_down,
                            size: 20,
                            color: textColor,
                          ),
                        ],
                      ),
                    ),
                    // Icono de cerrar (X) alineado al extremo derecho
                    Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        FontAwesomeIcons.close,
                        size: 20,
                        color: iconColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              color: isDarkMode ? Colors.grey.shade800.withOpacity(0.4) : Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  isLoading
                      ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        height: 23,
                        width: 23,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.cyan),
                          strokeWidth: 2.6,
                        ),
                      ),
                    ),
                  )
                      : CarouselSlider.builder(
                    itemCount: friends.length,
                    options: CarouselOptions(
                      height: 102,
                      viewportFraction: 0.18, //uni o separar la fraccion de amigos
                      enableInfiniteScroll: true,
                      autoPlayInterval: Duration(seconds: 3),
                      padEnds: false,
                    ),
                    itemBuilder: (context, index, realIndex) {
                      final friend = friends[index];
                      return Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDarkMode
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade300,
                                width: 0.8,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 26,
                              backgroundImage:
                              NetworkImage(friend['image']!),
                            ),
                          ),
                          SizedBox(height: 5),
                          SizedBox(
                            width: 60,
                            child: Text(
                              friend['name']!,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
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
                    height: 1,
                    thickness: 0.2,
                    color: isDarkMode
                        ? Colors.grey.shade700
                        : Colors.grey.shade300,
                  ),
                  SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      "Herramientas de Interacción",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade500,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  //iconos de compartir
                  _iconosShare(),

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
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500),
                    ),
                  ),
                  SizedBox(height: 10),

                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Los iconos de las apps sin fondo adicional
                        ...installedApps.map((app) {
                          return _buildAppIcon(
                            null,
                            Colors.transparent, // Sin fondo para las apps
                            app.appName,
                                () {
                              DeviceApps.openApp(app.packageName);
                            },
                            iconData: MemoryImage(app.icon!),
                          );
                        }).toList(),

                        // Botón 'Copiar Enlace' con fondo
                        _buildAppIconLink(
                          FontAwesomeIcons.link,
                          Colors.cyan,
                          "Copiar Enlace",
                          _copyLink,
                        ),

                        // Botón 'Más' con fondo
                        _buildAppIconLink(
                          FontAwesomeIcons.plus,
                          Colors.blue,
                          "Más",
                          _shareLink,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  //herramientas de interaccion
  Widget _buildAppIconEvent(
      IconData? icon,
      Color color,
      String label,
      VoidCallback onTap,
      {ImageProvider? iconData}
      ) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final backgroundColor = darkModeProvider.backgroundColor;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 50,
              width: 50,
              margin: EdgeInsets.only(bottom: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(30),
              ),
              padding: const EdgeInsets.all(10),
              child: iconData == null
                  ? Icon(
                icon,
                color: isDarkMode ? Colors.grey.shade400 : Colors.grey.shade600,
                size: 22,
              )
                  : ClipOval(
                child: Image(
                  image: iconData,
                  fit: BoxFit.cover,
                  width: 40,
                  height: 40,
                ),
              ),
            ),
            SizedBox(height: 6),
            Container(
              width: 60,
              height: 28,
              alignment: Alignment.topCenter, // Alinea el texto hacia arriba
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //metodo de iconos de interaccion
  Widget _iconosShare (){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              SizedBox(width: 2,),
              _buildAppIconEvent(
                FontAwesomeIcons.solidFlag,
                Colors.grey.withOpacity(0.2),
                "Denunciar",
                _reportPost,
              ),
              SizedBox(width: 2,),
              _buildAppIconEvent(
                FontAwesomeIcons.solidHeart,
                Colors.grey.withOpacity(0.2),
                "Me gusta",
                _likePost,
              ),
              SizedBox(width: 2),
              _buildAppIconEvent(
                FontAwesomeIcons.solidBookmark,
                Colors.grey.withOpacity(0.2),
                "Guardar contenido",
                _savePost,
              ),
              SizedBox(width: 2,),
              _buildAppIconEvent(
                FontAwesomeIcons.solidStar,
                Colors.grey.withOpacity(0.2),
                "Agregar a favoritos",
                _favoritePost,
              ),
              SizedBox(width: 2,),
              _buildAppIconEvent(
                FontAwesomeIcons.retweet,
                Colors.grey.withOpacity(0.2),
                "Reaccionar",
                _reactToPost,
              ),
              SizedBox(width: 2,),
              _buildAppIconEvent(
                FontAwesomeIcons.userPlus,
                Colors.grey.withOpacity(0.2),
                "Seguir",
                _followUser,
              ),
              SizedBox(width: 2,),
              _buildAppIconEvent(
                FontAwesomeIcons.solidBell,
                Colors.grey.withOpacity(0.2),
                "Notificacion",
                _toggleNotifications,
              ),
              SizedBox(width: 2,),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppIconLink(
      IconData? icon, Color color, String label, VoidCallback onTap,
      {ImageProvider? iconData}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: SizedBox(
          width: 60, // Asegura que todos los íconos tengan el mismo tamaño
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: color,
                radius: 25, // Ajusta el tamaño del fondo circular
                child: iconData == null
                    ? Icon(icon, color: Colors.white, size: 26) // Ajusta el tamaño del icono
                    : ClipOval(
                  child: Image(
                    image: iconData,
                    fit: BoxFit.cover,
                    width: 40, // Ajusta el tamaño de la imagen
                    height: 40, // Ajusta el tamaño de la imagen
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 33, // Espacio fijo para el texto
                child: Text(
                  label,
                  style: const TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center, // Alineación centrada
                  maxLines: 2, // Permite que el texto ocupe dos líneas si es necesario
                  overflow: TextOverflow.ellipsis, // Asegura que no se desborde
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
        padding: const EdgeInsets.symmetric(horizontal: 6.0),
        child: SizedBox(
          width: 60, // Asegura que todos los íconos tengan el mismo tamaño
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.grey, // Color gris para el borde
                    width: 0.2, // Grosor del borde
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: color,
                  radius: 25,
                  child: iconData == null
                      ? Icon(icon, color: Colors.white, size: 28)
                      : ClipOval(
                    child: Image(
                      image: iconData,
                      fit: BoxFit.cover,
                      width: 50,
                      height: 50,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                height: 33, // Incrementa la altura para dar más espacio al texto
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 9, // Reduce el tamaño de fuente si el texto sigue siendo largo
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis, // Mantiene los puntos suspensivos si el texto es muy largo
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
