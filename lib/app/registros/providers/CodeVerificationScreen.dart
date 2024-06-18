import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/AuthProvider.dart';

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
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // Evitar que el teclado desplace la pantalla
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Ingrese el código recibido en su correo electrónico:',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD9F103),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30.0),
              Form(
                key: _formKey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    6,
                    (index) => SizedBox(
                      width: 40.0,
                      child: TextFormField(
                        controller: _codeControllers[index],
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Ingrese un número';
                          }
                          return null;
                        },
                        onChanged: (value) {
                          if (value.length == 1 &&
                              index < _codeControllers.length - 1) {
                            FocusScope.of(context).nextFocus();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 40.0),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final code = _codeControllers
                        .map((controller) => controller.text)
                        .join('');
                    try {
                      await Provider.of<AuthProvider>(context, listen: false)
                          .verifyCode(widget.email, code);
                      // Mostrar mensaje de éxito
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text(
                              'Felicidades',
                              style: TextStyle(
                                color: Color(0xFF15B903),
                                fontWeight: FontWeight.bold,
                                fontSize: 24.0,
                              ),
                            ),
                            content: Text(
                              '¡Su cuenta ha sido verificada con éxito!',
                              style: TextStyle(
                                fontSize: 18.0,
                                color: Colors.black,
                              ),
                            ),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.pushReplacementNamed(context, '/login');
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
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
                            ],
                          );
                        },
                      );
                    } catch (e) {
                      print('Error durante la verificación del código: $e');
                      failedAttempts++; // Incrementar intentos fallidos
                      if (failedAttempts >= maxAttempts) {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          // No se puede cerrar con clic afuera
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                'Error',
                                style: TextStyle(
                                  color: Colors.red,
                                  // Color de texto negro
                                  fontWeight: FontWeight.bold,
                                  // Texto en negrita
                                  fontSize: 24.0, // Tamaño de fuente
                                ),
                              ),
                              content: Text(
                                'Se ha bloqueado la verificación por múltiples intentos incorrectos. Intente más tarde.',
                                style: TextStyle(
                                  color: Colors.black87,
                                  // Color de texto negro (más suave)
                                  fontSize: 18.0, // Tamaño de fuente
                                ),
                              ),
                              backgroundColor: Colors.white,
                              // Fondo blanco
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10.0), // Bordes redondeados
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.pushReplacementNamed(
                                        context, '/login');
                                  },
                                  child: Text(
                                    'OK',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      } else {

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text(
                                'Error',
                                style: TextStyle(
                                  color: Colors.red,
                                  // Color de texto negro
                                  fontWeight: FontWeight.bold,
                                  // Texto en negrita
                                  fontSize: 24.0, // Tamaño de fuente
                                ),
                              ),
                              content: Text(
                                'Código de verificación incorrecto. Por favor, inténtelo de nuevo.',
                                style: TextStyle(
                                  color: Colors.black87,
                                  // Color de texto negro (más suave)
                                  fontSize: 18.0, // Tamaño de fuente
                                ),
                              ),
                              backgroundColor: Colors.white,
                              // Fondo blanco
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10.0), // Bordes redondeados
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'OK',
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18.0,
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
                  backgroundColor: Color(0xFF4FD905),
                  padding: EdgeInsets.symmetric(horizontal: 35, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  'Verificar código',
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
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
