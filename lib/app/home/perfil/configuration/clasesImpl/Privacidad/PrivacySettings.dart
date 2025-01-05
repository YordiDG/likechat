import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../../Globales/estadoDark-White/DarkModeProvider.dart';
import '../../../../../Globales/estadoDark-White/Fuentes/FontSizeProvider.dart';
import 'Impl. y Permisos Dispo./PermissionsSection.dart';
import 'RestriccionCuenta/Interactiones/PrivacyDetailScreen.dart';
import 'RestriccionCuenta/RestrictedAccountSettingsScreen.dart';

class PrivacySettings extends StatefulWidget {
  @override
  _PrivacySettingsState createState() => _PrivacySettingsState();
}

class _PrivacySettingsState extends State<PrivacySettings> {
  // Account Privacy
  bool isPrivateAccount = false;
  bool showActivityStatus = true;
  bool showOnlineStatus = true;

  // Content & Interactions
  bool allowComments = true;
  bool allowLikes = true;
  bool allowViews = true;
  bool allowDuets = false;
  bool allowStitches = true;
  bool allowDownloads = false;
  bool hideForFollowers = false;
  bool allowShares = true;
  bool allowSaves = true;
  bool allowTags = true;
  bool allowMentions = true;
  bool allowRemixes = true;

  // Messages & Tags
  bool allowMessages = true;
  bool allowGroupMessages = true;
  bool allowTagging = true;
  bool mentionsFromEveryone = false;

  // Story & Live
  bool allowStoryReplies = true;
  bool allowStorySharing = true;
  bool allowLiveComments = true;
  bool allowLiveGuests = false;

  @override
  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;

