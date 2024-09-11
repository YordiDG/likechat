import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Globales/estadoDark-White/DarkModeProvider.dart';
import '../providers/AuthProvider.dart';
import 'ForgotPasswordScreen.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _showEmailError = false;
  bool _showPasswordError = false;
  bool _isEmailEmpty = false;
  bool _isPasswordEmpty = false;
  int _loginAttempts = 0;
  DateTime? _lockoutEndTime;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  void _loginWithGoogle() async {
    try {
      await _googleSignIn.signIn();
      Navigator.pushReplacementNamed(context, '/home');
    } catch (error) {
      print(error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Error al iniciar sesión con Google. Inténtalo nuevamente.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final backgroundColor = darkModeProvider.backgroundColor;

    final borderColor = darkModeProvider.isDarkMode ? Colors.cyan : Colors.black;
    final fillColorEmail = darkModeProvider.isDarkMode ? Colors.black : Colors.white;
    final fillColorPassword = darkModeProvider.isDarkMode ? Colors.white : Colors.cyan.withOpacity(0.1);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 200,
                  child: Image.asset('lib/assets/logo.png'),
                ),
                SizedBox(height: 20),
                TextField(
                  cursorColor: Colors.cyan,
                  controller: _emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: fillColorEmail,
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email, color: iconColor),
                    errorText: _showEmailError ? 'Correo inválido o no autenticado' : null,
                    errorStyle: TextStyle(color: Color(0xFFFF0E0E)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: borderColor, width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: _isEmailEmpty ? Color(0xFFFF0E0E) : borderColor,
                      ),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: textColor),
                ),
                SizedBox(height: 22),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: darkModeProvider.isDarkMode ? Colors.transparent : Colors.white,
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock, color: iconColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: iconColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                    errorText: _showPasswordError ? 'Contraseña incorrecta. Verifica e intenta nuevamente.' : null,
                    errorStyle: TextStyle(color: Color(0xFFFF0E0E)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: borderColor, width: 2.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: _isPasswordEmpty ? Color(0xFFFF0E0E) : borderColor,
                      ),
                    ),
                  ),
                  style: TextStyle(color: textColor),
                ),

                SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        _showEmailError = false;
                        _showPasswordError = false;
                        _isEmailEmpty = _emailController.text.trim().isEmpty;
                        _isPasswordEmpty = _passwordController.text.trim().isEmpty;
                      });

                      if (_isEmailEmpty || _isPasswordEmpty) {
                        setState(() {
                          if (_isEmailEmpty) _showEmailError = true;
                          if (_isPasswordEmpty) _showPasswordError = true;
                        });
                        return;
                      }

                      try {
                        await Provider.of<AuthProvider>(context, listen: false).login(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );
                        Navigator.pushReplacementNamed(context, '/home');
                      } catch (e) {
                        setState(() {
                          if (e.toString().contains('Unauthorized')) {
                            _showEmailError = true;
                            _showPasswordError = true;
                          } else if (e.toString().contains('Invalid email format') ||
                              e.toString().contains('Email not authenticated')) {
                            _showEmailError = true;
                          } else if (e.toString().contains('Invalid password')) {
                            _showPasswordError = true;
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error inesperado: $e')),
                            );
                          }
                        });

                        _loginAttempts += 1;
                        if (_loginAttempts >= 3) {
                          if (_lockoutEndTime == null) {
                            _lockoutEndTime = DateTime.now().add(Duration(minutes: 10));
                          } else {
                            _lockoutEndTime = DateTime.now().add(Duration(days: 5));
                          }

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                  child: Material(
                                    borderRadius: BorderRadius.circular(15), // Asegura que el dialogo tenga el material necesario
                                    color: Colors.transparent, // Hace que el material sea transparente
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: isDarkMode ? Colors.grey.shade900 : Colors.grey.shade500,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Cuenta bloqueada',
                                            style: TextStyle(
                                              color: textColor,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 16),
                                          const Icon(Icons.lock, size: 30),
                                          const SizedBox(height: 16),
                                          Text(
                                            'Debido a múltiples intentos fallidos, tu cuenta ha sido bloqueada temporalmente. Vuelve a intentar en 10 minutos.',
                                            style: TextStyle(color: textColor, fontSize: 16),
                                            textAlign: TextAlign.justify,
                                          ),
                                          const SizedBox(height: 16),
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.pink,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                            child: const Text('OK', style: TextStyle(color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          );

                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyan,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Iniciar sesión',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 1),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RecoverPasswordScreen()),
                    );
                  },
                  child: Text(
                    '¿Olvidaste tu contraseña?',
                    style: TextStyle(
                      color: Colors.cyan,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                ElevatedButton(
                  onPressed: _loginWithGoogle,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.black, width: 2),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16), // Ajusta el padding horizontal
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.max, // Asegura que el Row ocupe todo el ancho disponible
                    mainAxisAlignment: MainAxisAlignment.center, // Centra los elementos dentro del Row
                    crossAxisAlignment: CrossAxisAlignment.center, // Alinea verticalmente los elementos en el centro
                    children: [
                      Image.asset(
                        'lib/assets/logo_google_login.png',
                        height: 24,
                      ),
                      SizedBox(width: 8), // Espacio entre el icono y el texto
                      Text(
                        'Iniciar sesión con Google',
                        textAlign: TextAlign.center, // Centra el texto dentro del Row
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D0D55),
                        ),
                        overflow: TextOverflow.ellipsis, // Muestra "..." si el texto es demasiado largo
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/register');
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.transparent),
                  ),
                  child: RichText(
                    text: TextSpan(
                      text: '¿No tienes una cuenta? ',
                      style: TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: 'Regístrate',
                          style: TextStyle(
                            color: Colors.cyan,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
