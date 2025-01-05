import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../Globales/estadoDark-White/DarkModeProvider.dart';
import 'cuentaPersonal/AccountVerificationScreen.dart';
import 'cuentaPersonal/DataDownloader.dart';
import 'cuentaPersonal/DatosCuenta.dart';
import 'cuentaPersonal/EmpresaAccountSettings.dart';
import 'cuentaPersonal/VerContraseña.dart';

class Cuenta extends StatelessWidget {
  final double fontSize;

  Cuenta({required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final cardColor = isDarkMode ? Colors.grey.shade900 : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.grey.shade200,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: textColor,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Center(
          child: Text(
            'Cuenta',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: textColor,
            ),
          ),
        ),
        actions: [SizedBox(width: 48)],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildSection(
            context,
            title: 'Información de la Cuenta',
            items: [
              _buildMenuItem(
                context,
                icon: Icons.person,
                title: 'Datos de la Cuenta',
                description: 'Gestiona y actualiza tu información personal.',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DatosCuenta(
                      email: 'yordi15@gmail.com',
                      phoneNumber: '+519902411155',
                      region: 'Perú',
                    ),
                  ),
                ),
              ),
              _buildMenuItem(
                context,
                icon: Icons.lock,
                title: 'Contraseña y Seguridad',
                description: 'Cambia tu contraseña y configura la seguridad.',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VerificationCodeScreen(),
                  ),
                ),
              ),
            ],
            cardColor: cardColor,
            textColor: textColor,
          ),
          SizedBox(height: 16),
          _buildSection(
            context,
            title: 'Configuración de la Cuenta',
            items: [
              _buildMenuItem(
                context,
                icon: Icons.business_sharp,
                title: 'Cambiar a Cuenta de Empresa',
                description: 'Convierte tu cuenta en una cuenta empresarial.',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EmpresaAccountSettings()),
                ),
              ),
              _buildMenuItem(
                context,
                icon: Icons.security_update,
                title: 'Descargar tus Datos',
                description: 'Descarga una copia de tus datos personales.',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DownloadDataScreen()),
                ),
              ),
              _buildMenuItem(
                context,
                icon: Icons.verified_user_rounded,
                title: 'Verificación de Cuenta',
                description: 'Solicita la verificación de tu cuenta.',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AccountVerificationScreen()),
                ),
              ),
            ],
            cardColor: cardColor,
            textColor: textColor,
          ),
          SizedBox(height: 16),
          _buildSection(
            context,
            title: 'Administración de la Cuenta',
            items: [
              _buildMenuItem(
                context,
                icon: Icons.logout_sharp,
                title: 'Desactivar o Eliminar Cuenta',
                description: 'Desactiva o elimina tu cuenta permanentemente.',
                onTap: () {},
              ),
            ],
            cardColor: cardColor,
            textColor: textColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      BuildContext context, {
        required String title,
        required List<Widget> items,
        required Color cardColor,
        required Color textColor,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              color: textColor.withOpacity(0.7),
              fontSize: fontSize - 1,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          color: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 0.5
            ),
          ),
          child: Column(
            children: List.generate(items.length * 2 - 1, (index) {
              if (index.isOdd) {
                return Divider(height: 1,thickness: 0.4, color: Colors.grey.withOpacity(0.2));
              }
              return items[index ~/ 2];
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String description,
        required VoidCallback onTap,
      }) {
    final isDarkMode = Provider.of<DarkModeProvider>(context).isDarkMode;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return ListTile(
      leading: Icon(icon, color: textColor.withOpacity(0.7)),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
          fontSize: fontSize,
        ),
      ),
      subtitle: Text(
        description,
        style: TextStyle(
          color: textColor.withOpacity(0.6),
          fontSize: fontSize - 2,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: fontSize,
        color: textColor.withOpacity(0.7),
      ),
      onTap: onTap,
    );
  }
}