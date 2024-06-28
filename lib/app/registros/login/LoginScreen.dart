import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/AuthProvider.dart';
import 'ForgotPasswordScreen.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  void _loginWithGoogle() async {
    try {
      await _googleSignIn.signIn();
      Navigator.pushReplacementNamed(context, '/home');
    } catch (error) {
      print(error);
    }
  }

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
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email, color: Colors.black),
                    errorText: _showEmailError ? 'Correo electrónico inválido' : null,
                    errorStyle: TextStyle(color: Color(0xFFFF0E0E)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.black, width: 4.0),
                    ),
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
                    labelText: 'Password',
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
                    errorStyle: TextStyle(color: Color(0xFFFF0E0E)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Colors.black, width: 4.0),
                    ),
                  ),
                  style: TextStyle(color: Colors.black),
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
                      });

                      try {
                        await Provider.of<AuthProvider>(context, listen: false)
                            .login(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                        );
                        Navigator.pushReplacementNamed(context, '/home');
                      } catch (e) {
                        setState(() {
                          if (e.toString().contains('Invalid email format')) {
                            _showEmailError = true;
                          } else if (e.toString().contains('Invalid password')) {
                            _showPasswordError = true;
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
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
                                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
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
                                          style: TextStyle(color: Colors.black, fontSize: 16),
                                          textAlign: TextAlign.justify,
                                        ),
                                        SizedBox(height: 16),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          style: ElevatedButton.styleFrom(
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
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF0D0D55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD9F103),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RecoverPasswordScreen()),
                    );
                  },
                  child: Text(
                    'Forgot password?',
                    style: TextStyle(
                      color: Color(0xFF99A804),
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: 25),
                ElevatedButton(
                  onPressed: _loginWithGoogle,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black, backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(color: Colors.black, width: 2),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 14, horizontal: 80),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'lib/assets/logo_google_login.png',
                        height: 24,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Sign in with Google',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0D0D55),
                        ),
                      ),
                    ],
                  ),
                ),
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
                        fontSize: 20,
                        color: Color(0xFF0D0D55),
                      ),
                      children: [
                        TextSpan(
                          text: "Don't have an account? ",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF0D0D55),
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
