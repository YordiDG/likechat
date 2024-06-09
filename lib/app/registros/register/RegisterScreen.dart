import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/AuthProvider.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dobDayController = TextEditingController();
  final _dobMonthController = TextEditingController();
  final _dobYearController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  String _selectedGender = 'Male';
  bool _obscurePassword = true;
  bool _acceptTerms = false;

  bool _isRegistered = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(30.10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    Text(
                      'LikeChat',
                      style: TextStyle(
                        fontSize: 37,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFD9F103),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Crear una cuenta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 25),
              _buildTextField('First Name', _firstNameController),
              SizedBox(height: 25),
              _buildTextField('Last Name', _lastNameController),
              SizedBox(height: 25),
              _buildEmailField('Email', _emailController),
              SizedBox(height: 19),
              _buildPasswordField('Password', _passwordController),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'Day',
                      _dobDayController,
                      keyboardType: TextInputType.number,
                      maxLength: 2,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      'Month',
                      _dobMonthController,
                      keyboardType: TextInputType.number,
                      maxLength: 2,
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                      'Year',
                      _dobYearController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 28),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  height: 100,
                  width: 500.0,
                  child: DropdownButtonFormField<String>(
                    value: _selectedGender,
                    items: ['Male', 'Female', 'Other'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedGender = newValue!;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      filled: true,
                      fillColor: Colors.transparent,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Color(0xFFD9F103)),
                      ),
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                    dropdownColor: Color(0xFF3A3A8F),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 4),
              Row(
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    onChanged: (bool? value) {
                      setState(() {
                        _acceptTerms = value!;
                      });
                    },
                    activeColor: Color(0xFFD9F103),
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Aceptar ',
                            style: TextStyle(color: Colors.white),
                          ),
                          TextSpan(
                            text: 'Condiciones',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Agrega aquí la lógica para el enlace
                              },
                          ),
                          TextSpan(
                            text: ' y ',
                            style: TextStyle(color: Colors.white),
                          ),
                          TextSpan(
                            text: 'Política de Privacidad',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // Agrega aquí la lógica para el enlace
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),

              ElevatedButton(
                onPressed: () async {
                  String? errorMessage = _validateFields();
                  if (errorMessage != null) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return Theme(
                          data: ThemeData(
                            dialogBackgroundColor: Colors.red.withOpacity(0.9),
                            textTheme: TextTheme(
                              bodyText1: TextStyle(color: Colors.white),
                            ),
                          ),
                          child: AlertDialog(
                            title: Text('Error de registro', style: TextStyle(color: Colors.white)),
                            content: Text(errorMessage, style: TextStyle(color: Colors.white)),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('OK', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                    return;
                  }

                  try {
                    await Provider.of<AuthProvider>(context, listen: false).register(
                      _usernameController.text,
                      _emailController.text,
                      _passwordController.text,
                      _firstNameController.text,
                      _lastNameController.text,
                      "${_dobYearController.text}-${_dobMonthController.text.padLeft(2, '0')}-${_dobDayController.text.padLeft(2, '0')}",
                      _acceptTerms,
                    );

                    if (!_isRegistered) {
                      _isRegistered = true; // Marcar que ya se mostró el diálogo
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Theme(
                            data: ThemeData(
                              dialogBackgroundColor: Colors.green.withOpacity(0.9),
                              textTheme: TextTheme(
                                bodyText1: TextStyle(color: Colors.white),
                              ),
                            ),
                            child: AlertDialog(
                              title: Text('Registro exitoso', style: TextStyle(color: Colors.white)),
                              content: Text('¡Registro exitoso!', style: TextStyle(color: Colors.white)),
                            ),
                          );
                        },
                      );

                      await Future.delayed(Duration(seconds: 2));

                      Navigator.pushReplacementNamed(context, '/login');
                    }
                  } catch (e) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.transparent,
                          content: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Registro fallido',
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Hubo un error durante el registro. Por favor, inténtelo de nuevo.',
                                  style: TextStyle(color: Colors.white),
                                ),
                                SizedBox(height: 16),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'OK',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFD9F103),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: Text(
                    'Registro',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF0D0D55),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 8),
              SizedBox(height: 7),
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: Text(
                    '¿Ya tienes una cuenta?',
                    style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                      fontSize: 17,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateFields() {
    // Validar campos individualmente
    if (_firstNameController.text.isEmpty) {
      return 'Por favor, ingrese su nombre.';
    }
    if (_lastNameController.text.isEmpty) {
      return 'Por favor, ingrese su apellido.';
    }
    if (_emailController.text.isEmpty) {
      return 'Por favor, ingrese su correo electrónico.';
    }
    if (!validateEmail(_emailController.text)) {
      return 'Ingrese un correo electrónico válido.';
    }
    if (_passwordController.text.isEmpty) {
      return 'Por favor, ingrese su contraseña.';
    }
    if (!(_passwordController.text.length >= 8 &&
        _passwordController.text.contains(new RegExp(r'[A-Za-z]')) &&
        _passwordController.text.contains(new RegExp(r'[0-9]')) &&
        _passwordController.text.contains(new RegExp(r'[!@#$%^&*(),.?":{}|<>]')))) {
      return 'La contraseña debe tener al menos 8 caracteres, una letra, un número y un símbolo.';
    }
    if (!_validateBirthday()) {
      return 'Fecha de nacimiento no válida. Debe tener al menos 18 años.';
    }
    if (!_acceptTerms) {
      return 'Debe aceptar los términos y condiciones para continuar.';
    }
    return null;
  }


  Widget _buildTextField(
      String labelText,
      TextEditingController controller, {
        TextInputType keyboardType = TextInputType.text,
        int? maxLength,
      }) {
    bool showError = false;
    String? errorText;
    // Validar el campo
    if (labelText == 'First Name' && controller.text.isEmpty) {
      showError = true;
      errorText = 'Por favor, ingrese su nombre.';
    } else if (labelText == 'Last Name' && controller.text.isEmpty) {
      showError = true;
      errorText = 'Por favor, ingrese su apellido.';
    }


    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength, // Usar el valor de maxLength si se proporciona
      decoration: InputDecoration(
        labelText: labelText,
        counterText: '', // Desactivar el contador de longitud máxima
        filled: true,
        fillColor: Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: showError ? Colors.red.withOpacity(0.5) : Colors.white,
            width: 2.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Color(0xFFD9F103), width: 2.0),
        ),
        labelStyle: TextStyle(color: Colors.white),
        errorText: showError ? errorText : null, // Mostrar el mensaje de error si corresponde
      ),
      style: TextStyle(
        color: Colors.white,
      ),
    );
  }


  Widget _buildEmailField(String labelText, TextEditingController controller) {
    bool showError = false;
    Timer? _timer;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: labelText,
            filled: true,
            fillColor: Colors.transparent,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white, width: 2.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color(0xFFD9F103), width: 2.0),
            ),
            labelStyle: TextStyle(color: Colors.white),
          ),
          style: TextStyle(color: Colors.white),
          onChanged: (value) {
            setState(() {
              showError = !validateEmail(value);
              _timer?.cancel();
              // Inicia un temporizador para ocultar el mensaje de error después de 2 segundos
              _timer = Timer(Duration(seconds: 2), () {
                setState(() {
                  showError = false;
                });
              });
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Ingrese un correo electrónico';
            } else if (!validateEmail(value)) {
              return 'Ingrese un correo electrónico válido';
            }
            return null;
          },
        ),
        AnimatedOpacity(
          duration: Duration(milliseconds: 500),
          opacity: showError ? 1.0 : 0.0,
          child: Container(
            margin: EdgeInsets.only(top: 4),
            child: Text(
              'Ingrese un correo válido',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }


  bool validateEmail(String email) {
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(email)) {
      return false;
    }

    final allowedDomains = ['gmail.com', 'hotmail.com', 'outlook.com'];

    final domain = email.split('@').last;

    if (!allowedDomains.contains(domain)) {
      return false;
    }

    return true;
  }

  bool _validateBirthday() {
    final int day = int.tryParse(_dobDayController.text.padLeft(2, '0')) ?? 0;
    final int month = int.tryParse(_dobMonthController.text.padLeft(2, '0')) ?? 0;
    final int year = int.tryParse(_dobYearController.text.substring(0, 4).padLeft(4, '0')) ?? 0;

    final DateTime now = DateTime.now();

    // Validar que el día sea válido (1-31)
    if (day < 1 || day > 31) {
      return false;
    }

    // Validar que el mes sea válido (1-12)
    if (month < 1 || month > 12) {
      return false;
    }

    // Validar el número de días según el mes
    if (day > 28 && month == 2) {
      // Febrero tiene máximo 28 días (sin tener en cuenta años bisiestos)
      return false;
    }
    if ((day > 30 && (month == 4 || month == 6 || month == 9 || month == 11)) || day > 31) {
      // Abril, junio, septiembre y noviembre tienen máximo 30 días
      // Otros meses tienen máximo 31 días
      return false;
    }

    final DateTime birthday = DateTime(year, month, day);

    int age = now.year - birthday.year;

    if (now.month < birthday.month ||
        (now.month == birthday.month && now.day < birthday.day)) {
      age--;
    }

    return age >= 18 && year <= now.year;
  }


  Widget _buildPasswordField(
      String labelText, TextEditingController controller) {
    bool showError = false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          keyboardType: TextInputType.text,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: labelText,
            filled: true,
            fillColor: Colors.transparent,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.white, width: 2.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color(0xFFD9F103), width: 2.0),
            ),
            labelStyle: TextStyle(color: Colors.white),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          style: TextStyle(color: Colors.white),
          onChanged: (value) {
            showError = !(value.length >= 8 &&
                value.contains(new RegExp(r'[A-Za-z]')) &&
                value.contains(new RegExp(r'[0-9]')) &&
                value.contains(new RegExp(r'[!@#$%^&*(),.?":{}|<>]')));
            setState(() {});
          },
        ),
        AnimatedOpacity(
          duration: Duration(milliseconds: 500),
          opacity: showError ? 1.0 : 0.0,
          child: Container(
            margin: EdgeInsets.only(top: 4),
            child: Text(
              'La contraseña debe tener al menos 8 caracteres, una letra, un número y un símbolo.',
              style: TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
