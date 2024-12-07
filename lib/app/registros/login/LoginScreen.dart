import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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

  bool _isLoading = false;

  final GoogleSignIn _googleSignIn = GoogleSignIn();


  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final backgroundColor = darkModeProvider.backgroundColor;

    final borderColor =
        darkModeProvider.isDarkMode ? Colors.cyan : Colors.black;
    final fillColorEmail =
        darkModeProvider.isDarkMode ? Colors.black : Colors.white;
    final fillColorPassword = darkModeProvider.isDarkMode
        ? Colors.white
        : Colors.cyan.withOpacity(0.1);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Center(
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
                    _buildEmailField(
                        borderColor, fillColorEmail, iconColor, textColor),
                    SizedBox(height: 22),
                    _buildPasswordField(borderColor, iconColor, textColor),
                    SizedBox(height: 40),
                    _buildLoginButton(isDarkMode),
                    _buildRecoverPasswordButton(context, isDarkMode),
                    SizedBox(height: 15),
                    _buildGoogleLoginButton(),
                    _buildRegisterButton(context, isDarkMode, textColor),
                  ],
                ),
              ),
            ),
          ),
          // Indicador de carga
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              // Fondo oscuro semitransparente
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.all(20),
                width: 230,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  // Ajuste de tamaño al contenido
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Colors.cyan,
                    ),
                    SizedBox(height: 20),
                    Text(
                      "Verificando",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w700
                      ),
                    ),
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }


  Widget _buildEmailField(Color borderColor, Color fillColorEmail,
      Color iconColor, Color textColor) {
    return TextField(
      cursorColor: Colors.cyan,
      controller: _emailController,
      decoration: InputDecoration(
        filled: false, //true hce el input de fondo blanco
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
          borderSide: BorderSide(color: Colors.cyan, width: 2.0),
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
    );
  }

  Widget _buildPasswordField(
      Color borderColor, Color iconColor, Color textColor) {
    return TextField(
      cursorColor: Colors.cyan,
      controller: _passwordController,
      obscureText: _obscureText,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.transparent,
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
        errorText: _showPasswordError
            ? 'Contraseña incorrecta. Verifica e intenta nuevamente.'
            : null,
        errorStyle: TextStyle(color: Color(0xFFFF0E0E)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.cyan, width: 2.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: _isPasswordEmpty ? Color(0xFFFF0E0E) : borderColor,
          ),
        ),
      ),
      style: TextStyle(color: textColor),
    );
  }

  Widget _buildLoginButton(bool isDarkMode) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => _handleLogin(isDarkMode),
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
    );
  }

  Widget _buildRecoverPasswordButton(BuildContext context, bool isDarkMode) {
    return TextButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RecoverPasswordScreen()),
        );
      },
      child: Text(
        '¿Olvidaste tu contraseña?',
        style: TextStyle(
          color: isDarkMode ? Colors.cyan : Color(0xFF068C8C),
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildGoogleLoginButton() {
    return ElevatedButton(
      onPressed: _loginWithGoogle,
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: Colors.black, width: 2),
        ),
        padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'lib/assets/logo_google_login.png',
            height: 24,
          ),
          SizedBox(width: 8),
          Text(
            'Iniciar sesión con Google',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D0D55),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton(
      BuildContext context, bool isDarkMode, Color textColor) {
    return TextButton(
      onPressed: () {
        Navigator.pushReplacementNamed(context, '/register');
      },
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
                color: isDarkMode ? Colors.cyan : Color(0xFF068C8C),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin(bool isDarkMode) async {
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

    // Verifica la conexión a Internet
    var connectivityResult = await Connectivity().checkConnectivity();
    Duration delayDuration;

    // Ajusta el tiempo de espera según el tipo de conexión
    if (connectivityResult == ConnectivityResult.mobile) {
      delayDuration = Duration(seconds: 2); // Conexión móvil
    } else if (connectivityResult == ConnectivityResult.wifi) {
      delayDuration = Duration(seconds: 2); // Conexión Wi-Fi
    } else {
      // Si no hay conexión a Internet, muestra el mensaje y regresa
      Fluttertoast.showToast(
        msg: "No hay conexión a Internet",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    setState(() {
      _isLoading = true; // Activa el indicador de carga
    });

    try {
      await Provider.of<AuthProvider>(context, listen: false).login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );

      // Espera según el tipo de conexión para que se vea el indicador de carga
      await Future.delayed(delayDuration);

      setState(() {
        _isLoading = false; // Desactiva el indicador de carga
      });

      // Muestra el toast de éxito
      Fluttertoast.showToast(
        msg: "Datos validados correctamente",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      setState(() {
        _isLoading = false; // Desactiva el indicador de carga en caso de error
      });
      _handleLoginError(e, isDarkMode);
    }
  }

  void _handleLoginError(Object e, bool isDarkMode) {
    String errorMessage;

    // Establecer el mensaje de error en función del tipo de excepción
    if (e is Exception) {
      if (e.toString().contains('Unauthorized')) {
        errorMessage =
            'Correo inválido o no autenticado. Por favor, revisa tu correo.';
      } else if (e.toString().contains('Invalid email format') ||
          e.toString().contains('Email not authenticated')) {
        errorMessage =
            'El formato del correo es inválido. Asegúrate de ingresarlo correctamente.';
      } else if (e.toString().contains('Invalid password')) {
        errorMessage =
            'Contraseña incorrecta. Verifica que has ingresado la contraseña correcta.';
      } else {
        errorMessage = 'Ocurrió un error inesperado. Intenta nuevamente.';
      }
    } else {
      errorMessage =
          'Error desconocido. Por favor, intenta de nuevo más tarde.';
    }

    // Mostrar el mensaje de error como un Toast
    Fluttertoast.showToast(
      msg: errorMessage,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey[850],
      textColor: Colors.white,
      fontSize: 14.0,
    );

    _loginAttempts += 1;
    if (_loginAttempts >= 3) {
      _handleAccountLock(isDarkMode);
    }
  }

  //bloquea multiples intentod
  void _handleAccountLock(bool isDarkMode) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final backgroundColor = darkModeProvider.backgroundColor;

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
              borderRadius: BorderRadius.circular(15),
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color:
                      isDarkMode ? Colors.grey.shade900 : Colors.grey.shade500,
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
                      child: const Text('OK',
                          style: TextStyle(color: Colors.white)),
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

  //sesion con google
  void _loginWithGoogle() async {
    try {
      await _googleSignIn.signIn();
      Navigator.pushReplacementNamed(context, '/home');
    } catch (error) {
      print(error);
      Fluttertoast.showToast(
        msg:
        'Se produjo un error al iniciar sesión con Google. Inténtalo nuevamente.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.grey[850],
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }

}
