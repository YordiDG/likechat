import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/AuthProvider.dart';

class VerificationPassword extends StatefulWidget {
  final String email;

  VerificationPassword({required this.email});

  @override
  _VerificationPassword createState() => _VerificationPassword();
}

class _VerificationPassword extends State<VerificationPassword> {
  final _formKey = GlobalKey<FormState>();
  final _codeControllers = List.generate(6, (index) => TextEditingController());
  int failedAttempts = 0;
  final int maxAttempts = 5;

  void _clearAllFields() {
    for (var controller in _codeControllers) {
      controller.clear();
    }
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF9B30FF),
              Color(0xFF00BFFF),
              Color(0xFF00FFFF),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      'Ingrese el código recibido en su correo electrónico:',
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF333333),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 40.0),
                  Form(
                    key: _formKey,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        6,
                            (index) => SizedBox(
                          width: 45.0,
                          child: TextFormField(
                            controller: _codeControllers[index],
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            textAlign: TextAlign.center,
                            maxLength: 1,
                            style: TextStyle(
                              fontSize: 26.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            decoration: InputDecoration(
                              counterText: '',
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.3),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide.none,
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12.0),
                                borderSide: BorderSide(color: Colors.white, width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return '';
                              }
                              return null;
                            },
                            onChanged: (value) {
                              if (value.length == 1 && index < _codeControllers.length - 1) {
                                FocusScope.of(context).nextFocus();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 50.0),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          final code = _codeControllers.map((controller) => controller.text).join('');
                          try {
                            await Provider.of<AuthProvider>(context, listen: false)
                                .verifyCode(widget.email, code);

                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  title: Icon(
                                    Icons.check_circle,
                                    color: Color(0xFF15B903),
                                    size: 50,
                                  ),
                                  content: Text(
                                    '¡Su cuenta ha sido verificada con éxito!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14.0,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  actions: [
                                    Container(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          Navigator.pushReplacementNamed(context, '/login');
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF15B903),
                                          padding: EdgeInsets.symmetric(vertical: 15),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        child: Text(
                                          'Continuar',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          } catch (e) {
                            print('Error durante la verificación del código: $e');
                            setState(() {
                              failedAttempts++;
                              _clearAllFields();
                            });

                            if (failedAttempts >= maxAttempts) {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15.0),
                                    ),
                                    title: Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 50,
                                    ),
                                    content: Text(
                                      'Se ha bloqueado la verificación por múltiples intentos incorrectos. Intente más tarde.',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    actions: [
                                      Container(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            Navigator.pushReplacementNamed(context, '/recover_password');
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                            padding: EdgeInsets.symmetric(vertical: 15),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          child: Text(
                                            'Entendido',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Código incorrecto. Intentos restantes: ${maxAttempts - failedAttempts}',
                                    style: TextStyle(color: Colors.white, fontSize: 12),
                                  ),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              );
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Color(0xFF9B30FF),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                      ),
                      child: Text(
                        'Verificar código',
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}