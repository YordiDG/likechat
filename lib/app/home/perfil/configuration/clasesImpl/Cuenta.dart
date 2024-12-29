import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Globales/estadoDark-White/DarkModeProvider.dart';
import '../../../../Globales/estadoDark-White/Fuentes/FontSizeProvider.dart';
import 'cuentaPersonal/AccountVerificationScreen.dart';
import 'cuentaPersonal/DataDownloader.dart';
import 'cuentaPersonal/DatosCuenta.dart';
import 'cuentaPersonal/DeleteAccountDialog.dart';
import 'cuentaPersonal/EmpresaAccountSettings.dart';
import 'cuentaPersonal/VerContraseña.dart';

class Cuenta extends StatelessWidget {
  final Color tileColor;
  final Color textColor;
  final double fontSize;

  Cuenta({
    required this.tileColor,
    required this.textColor,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final backgroundColor = darkModeProvider.backgroundColor;
    final iconColor = darkModeProvider.iconColor;
    final isDarkMode = darkModeProvider.isDarkMode;

    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return Scaffold(
      backgroundColor:backgroundColor ,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade100,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: iconColor,
            size: 20,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Center(
          child: Text(
            'Cuenta',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
        ),
        actions: [

          SizedBox(width: 48), // Asegúrate de usar un ancho equivalente al del IconButton
        ],
      ),
      body: ListView(
        children: [
          _buildSectionHeader('Información de la Cuenta'),
          _buildMenuTile(
            context,
            icon: Icons.person,
            title: 'Datos de la Cuenta',
            description: 'Gestiona y actualiza tu información personal.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DatosCuenta(
                    email: 'yordi15@gmail.com',
                    phoneNumber: '+519902411155', region: 'Perú',
                  ),
                ),
              );
            },
          ),
          _buildMenuTile(
            context,
            icon: Icons.lock,
            title: 'Contraseña y Seguridad',
            description: 'Cambia tu contraseña y configura la seguridad.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => VerContrasenia(),
              ),
              );
            },
          ),
          _buildSectionHeader('Configuración de la Cuenta'),
          _buildMenuTile(
            context,
            icon: Icons.business_sharp,
            title: 'Cambiar a Cuenta de Empresa',
            description: 'Convierte tu cuenta en una cuenta empresarial.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EmpresaAccountSettings()),
              );
            },
          ),
          _buildMenuTile(
            context,
            icon: Icons.security_update,
            title: 'Descargar tus Datos',
            description: 'Descarga una copia de tus datos personales.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => DownloadDataScreen()),
              );
            },
          ),

          _buildMenuTile(
            context,
            icon: Icons.verified_user_rounded,
            title: 'Verificación de Cuenta',
            description: 'Solicita la verificación de tu cuenta.',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccountVerificationScreen()),
              );
            },
          ),
          _buildSectionHeader('Administración de la Cuenta'),
          AccountMenuTile(
            icon: Icons.logout_sharp,
            title: 'Desactivar o Eliminar Cuenta',
            description: 'Desactiva o elimina tu cuenta permanentemente.',
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String description,
        required VoidCallback onTap,
      }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey.shade600),
      title: Text(
        title,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500, fontSize: fontSize),
      ),
      subtitle: Text(
        description,
        style: TextStyle(color: textColor.withOpacity(0.6), fontSize: fontSize - 4),
      ),
      trailing: Icon(Icons.arrow_forward_ios, size: fontSize, color: textColor),
      tileColor: tileColor,
      onTap: onTap,
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.grey.shade600,
          fontSize: fontSize - 3,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

}

