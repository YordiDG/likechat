import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/AuthProvider.dart';
import 'ForgotPasswordScreen.dart';

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
  int _loginAttempts = 0;
  DateTime? _lockoutEndTime;

  @override
  Widget build(BuildContext context) {
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
                  controller: _emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    label: Container(
                      padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 5.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Email',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFFD9F103), width: 4.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    prefixIcon: Icon(Icons.email, color: Colors.black),
                    errorText: _showEmailError ? 'Correo electrónico inválido' : null,
                    errorStyle: TextStyle(
                      color: Color(0xFFFF0E0E),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0), // Padding adicional
                  ),
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: Colors.black),
                ),

                SizedBox(height: 22),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    label: Container(
                      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 5.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Password',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFFD9F103), width: 4.0),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.grey, width: 1.0),
                    ),
                    prefixIcon: Icon(Icons.lock, color: Colors.black),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: Colors.black,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                    errorText: _showPasswordError ? 'Contraseña incorrecta' : null,
                    errorStyle: TextStyle(
                      color: Color(0xFFFF0E0E),
                    ),
                    contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0), // Padding adicional
                  ),
                  style: TextStyle(color: Colors.black),
                ),

                SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (_lockoutEndTime != null &&
                          DateTime.now().isBefore(_lockoutEndTime!)) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                padding: EdgeInsets.all(16),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Cuenta bloqueada',
                                      style: TextStyle(
                                        color: Color(0x00ffffff),
                                        fontSize: 23,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    Text(
                                      'Su cuenta se ha bloqueado por datos incorrectos. Vuelva a intentar más tarde.',
                                      style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        foregroundColor: Colors.red,
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      child: Text(
                                        'OK',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                        return;
                      }

                      setState(() {
                        _showEmailError = false;
                        _showPasswordError = false;
                      });

                      try {
                        await Provider.of<AuthProvider>(context, listen: false)
                            .login(
                          _emailController.text,
                          _passwordController.text,
                        );
                        Navigator.pushReplacementNamed(context, '/home');
                      } catch (e) {
                        setState(() {
                          if (_emailController.text.isEmpty ||
                              !RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                  .hasMatch(_emailController.text)) {
                            _showEmailError = true;
                          }
                          if (_passwordController.text.isEmpty ||
                              _passwordController.text.length < 6) {
                            _showPasswordError = true;
                          }
                        });

                        _loginAttempts += 1;
                        if (_loginAttempts >= 3) {
                          if (_lockoutEndTime == null) {
                            _lockoutEndTime =
                                DateTime.now().add(Duration(minutes: 10));
                          } else {
                            _lockoutEndTime =
                                DateTime.now().add(Duration(days: 5));
                          }

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0), // Agrega padding en los laterales
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(1),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    padding: EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'Cuenta bloqueada',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Icon(Icons.lock),
                                        SizedBox(height: 16),
                                        Text(
                                          'Su cuenta se ha bloqueado temporalmente. Vuelva a intentar en 10 días.',
                                          style: TextStyle(color: Colors.black, fontSize: 20),
                                          textAlign: TextAlign.justify, // Texto justificado
                                        ),
                                        SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          style: ElevatedButton.styleFrom(
                                            foregroundColor: Colors.white,
                                            backgroundColor: Colors.red,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: Text('OK'),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Login failed')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFD9F103),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D0D55),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => RecoverPasswordScreen()),
                    );
                  },
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(
                      color: Color(0xFFD9F103),
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 25),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/register');
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.transparent),
                    foregroundColor: MaterialStateProperty.all<Color>(Color(0xFFD9F103)),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 20, // Tamaño de fuente de "Register"
                        color: Color(0xFFD9F103),
                      ),
                      children: [
                        TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFFB3C708),
                          ),
                        ),
                        TextSpan(
                          text: "Register",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )

              ],
            ),
          ),
        ),
      ),
    );
  }
}