    return SingleChildScrollView(
      child: Container(
        color: isDarkMode ? Colors.black : Colors.grey.shade100,
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAccountSection(),
            _buildInteractionsSection(),
            _buildContentSection(),
            _buildStoryAndLiveSection(),
            _buildDataSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    Widget? headerAction,
  }) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5),
      color: isDarkMode ? Colors.grey[900]! : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDarkMode ? Colors.grey[850]! : Colors.grey[200]!,
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[600] : Colors.grey,
                    fontSize: fontSizeProvider.fontSize - 2,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                if (headerAction != null) headerAction,
              ],
            ),
          ),
          Divider(
            color: Colors.grey.withOpacity(0.3),
            thickness: 0.3,
            height: 1,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 1.0),
            child: Column(
              children: children
                  .map((child) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: child,
                      ))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyOptionCuentaRestrict({
    required String title,
    required String description,
    required bool value,
    required VoidCallback onTap,
  }) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return GestureDetector(
      onTap: onTap, // Toda la fila será interactiva
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: fontSizeProvider.fontSize,
                      color: isDarkMode ? Colors.white : Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      value ? 'Privada' : 'Pública',
                      style: TextStyle(
                          fontSize: fontSizeProvider.fontSize - 1,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 2),
            Text(
              description,
              style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontSize: fontSizeProvider.fontSize - 3,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyOptionCuenta({
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
    Widget? trailing,
  }) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 16.0),
      // Ajuste del padding
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: fontSizeProvider.fontSize,
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: Colors.white,
                  activeTrackColor: Color(0xFF9B30FF),
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey.withOpacity(0.5),
                ),
              ),
            ],
          ),
          Text(
            description,
            style: TextStyle(
              color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
              fontSize: fontSizeProvider.fontSize - 3,
              height: 1.2, // Ajuste de altura de línea
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountSection() {
    return _buildSection(
      title: 'Visibilidad', // Removed toUpperCase()
      children: [
        _buildPrivacyOptionCuentaRestrict(
          title: 'Cuenta restringida',
          description:
              'Solo los usuarios que autorices podrán seguirte y acceder a tus videos. Tus seguidores actuales no se verán afectados por este cambio.',
          value: isPrivateAccount,
          onTap: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RestrictedAccountSettingsScreen(
                  isRestricted: isPrivateAccount,
                ),
              ),
            );

            if (result != null) {
              setState(() => isPrivateAccount = result);
            }
          },
        ),
        _buildPrivacyOptionCuenta(
          title: 'Visibilidad de actividad',
          description:
              'Al habilitar esta función, tanto tú como tus amigos (seguidores mutuos) podrán ver el estado de actividad de cada uno.',
          value: showActivityStatus,
          onChanged: (value) => setState(() => showActivityStatus = value),
        ),
        _buildPrivacyOptionCuenta(
          title: 'Estado en línea',
          description:
              'Permite que otros usuarios vean cuándo estás conectado y activo en tiempo real.',
          value: showOnlineStatus,
          onChanged: (value) => setState(() => showOnlineStatus = value),
        ),
        SizedBox(
          height: 10,
        )
      ],
    );
  }

  Widget _buildPrivacyOption({
    required IconData icon,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
    Widget? trailing,
  }) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 20.0),
      // Padding ajustado
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            size: 20,
          ),
          SizedBox(width: 12.0), // Espacio reducido entre ícono y texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: fontSizeProvider.fontSize,
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2),
                // Espacio reducido entre título y descripción
                Text(
                  description,
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                    fontSize: fontSizeProvider.fontSize - 2,
                    height: 1.2, // Altura de línea ajustada
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: Color(0xFF9B30FF),
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyOptionInteraction({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 20.0),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.grey[600],
              size: 24,
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle( // Eliminado 'const'
                      fontSize: fontSizeProvider.fontSize,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: fontSizeProvider.fontSize - 2,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.grey[400],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractionsSection() {
    return _buildSection(
      title: 'Interacciones',
      children: [
        _buildPrivacyOptionInteraction(
          icon: FontAwesomeIcons.commentDots,
          title: 'Comentarios',
          description: 'Controla quién puede comentar en tus publicaciones',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PrivacyDetailScreen(
                title: 'Comentarios',
                options: const ['Todos', 'Seguidores', 'Nadie'],
                icon: FontAwesomeIcons.commentDots,
              ),
            ),
          ),
        ),
        _buildPrivacyOptionInteraction(
          icon: Icons.favorite_border,
          title: 'Me gusta',
          description: 'Mostrar conteo de me gusta en tus publicaciones',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PrivacyDetailScreen(
                title: 'Me gusta',
                options: const ['Mostrar', 'Ocultar'],
                icon: Icons.favorite_border,
              ),
            ),
          ),
        ),
        _buildPrivacyOptionInteraction(
          icon: Icons.remove_red_eye_outlined,
          title: 'Vistas',
          description: 'Mostrar contador de visualizaciones',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PrivacyDetailScreen(
                title: 'Vistas',
                options: const ['Mostrar', 'Ocultar'],
                icon: Icons.remove_red_eye_outlined,
              ),
            ),
          ),
        ),
        _buildPrivacyOptionInteraction(
          icon: Icons.share_outlined,
          title: 'Compartir',
          description: 'Permitir que otros compartan tus publicaciones',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PrivacyDetailScreen(
                title: 'Compartir',
                options: const ['Todos', 'Seguidores', 'Nadie'],
                icon: Icons.share_outlined,
              ),
            ),
          ),
        ),
        _buildPrivacyOptionInteraction(
          icon: Icons.bookmark_border,
          title: 'Guardar',
          description: 'Permitir que otros guarden tus publicaciones',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PrivacyDetailScreen(
                title: 'Guardar',
                options: const ['Permitir', 'No permitir'],
                icon: Icons.bookmark_border,
              ),
            ),
          ),
        ),
        _buildPrivacyOptionInteraction(
          icon: FontAwesomeIcons.comment,
          title: 'Mensajes directos',
          description: 'Controla quién puede enviarte mensajes directos',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PrivacyDetailScreen(
                title: 'Mensajes directos',
                options: const ['Todos', 'Seguidores', 'Nadie'],
                icon: FontAwesomeIcons.comment,
              ),
            ),
          ),
        ),
        _buildPrivacyOptionInteraction(
          icon: Icons.tag,
          title: 'Etiquetas',
          description: 'Permitir que otros te etiqueten en publicaciones',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PrivacyDetailScreen(
                title: 'Etiquetas',
                options: const ['Todos', 'Seguidores', 'Nadie'],
                icon: Icons.tag,
              ),
            ),
          ),
        ),
        _buildPrivacyOptionInteraction(
          icon: Icons.group_add_outlined,
          title: 'Grupos',
          description: 'Permitir ser añadido a grupos',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PrivacyDetailScreen(
                title: 'Grupos',
                options: const ['Todos pueden añadirme', 'Solo seguidores', 'Nadie'],
                icon: Icons.group_add_outlined,
              ),
            ),
          ),
        ),
        _buildPrivacyOptionInteraction(
          icon: Icons.alternate_email,
          title: 'Menciones',
          description: 'Controla quién puede mencionarte',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PrivacyDetailScreen(
                title: 'Menciones',
                options: const ['Todos', 'Seguidores', 'Nadie'],
                icon: Icons.alternate_email,
              ),
            ),
          ),
        ),
        _buildPrivacyOptionInteraction(
          icon: Icons.play_circle_outline,
          title: 'Dúos/Remixes',
          description: 'Permitir que otros creen dúos con tus videos',
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PrivacyDetailScreen(
                title: 'Dúos/Remixes',
                options: const ['Permitir todos los videos', 'Solo videos seleccionados', 'No permitir'],
                icon: Icons.play_circle_outline,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContentSection() {
    return _buildSection(
      title: 'Contenido', // Removed toUpperCase()
      children: [
        _buildPrivacyOption(
          icon: Icons.duo_outlined,
          title: 'Dúos',
          description: 'Permitir que otros hagan dúos con tus videos',
          value: allowDuets,
          onChanged: (value) => setState(() => allowDuets = value),
        ),
        _buildPrivacyOption(
          icon: Icons.download_outlined,
          title: 'Descargas',
          description: 'Permitir que otros descarguen tus videos',
          value: allowDownloads,
          onChanged: (value) => setState(() => allowDownloads = value),
        ),
        SizedBox(height: 6,)
      ],
    );
  }

  Widget _buildStoryAndLiveSection() {
    return _buildSection(
      title: 'Historias y Directos', // Removed toUpperCase()
      children: [
        _buildPrivacyOption(
          icon: Icons.history,
          title: 'Respuestas a historias',
          description: 'Permitir respuestas a tus historias',
          value: allowStoryReplies,
          onChanged: (value) => setState(() => allowStoryReplies = value),
        ),
        _buildPrivacyOption(
          icon: Icons.share,
          title: 'Compartir historias',
          description: 'Permitir que otros compartan tus historias',
          value: allowStorySharing,
          onChanged: (value) => setState(() => allowStorySharing = value),
        ),
        _buildPrivacyOption(
          icon: Icons.live_tv,
          title: 'Comentarios en directos',
          description: 'Permitir comentarios durante transmisiones en vivo',
          value: allowLiveComments,
          onChanged: (value) => setState(() => allowLiveComments = value),
        ),
        SizedBox(height: 6,)
      ],
    );
  }

  Widget _buildDataSection() {
    return _buildSection(
      title: 'Permisos',
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0,),
          child: ListTile(
            leading: Icon(Icons.app_blocking_outlined, color: Colors.grey),
            title: Text(
              'Permisos de aplicación',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            trailing: Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PermissionsSection(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

}


