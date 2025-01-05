import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../../Globales/estadoDark-White/DarkModeProvider.dart';
import '../providers/AuthProvider.dart';
import 'UpdatePasswordScreen.dart';
import 'VerificationPassword.dart';

class RecoverPasswordScreen extends StatefulWidget {
  @override
  _RecoverPasswordScreenState createState() => _RecoverPasswordScreenState();
}

class _RecoverPasswordScreenState extends State<RecoverPasswordScreen> {
  final _emailController = TextEditingController();
  bool _isValidDomain = true; // Estado para validar dominio
  String? emailErrorMessage;

  final FocusNode _emailFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_onEmailFocusChange);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  bool _validateEmailDomain(String email) {
    final RegExp emailRegex =
    RegExp(r"^[a-zA-Z0-9._%+-]+@(gmail\.com|hotmail\.com|outlook\.com)$");
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        title: Text(
          'Recuperar Contraseña',
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20, color: iconColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              SizedBox(
                height: 120,
                child: Image.asset('lib/assets/splash/chaski.png'),
              ),
              SizedBox(height: 10),

              // Título y descripción
              Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : Colors.cyan[800]),
              ),
              SizedBox(height: 8),
              Text(
                'Ingresa tu correo registrado para recibir instrucciones.',
                style: TextStyle(fontSize: 10, color: isDarkMode ? Colors.white60 : Colors.black54, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),

              // Campo de correo electrónico
              TextField(
                controller: _emailController,
                focusNode: _emailFocusNode,
                cursorColor: Colors.cyan,
                decoration: InputDecoration(
                  labelText: 'Correo Electrónico',
                  labelStyle: TextStyle(
                    color: _isValidDomain ? Colors.cyan : Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: _isValidDomain ? Colors.cyan : Colors.red,
                      width: 1,
                    ),
                  ),
                  prefixIcon: Icon(Icons.email, color: _isValidDomain ? Colors.cyan : Colors.red),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: _isValidDomain ? Colors.grey.shade500 : Colors.red,
                      width: 1.2,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: _isValidDomain ? Colors.cyan : Colors.red,
                      width: 1.2,
                    ),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                onChanged: (value) {
                  setState(() {
                    if (value.isEmpty) {
                      emailErrorMessage = null;
                    } else if (!_validateEmailDomain(value)) {
                      emailErrorMessage = 'Dominios válidos: (gmail.com, outlook.com, hotmail.com)';
                    } else {
                      emailErrorMessage = null;
                    }
                  });
                },
              ),
              // Mostrar mensaje de error solo si es necesario
              if (emailErrorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 3.0, left: 8),
                  child: Align(
                    alignment: Alignment.centerLeft, // Alineación a la izquierda
                    child: Text(
                      emailErrorMessage!,
                      style: TextStyle(color: Color(0xFFCB7070), fontSize: 10, fontWeight: FontWeight.w500), // Rojo más suave
                    ),
                  ),
                ),

              SizedBox(height: 40),
              // Botón de envío
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_emailController.text.isEmpty) {
                      setState(() {
                        emailErrorMessage = ' Campo email es obligatorio *';
                      });
                      return;
                    }

                    if (!_validateEmailDomain(_emailController.text)) {
                      setState(() {
                        emailErrorMessage = 'El dominio del correo es inválido.';
                      });
                      return;
                    }

                    try {
                      await Provider.of<AuthProvider>(context, listen: false)
                          .recoverPassword(_emailController.text);
                      Fluttertoast.showToast(
                          msg: "Correo de recuperación enviado.",
                          backgroundColor: Colors.green,
                          textColor: Colors.white, fontSize: 11);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                VerificationPassword(email: _emailController.text)),
                      );
                    } catch (e) {
                      Fluttertoast.showToast(
                          msg: "Error al enviar el correo.",
                          backgroundColor: Colors.red,
                          textColor: Colors.white, fontSize: 11);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.cyan,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Enviar Correo',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),

              SizedBox(height: 100),
              // Mensaje de ayuda
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            UpdatePasswordScreen(email: _emailController.text)),
                  );
                },
                child: Text(
                  '¿Necesitas ayuda?',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w600, fontSize: 12
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  void _onEmailFocusChange() {
    if (_emailFocusNode.hasFocus) {
      setState(() {
        if (_emailController.text.isEmpty) {
          emailErrorMessage = null;
        } else if (!_validateEmailDomain(_emailController.text)) {
          emailErrorMessage = 'Dominios válidos: (gmail.com, outlook.com, hotmail.com)';
        } else {
          emailErrorMessage = null;
        }
      });
    }
  }
}
