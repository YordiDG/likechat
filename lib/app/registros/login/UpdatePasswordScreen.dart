import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../../Globales/estadoDark-White/DarkModeProvider.dart';
import '../providers/AuthProvider.dart';

class UpdatePasswordScreen extends StatefulWidget {
  final String email;

  UpdatePasswordScreen({required this.email});

  @override
  _UpdatePasswordScreenState createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Validación en tiempo real
  bool hasMinLength = false;
  bool hasLetter = false;
  bool hasNumber = false;
  bool hasSpecialChar = false;
  bool _isButtonEnabled = false;

  // Ojo de contraseña
  bool _oldPasswordVisible = false;
  bool _newPasswordVisible = false;

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final backgroundColor = darkModeProvider.backgroundColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        title: Text(
          'Actualizar Contraseña',
          style: TextStyle(
              color: textColor, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 22, color: iconColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        color: backgroundColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Icon(
                        Icons.lock_outline,
                        size: 70,
                        color: isDarkMode ? Colors.white : Colors.cyan,
                      ),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: Text(
                        'Cambiar Contraseña',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    _buildPasswordTextField(
                      controller: _oldPasswordController,
                      label: 'Contraseña actual',
                      isVisible: _oldPasswordVisible,
                      toggleVisibility: () {
                        setState(() {
                          _oldPasswordVisible = !_oldPasswordVisible;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su contraseña actual';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 25),
                    _buildPasswordTextField(
                      controller: _newPasswordController,
                      label: 'Nueva contraseña',
                      isVisible: _newPasswordVisible,
                      toggleVisibility: () {
                        setState(() {
                          _newPasswordVisible = !_newPasswordVisible;
                        });
                      },
                      validator: null, // Validación en tiempo real
                    ),
                    if (!hasMinLength ||
                        !hasLetter ||
                        !hasNumber ||
                        !hasSpecialChar) ...[
                      SizedBox(height: 8),
                      _buildPasswordValidation(),
                    ],
                    SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isButtonEnabled ? _validateAndSubmit : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan,
                          disabledBackgroundColor: Colors.grey.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Actualizar Contraseña',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height:70),
              // Mensaje de ayuda
              TextButton(
                onPressed: () {},
                child: Text(
                  '¿Necesitas ayuda?',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordTextField({
    required TextEditingController controller,
    required String label,
    required bool isVisible,
    required VoidCallback toggleVisibility,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      inputFormatters: [
        LengthLimitingTextInputFormatter(28),
        // Limita la entrada a 25 caracteres
      ],
      onChanged: (value) {
        if (controller == _newPasswordController) {
          // Actualiza las reglas en tiempo real solo para la nueva contraseña
          setState(() {
            hasMinLength = value.length >= 8;
            hasLetter = value.contains(RegExp(r'[A-Za-z]'));
            hasNumber = value.contains(RegExp(r'[0-9]'));
            hasSpecialChar =
                value.contains(RegExp(r'[!@#\+$%^&*(),.?":{}|<>]'));

            // Habilitar el botón si todas las condiciones son verdaderas
            _isButtonEnabled = hasMinLength &&
                hasLetter &&
                hasNumber &&
                hasSpecialChar &&
                value.length <= 28; // Verifica el límite máximo
          });
        }
      },
      cursorColor: Colors.cyan,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.cyan),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.cyan),
        ),
        prefixIcon: Icon(Icons.lock, color: Colors.cyan),
        suffixIcon: IconButton(
          icon: Icon(isVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.cyan),
          onPressed: toggleVisibility,
        ),
      ),
      obscureText: !isVisible,
    );
  }

  Widget _buildPasswordValidation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildValidationText('Al menos 8 caracteres', hasMinLength),
        _buildValidationText('Debe incluir al menos una letra', hasLetter),
        _buildValidationText('Debe incluir al menos un número', hasNumber),
        _buildValidationText(
            'Debe incluir al menos un símbolo', hasSpecialChar),
      ],
    );
  }

  Widget _buildValidationText(String text, bool isValid) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.cancel,
          color: isValid ? Colors.green : Colors.grey,
          size: 16,
        ),
        SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(
              color: isValid ? Colors.green : Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  void _validateAndSubmit() async {
    if (_formKey.currentState!.validate()) {
      try {
        await Provider.of<AuthProvider>(context, listen: false).updatePassword(
          widget.email,
          _oldPasswordController.text,
          _newPasswordController.text,
        );
        Fluttertoast.showToast(
          msg: "Contraseña actualizada exitosamente",
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        Fluttertoast.showToast(
          msg: "Error del servidor. Vuelva a intertarlo.",
          backgroundColor: Colors.grey.shade800,
          textColor: Colors.white,
        );
      }
    }
  }
}
