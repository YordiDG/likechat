import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../shortVideos/PreviewVideo/PublicarVideo/VideoPublishScreen.dart';

class PrivacyAndPermissionsModal extends StatefulWidget {
  final PublishOptions publishOptions;
  final ValueChanged<String> onPrivacyOptionChange;
  final ValueChanged<bool> onAllowDownloadsChange;
  final ValueChanged<bool> onAllowLocationTaggingChange;
  final ValueChanged<bool> onAllowCommentsChange;

  const PrivacyAndPermissionsModal({
    Key? key,
    required this.publishOptions,
    required this.onPrivacyOptionChange,
    required this.onAllowDownloadsChange,
    required this.onAllowLocationTaggingChange,
    required this.onAllowCommentsChange,
  }) : super(key: key);

  @override
  _PrivacyAndPermissionsModalState createState() => _PrivacyAndPermissionsModalState();
}

class _PrivacyAndPermissionsModalState extends State<PrivacyAndPermissionsModal> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
          )
        ],
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Título
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Configuración de Publicación',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Icon(Icons.tune, color: Colors.grey),
              ],
            ),
          ),

          // Opciones de Privacidad
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Visibilidad',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    _buildPrivacyButton(
                      'Público',
                      Icons.public,
                      'publico',
                      widget.publishOptions.privacyOption == 'publico',
                    ),
                    SizedBox(width: 10),
                    _buildPrivacyButton(
                      'Privado',
                      Icons.lock_outline,
                      'privado',
                      widget.publishOptions.privacyOption == 'privado',
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Permisos
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16),
              children: [
                _buildPermissionTile(
                  'Descargas',
                  Icons.download,
                  widget.publishOptions.allowDownloads,
                  widget.onAllowDownloadsChange,
                  'Permite que otros descarguen tu video',
                ),
                _buildPermissionTile(
                  'Ubicación',
                  Icons.location_on,
                  widget.publishOptions.allowLocationTagging,
                  widget.onAllowLocationTaggingChange,
                  'Muestra la ubicación de tu video',
                ),
                _buildPermissionTile(
                  'Comentarios',
                  FontAwesomeIcons.solidComment,
                  widget.publishOptions.allowComments,
                  widget.onAllowCommentsChange,
                  'Permite que otros comenten tu video',
                ),
              ],
            ),
          ),

          // Botón de Guardar
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                minimumSize: Size(60, 40),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Guardar Configuración',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyButton(
      String label,
      IconData icon,
      String option,
      bool isSelected
      ) {
    return Expanded(
      child: GestureDetector(
        onTap: () => widget.onPrivacyOptionChange(option),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.lightBlueAccent : Colors.white,
            border: Border.all(
              color: isSelected ? Colors.lightBlueAccent : Colors.grey.shade300,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey,
              ),
              SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionTile(
      String title,
      IconData icon,
      bool value,
      ValueChanged<bool> onChanged,
      String description,
      ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon, size: 27,
        color: value ? Colors.lightBlueAccent : Colors.grey,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: Colors.black,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        description,
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey,
        ),
      ),
      trailing: Transform.scale(
        scale: 0.8,
        child: Switch.adaptive(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: Colors.lightBlueAccent,
        ),
      ),
    );
  }
}