import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../Globales/estadoDark-White/DarkModeProvider.dart';


class PrivacySettings extends StatefulWidget {
  final Color switchActiveColor;
  final Color titleColor;
  final Color sectionTitleColor;
  final Color descriptionColor;
  final Color sectionBackgroundColor;
  final double titleFontSize;
  final double sectionTitleFontSize;
  final double descriptionFontSize;

  PrivacySettings({
    required this.switchActiveColor,
    required this.titleColor,
    required this.sectionTitleColor,
    required this.descriptionColor,
    required this.sectionBackgroundColor,
    required this.titleFontSize,
    required this.sectionTitleFontSize,
    required this.descriptionFontSize,
  });

  @override
  _PrivacySettingsState createState() => _PrivacySettingsState();
}

class _PrivacySettingsState extends State<PrivacySettings> {
  bool isPrivateAccount = false;
  bool showActivityStatus = true;
  bool allowComments = true;
  bool allowLikes = true;
  bool allowViews = true;
  bool allowDuets = false;

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sección: Cuenta
          _buildSection(
            title: 'Cuenta',
            children: [
              _buildPrivacyOption(
                icon: Icons.lock_outline,
                title: 'Cuenta privada',
                description:
                'Solo las personas que apruebes podrán seguirte y ver tus publicaciones.',
                value: isPrivateAccount,
                onChanged: (value) {
                  setState(() {
                    isPrivateAccount = value;
                  });
                },
              ),
              _buildPrivacyOption(
                icon: Icons.visibility_off_outlined,
                title: 'Estado de actividad',
                description:
                'Permite que las personas que sigues y cualquiera que te envíe mensajes vea cuándo estuviste activo por última vez en las aplicaciones.',
                value: showActivityStatus,
                onChanged: (value) {
                  setState(() {
                    showActivityStatus = value;
                  });
                },
              ),
            ],
          ),

          // Sección: Interacciones
          _buildSection(
            title: 'Interacciones',
            children: [
              _buildPrivacyOption(
                icon: Icons.comment_outlined,
                title: 'Comentarios',
                description:
                'Controla quién puede comentar en tus publicaciones y si deseas recibir comentarios en general.',
                value: allowComments,
                onChanged: (value) {
                  setState(() {
                    allowComments = value;
                  });
                },
              ),
              _buildPrivacyOption(
                icon: Icons.thumb_up_alt_outlined,
                title: 'Likes',
                description:
                'Permite que otros usuarios vean a quién le han gustado tus publicaciones.',
                value: allowLikes,
                onChanged: (value) {
                  setState(() {
                    allowLikes = value;
                  });
                },
              ),
              _buildPrivacyOption(
                icon: Icons.visibility_outlined,
                title: 'Visualizaciones',
                description:
                'Controla quién puede ver cuántas veces se han visualizado tus publicaciones.',
                value: allowViews,
                onChanged: (value) {
                  setState(() {
                    allowViews = value;
                  });
                },
              ),
              _buildPrivacyOption(
                icon: Icons.star_outline,
                title: 'Dúos',
                description:
                'Permite que otros usuarios creen dúos con tus videos.',
                value: allowDuets,
                onChanged: (value) {
                  setState(() {
                    allowDuets = value;
                  });
                },
              ),
            ],
          ),

          // Sección: Mensajes Directos
          _buildSection(
            title: 'Mensajes Directos',
            children: [
              _buildPrivacyOption(
                icon: Icons.message_outlined,
                title: 'Restricciones de mensajes',
                description:
                'Controla quién puede enviarte mensajes directos y si deseas recibirlos.',
                value: true,
                onChanged: (value) {},
              ),
            ],
          ),

          // Sección: Más opciones
          _buildSection(
            title: 'Más opciones',
            children: [
              _buildPrivacyOption(
                icon: Icons.share_outlined,
                title: 'Compartir actividad',
                description:
                'Permite compartir tu actividad con otros usuarios.',
                value: true,
                onChanged: (value) {},
              ),
              _buildPrivacyOption(
                icon: Icons.history_outlined,
                title: 'Historial de búsqueda',
                description: 'Gestiona o elimina tu historial de búsqueda.',
                value: true,
                onChanged: (value) {},
              ),
              _buildPrivacyOption(
                icon: Icons.block_outlined,
                title: 'Bloquear cuentas',
                description: 'Administra la lista de cuentas bloqueadas.',
                value: true,
                onChanged: (value) {},
              ),
              _buildPrivacyOption(
                icon: Icons.filter_list_outlined,
                title: 'Filtros de palabras clave',
                description:
                'Bloquea comentarios o mensajes que contengan ciertas palabras clave.',
                value: true,
                onChanged: (value) {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: widget.sectionTitleColor,
              fontSize: widget.sectionTitleFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: widget.sectionBackgroundColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyOption({
    required IconData icon,
    required String title,
    required String description,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Alinea el icono con el título
        children: [
          Icon(icon, color: widget.titleColor), // Ícono
          SizedBox(width: 16.0), // Espacio entre el ícono y el texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: widget.titleColor,
                    fontSize: widget.titleFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: widget.descriptionColor,
                    fontSize: widget.descriptionFontSize,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.9, // Reduce el tamaño del switch
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: widget.switchActiveColor,
            ),
          ),
        ],
      ),
    );
  }
}
