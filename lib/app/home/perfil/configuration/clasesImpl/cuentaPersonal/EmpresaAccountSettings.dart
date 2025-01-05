import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../Globales/estadoDark-White/DarkModeProvider.dart';
import '../../../../../Globales/estadoDark-White/Fuentes/FontSizeProvider.dart';

class EmpresaAccountSettings extends StatefulWidget {
  @override
  _EmpresaAccountSettingsState createState() => _EmpresaAccountSettingsState();
}

class _EmpresaAccountSettingsState extends State<EmpresaAccountSettings> {
  final _formKey = GlobalKey<FormState>();
  int _currentStep = 0;

  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _adsInPosts = false;
  bool _collaborationWithInfluencers = true;
  bool _useAIGeneratedContent = false;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _password;
  String? _confirmPassword;

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final backgroundColor = darkModeProvider.backgroundColor;
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    // Colores profesionales
    final primaryColor = isDarkMode ? Color(0xFF2196F3) : Color(0xFF1976D2);
    final surfaceColor = isDarkMode ? Color(0xFF1E1E1E) : Colors.white;
    final cardColor = isDarkMode ? Color(0xFF2D2D2D) : Colors.grey[50];

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        title: Text(
          'Configuración Empresarial',
          style: TextStyle(
            color: textColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20,),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader('Información de la Empresa', fontSizeProvider),
              _buildSection(
                children: [
                  _buildProfessionalTextField(
                    'Nombre de la Empresa',
                    Icons.business,
                    fontSizeProvider,
                    textColor,
                    primaryColor,
                  ),
                  SizedBox(height: 20),
                  _buildProfessionalTextField(
                    'Correo Electrónico',
                    Icons.email,
                    fontSizeProvider,
                    textColor,
                    primaryColor,
                  ),
                ],
                backgroundColor: cardColor,
              ),

              _buildHeader('Seguridad', fontSizeProvider),
              _buildSection(
                children: [
                  _buildProfessionalPasswordField(
                    'Contraseña',
                    _obscurePassword,
                        (val) => setState(() => _obscurePassword = !_obscurePassword),
                    fontSizeProvider,
                    textColor,
                    primaryColor,
                  ),
                  SizedBox(height: 20),
                  _buildProfessionalPasswordField(
                    'Confirmar Contraseña',
                    _obscureConfirmPassword,
                        (val) => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                    fontSizeProvider,
                    textColor,
                    primaryColor,
                  ),
                ],
                backgroundColor: cardColor,
              ),

              _buildHeader('Comunicaciones', fontSizeProvider),
              _buildSection(
                children: [
                  _buildProfessionalSwitch(
                    'Notificaciones por Email',
                    _emailNotifications,
                        (val) => setState(() => _emailNotifications = val),
                    Icons.mark_email_unread,
                    fontSizeProvider,
                    textColor,
                    primaryColor,
                  ),
                  Divider(height: 1),
                  _buildProfessionalSwitch(
                    'Notificaciones SMS',
                    _smsNotifications,
                        (val) => setState(() => _smsNotifications = val),
                    Icons.message_outlined,
                    fontSizeProvider,
                    textColor,
                    primaryColor,
                  ),
                ],
                backgroundColor: cardColor,
              ),

              _buildHeader('Configuración de Marketing', fontSizeProvider),
              _buildSection(
                children: [
                  _buildProfessionalSwitch(
                    'Publicidad en Publicaciones',
                    _adsInPosts,
                        (val) => setState(() => _adsInPosts = val),
                    Icons.campaign_outlined,
                    fontSizeProvider,
                    textColor,
                    primaryColor,
                  ),
                  Divider(height: 1),
                  _buildProfessionalSwitch(
                    'Programa de Influencers',
                    _collaborationWithInfluencers,
                        (val) => setState(() => _collaborationWithInfluencers = val),
                    Icons.group_outlined,
                    fontSizeProvider,
                    textColor,
                    primaryColor,
                  ),
                  Divider(height: 1),
                  _buildProfessionalSwitch(
                    'Contenido IA',
                    _useAIGeneratedContent,
                        (val) => setState(() => _useAIGeneratedContent = val),
                    Icons.psychology_outlined,
                    fontSizeProvider,
                    textColor,
                    primaryColor,
                  ),
                ],
                backgroundColor: cardColor,
              ),

              Padding(
                padding: EdgeInsets.all(24),
                child: _buildProfessionalButton(
                  'Guardar Cambios',
                      () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Cambios guardados exitosamente'),
                          backgroundColor: primaryColor,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  fontSizeProvider,
                  primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(String title, FontSizeProvider fontSizeProvider) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: fontSizeProvider.fontSize + 1,
          fontWeight: FontWeight.bold,
          color: Provider.of<DarkModeProvider>(context).textColor,
        ),
      ),
    );
  }

  Widget _buildSection({
    required List<Widget> children,
    required Color? backgroundColor,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildProfessionalTextField(
      String label,
      IconData icon,
      FontSizeProvider fontSizeProvider,
      Color textColor,
      Color primaryColor,
      ) {
    return TextFormField(
      style: TextStyle(
        fontSize: fontSizeProvider.fontSize,
        color: textColor,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: fontSizeProvider.fontSize,
          color: textColor.withOpacity(0.7),
        ),
        prefixIcon: Icon(icon, color: primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor),
        ),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'Este campo es requerido';
        }
        return null;
      },
    );
  }

  Widget _buildProfessionalPasswordField(
      String label,
      bool obscureText,
      Function(bool) onVisibilityToggle,
      FontSizeProvider fontSizeProvider,
      Color textColor,
      Color primaryColor,
      ) {
    return TextFormField(
      obscureText: obscureText,
      style: TextStyle(
        fontSize: fontSizeProvider.fontSize,
        color: textColor,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          fontSize: fontSizeProvider.fontSize,
          color: textColor.withOpacity(0.7),
        ),
        prefixIcon: Icon(Icons.lock_outline, color: primaryColor),
        suffixIcon: IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
            color: primaryColor,
          ),
          onPressed: () => onVisibilityToggle(!obscureText),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primaryColor),
        ),
      ),
      validator: (value) {
        if (value?.isEmpty ?? true) {
          return 'La contraseña es requerida';
        }
        return null;
      },
    );
  }

  Widget _buildProfessionalSwitch(
      String label,
      bool value,
      Function(bool) onChanged,
      IconData icon,
      FontSizeProvider fontSizeProvider,
      Color textColor,
      Color primaryColor,
      ) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: Icon(icon, color: primaryColor),
      title: Text(
        label,
        style: TextStyle(
          fontSize: fontSizeProvider.fontSize,
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: primaryColor,
      ),
    );
  }

  Widget _buildProfessionalButton(
      String text,
      VoidCallback onPressed,
      FontSizeProvider fontSizeProvider,
      Color primaryColor,
      ) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 2,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSizeProvider.fontSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}