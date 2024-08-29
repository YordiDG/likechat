import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../Globales/estadoDark-White/DarkModeProvider.dart';


class EstadoDeCuentaScreen extends StatefulWidget {
  @override
  _EstadoDeCuentaScreenState createState() => _EstadoDeCuentaScreenState();
}

class _EstadoDeCuentaScreenState extends State<EstadoDeCuentaScreen> {
  bool _isSectionActive = true; // Estado del Switch
  bool _isAccountActive = true; // Estado de la cuenta

  @override
  Widget build(BuildContext context) {

    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final appBarColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text('Estado de Cuenta', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
        backgroundColor: appBarColor, // Color del AppBar
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          _buildSection(
            title: 'Estado de Cuenta',
            isActive: _isAccountActive,
            onSwitchChanged: (value) {
              setState(() {
                _isAccountActive = value;
              });
            },
            subsections: [
              _buildSubsection(
                title: 'Cuenta Activa',
                icon: Icons.check_circle,
              ),
              _buildSubsection(
                title: 'Otras Cuentas',
                icon: Icons.account_circle,
              ),
              _buildSubsection(
                title: 'Cuentas Bloqueadas',
                icon: Icons.lock,
              ),
            ],
          ),
          SizedBox(height: 16.0),
          _buildSection(
            title: 'Resumen de Cuenta',
            isActive: _isSectionActive,
            onSwitchChanged: (value) {
              setState(() {
                _isSectionActive = value;
              });
            },
            subsections: [
              _buildSubsection(
                title: 'Saldo Actual',
                icon: Icons.monetization_on,
              ),
              _buildSubsection(
                title: 'Historial de Transacciones',
                icon: Icons.history,
              ),
              _buildSubsection(
                title: 'Próximos Pagos',
                icon: Icons.calendar_today,
              ),
            ],
          ),
          SizedBox(height: 16.0),
          _buildSection(
            title: 'Configuración de Notificaciones',
            isActive: _isSectionActive,
            onSwitchChanged: (value) {
              setState(() {
                _isSectionActive = value;
              });
            },
            subsections: [
              _buildSubsection(
                title: 'Alertas de Transacciones',
                icon: Icons.notifications,
              ),
              _buildSubsection(
                title: 'Recordatorios de Pagos',
                icon: Icons.alarm,
              ),
            ],
          ),
          SizedBox(height: 16.0),
          _buildSection(
            title: 'Preferencias de Usuario',
            isActive: _isSectionActive,
            onSwitchChanged: (value) {
              setState(() {
                _isSectionActive = value;
              });
            },
            subsections: [
              _buildSubsection(
                title: 'Idioma',
                icon: Icons.language,
              ),
              _buildSubsection(
                title: 'Tema',
                icon: Icons.palette,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required bool isActive,
    required ValueChanged<bool> onSwitchChanged,
    required List<Widget> subsections,
  }) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final backgroundColor = isDarkMode ? Colors.black : Colors.white;
    final appBarColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Transform.scale(
                scale: 0.9,
                child: Switch(
                value: isActive,
                onChanged: onSwitchChanged,
                activeColor: Colors.cyan,
              ),)
            ],
          ),
          SizedBox(height: 12.0),
          ...subsections,
        ],
      ),
    );
  }

  Widget _buildSubsection({required String title, required IconData icon}) {

    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      padding: EdgeInsets.all(12.0),
      margin: EdgeInsets.only(bottom: 8.0),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(6.0),
      ),
      child: Row(
        children: [
          Icon(icon, color: isDarkMode ? Colors.white : Colors.black, size: 24.0),
          SizedBox(width: 12.0),
          Text(
            title,
            style: TextStyle(fontSize: 16.0),
          ),
        ],
      ),
    );
  }
}
