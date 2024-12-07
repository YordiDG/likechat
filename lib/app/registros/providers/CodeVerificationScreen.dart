import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../Globales/estadoDark-White/DarkModeProvider.dart';
import '../providers/AuthProvider.dart';
import 'package:lottie/lottie.dart';

class CodeVerificationScreen extends StatefulWidget {
  final String email;

  CodeVerificationScreen({required this.email});

  @override
  _CodeVerificationScreenState createState() => _CodeVerificationScreenState();
}

class _CodeVerificationScreenState extends State<CodeVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeControllers = List.generate(6, (index) => TextEditingController());
  int failedAttempts = 0;
  final int maxAttempts = 5; // Límite de intentos fallidos

  @override
  Widget build(BuildContext context) {

    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final backgroundColor = darkModeProvider.backgroundColor;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icono grande encima del texto
              Icon(
                Icons.verified,
                color: Colors.cyan,
                size: 100.0,
              ),

              SizedBox(height: 20.0),

              Text(
                'Ingrese el código recibido en su correo electrónico:',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 60.0),

              Form(
                key: _formKey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 43.0,
                      child: StatefulBuilder(
                        builder: (BuildContext context, StateSetter setState) {
                          FocusNode _focusNode = FocusNode();
                          bool _isError = false;

                          return TextFormField(
                            controller: _codeControllers[index],
                            keyboardType: TextInputType.text, // Activación del teclado alfanumérico
                            textCapitalization: TextCapitalization.characters, // Convierte el texto a mayúsculas
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')), // Permite letras y números
                            ],
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            focusNode: _focusNode,
                            cursorColor: Colors.cyan,
                            style: const TextStyle(
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.cyan, // Color del texto en el casillero
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: backgroundColor, // Color de fondo del casillero
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                  color: _isError ? Colors.pink : Colors.grey,
                                  width: 2.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                  color: Colors.cyan,
                                  width: 2.0,
                                ),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                  color: Colors.pink,
                                  width: 2.0,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                setState(() {
                                  _isError = true;
                                });
                                return 'Ingrese un número';
                              }
                              setState(() {
                                _isError = false;
                              });
                              return null;
                            },
                            onChanged: (value) {
                              if (value.length == 1 && index < _codeControllers.length - 1) {
                                FocusScope.of(context).nextFocus();
                              } else if (value.length == 1 && index == _codeControllers.length - 1) {
                                FocusScope.of(context).unfocus();
                              }
                            },
                          );
                        },
                      ),
                    );
                  }),
                ),
              ),
              SizedBox(height: 30.0),
              ElevatedButton(
                onPressed: () async {
                  // Código de verificación
                  if (_formKey.currentState!.validate()) {
                    final code = _codeControllers
                        .map((controller) => controller.text)
                        .join('');
                    try {
                      await Provider.of<AuthProvider>(context, listen: false)
                          .verifyCode(widget.email, code);

                      // Valida success
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            backgroundColor: isDarkMode ? Colors.grey.shade800 : Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 150,
                                  height: 150,
                                  color: Colors.transparent,
                                  child: Lottie.asset(
                                    'lib/assets/code_success.json',
                                    width: 150,
                                    height: 150,
                                    fit: BoxFit.fill,
                                  ),
                                ),
                                SizedBox(height: 20.0),
                                Text(
                                  '¡Su cuenta ha sido verificada con éxito!',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                          );
                        },
                      );

                      // Espera de 3 segundos antes de redirigir al login
                      await Future.delayed(Duration(seconds: 4));
                      Navigator.of(context).pop(); // Cerrar el diálogo
                      Navigator.pushReplacementNamed(context, '/login');
                    } catch (e) {
                      // Manejo de errores
                      print('Error durante la verificación del código: $e');
                      failedAttempts++;
                      if (failedAttempts >= maxAttempts) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                'Error',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 22.0,
                                ),
                              ),
                              content: Text(
                                'Se ha bloqueado la verificación por múltiples intentos incorrectos. Intente más tarde.',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16.0,
                                ),
                              ),
                              backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              actions: [
                                Center(
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      Navigator.pushReplacementNamed(
                                          context, '/login');
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 40.0, vertical: 10.0),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius:
                                        BorderRadius.circular(10.0),
                                      ),
                                      child: Text(
                                        'OK',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      } else {
                        _codeControllers
                            .forEach((controller) => controller.clear());
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                'Error',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 22.0,
                                ),
                              ),
                              content: Text(
                                'Código de verificación incorrecto. Por favor, inténtelo de nuevo.',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 16.0,
                                ),
                              ),
                              backgroundColor: isDarkMode ? Colors.grey.shade900 : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              actions: [
                                Center(
                                  child: TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 40.0, vertical: 10.0),
                                      decoration: BoxDecoration(
                                        color: Colors.cyan,
                                        borderRadius:
                                        BorderRadius.circular(10.0),
                                      ),
                                      child: Text(
                                        'OK',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18.0,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Color(0xFF0D0D55),
                  backgroundColor: Colors.cyan,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Text(
                  'Verificar código',
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
