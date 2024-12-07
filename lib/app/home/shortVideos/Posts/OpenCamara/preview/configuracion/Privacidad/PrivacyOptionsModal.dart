import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../../../Globales/estadoDark-White/DarkModeProvider.dart';

class PrivacyOptionsModal extends StatefulWidget {
  final bool isFullScreen; // Agrega el parámetro isFullScreen

  PrivacyOptionsModal({Key? key, this.isFullScreen = false}) : super(key: key);

  @override
  _PrivacyOptionsModalState createState() => _PrivacyOptionsModalState();
}

class _PrivacyOptionsModalState extends State<PrivacyOptionsModal> {
  String _privacyOption = 'publico';
  bool _allowComments = true; // Variable para permitir comentarios
  bool _allowUbicacion = true; // Variable para permitir comentarios
  bool _allowLikes = true; // Variable para permitir likes
  bool _allowDescargas = true; // Variable para permitir likes
  bool allowSave = true; // manejar la visibilidad de la sección de permisos

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;

    return Container(
      height: MediaQuery.of(context).size.height * 0.5, // Media pantalla
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF1C1C1C): Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Column(
        children: [
          SizedBox(height: 6.0),
          _buildDragIndicator(),
         // Encabezado del Modal
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: Text(
              'Opciones de Privacidad',
              style: TextStyle(color: textColor, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          // Sección de opciones de privacidad
          Container(
            margin: EdgeInsets.only(bottom: 8.0),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.withOpacity(0.4), width: 0.7),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15.0, top:8.0), // Ajusta el padding para mover el texto a la izquierda
                  child: Text(
                    'Quién puede ver tus vídeos',
                    style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w700, color: textColor),
                  ),
                ),
                SizedBox(height: 8.0),
                Padding(
                  padding: const EdgeInsets.only(left: 35.0),
                  child: Row(
                    children: [
                      _buildPrivacyButton('publico', Icons.public, 'Público', textColor, iconColor),
                      SizedBox(width: 8.0),
                      _buildPrivacyButton('privado', Icons.lock, 'Privado', textColor, iconColor),
                    ],
                  ),
                ),
                SizedBox(height: 8.0),
              ],
            ),

          ),

          // Sección de permisos
          GestureDetector(
            onTap: () {
              setState(() {
                allowSave = !allowSave;
              });
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Para que el icono quede al final
                    children: [
                      Text(
                        'Permisos Adicionales',
                        style: TextStyle(
                          fontSize: 15.0,
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 15.0),
                        child: Icon(
                          allowSave ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                if (allowSave) _buildPermissionOptions(textColor), // Muestra las opciones adicionales si allowSave es true
              ],
            ),
          )

        ],
      ),
    );
  }

  // Método para construir el botón de privacidad
  Widget _buildPrivacyButton(String option, IconData icon, String label, Color textColor, Color iconColor) {
    return SizedBox(
      height: 35.0, // Ajusta la altura del botón
      child: TextButton.icon(
        onPressed: () {
          handlePrivacyOption(option);
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          backgroundColor: _privacyOption == option ? Colors.lightBlueAccent : Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(color: Colors.grey.withOpacity(0.3), width: 1.2),
          ),
        ),
        icon: Icon(
          icon,
          color: _privacyOption == option ? Colors.white : iconColor,
        ),
        label: Text(
          label,
          style: TextStyle(
            color: _privacyOption == option ? Colors.white : textColor,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  // Método para construir las opciones de permisos
  Widget _buildPermissionOptions(Color textColor) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.grey[200],

        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 23.0),
            child: _buildPermissionSwitch(
              'Permitir descargas',
              Icons.save,
              _allowDescargas,
                  (value) {
                setState(() {
                  _allowDescargas = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 23.0), // Aplica un padding left de 23
            child: _buildPermissionSwitch(
              'Permitir ubicación',
              Icons.location_on,
              _allowUbicacion,
                  (value) {
                setState(() {
                  _allowUbicacion = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: _buildPermissionSwitch(
              'Permitir Likes',
              Icons.thumb_up,
              _allowLikes,
                  (value) {
                setState(() {
                  _allowLikes = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: _buildPermissionSwitch(
              'Permitir comentarios',
              Icons.messenger,
              _allowComments,
                  (value) {
                setState(() {
                  _allowComments = value;
                });
              },
            ),
          ),
        ],
      ),
    );
  }


  // Método para construir cada opción de permiso con Switch
  Widget _buildPermissionSwitch(String label, IconData icon, bool value, ValueChanged<bool> onChanged) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;

    return InkWell(
      onTap: () {
        onChanged(!value);
      },
      child: Row(
        children: [
          Icon(icon, color: value ? Colors.lightBlueAccent : Colors.grey, size: 24),
          SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontWeight: FontWeight.w500, fontSize: 13),
          ),
          Spacer(),
          Transform.scale(
            scale: 0.76,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: Colors.white,
              activeTrackColor: Colors.lightBlueAccent,
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  void handlePrivacyOption(String newOption) {
    setState(() {
      _privacyOption = newOption; // Cambia la opción de privacidad
    });
  }

  //barra de encima del modal
  Widget _buildDragIndicator() {
    return Container(
      width: 60,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey[600],
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }
}
