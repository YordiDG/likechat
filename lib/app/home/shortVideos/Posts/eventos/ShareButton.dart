import 'dart:convert';
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
        color: Colors.grey.shade200,
        size: 20,
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
          0.6,
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
                ),
                padding: EdgeInsets.all(16),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Compartir con",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
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
                    Icon(
                      FontAwesomeIcons.close,
                      size: 17,
                      color: iconColor,
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
                      height: 98,
                      viewportFraction: 0.2,
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
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade500,
                      ),
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
                      _buildAppIconLink(FontAwesomeIcons.reply, Colors.blue, "Compartir", _shareLink),
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
      ),
    );
  }

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
        padding: const EdgeInsets.symmetric(horizontal: 3.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 45,
              width: 45,
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
                size: 20,
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
                  fontSize: 10,
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

  Widget _buildAppIconLink(
      IconData? icon, Color color, String label, VoidCallback onTap,
      {ImageProvider? iconData}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6.0),  // Menos padding
        child: SizedBox(
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
                backgroundColor: Colors.grey.withOpacity(0.2), // Sin color de fondo
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
