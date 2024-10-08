import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../Globales/estadoDark-White/DarkModeProvider.dart';
import '../providers/AuthProvider.dart';
import '../providers/CodeVerificationScreen.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

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

  final _codeControllers = List.generate(6, (index) => TextEditingController());

  bool _isRegistered = false;

  //email
  final FocusNode _emailFocusNode = FocusNode();
  String? emailErrorMessage;

  //Validaciones de password
  final FocusNode _passwordFocusNode = FocusNode();
  bool hasMinLength = false;
  bool hasLetter = false;
  bool hasNumber = false;
  bool hasSpecialChar = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();

    _emailFocusNode.addListener(_onEmailFocusChange);
    
    _passwordFocusNode.addListener(() {
      if (!_passwordFocusNode.hasFocus) {
        resetValidators();
      }
    });

  }

  @override
  void dispose() {

    _emailController.dispose();
    _emailFocusNode.dispose();
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final backgroundColor = darkModeProvider.backgroundColor;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/login');
        return false; // Prevent default back button behavior
      },
      child: Scaffold(
        backgroundColor: isDarkMode ? Color(0xFF0F101B) : Colors.white,
        body: Padding(
          padding: EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Text(
                        'LikeChat',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: isDarkMode ? Colors.cyan : Colors.black,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Crear una cuenta',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                _buildTextField('First Name', _firstNameController),
                SizedBox(height: 10),
                _buildTextField('Last Name', _lastNameController),
                SizedBox(height: 10),
                _buildEmailField('Email', _emailController),
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
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
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
                        _selectedGender = newValue ?? _selectedGender;
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
                        borderSide: BorderSide(color: Colors.cyan, width: 2.0),
                      ),
                      labelStyle: TextStyle(color: textColor),
                    ),
                    dropdownColor: Colors.cyan.withOpacity(0.9),
                    style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
                  ),
                ),
                Row(
                  children: [
                    Checkbox(
                      value: _acceptTerms,
                      onChanged: (bool? value) {
                        setState(() {
                          _acceptTerms = value ?? false;
                        });
                      },
                      activeColor: Colors.cyan,
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Aceptar ',
                              style: TextStyle(color: textColor, fontSize: 15),
                            ),
                            TextSpan(
                              text: 'Condiciones ',
                              style: TextStyle(
                                color: Colors.cyan,
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  // Agrega aquí la lógica para el enlace
                                },
                            ),
                            TextSpan(
                              text: ' y ',
                              style: TextStyle(color: textColor, fontSize: 15),
                            ),
                            TextSpan(
                              text: ' Política de Privacidad',
                              style: TextStyle(
                                  color: Colors.cyan,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15),
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
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () async {
                    String? errorMessage = _validateFields();
                    if (errorMessage != null) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return Theme(
                            data: ThemeData(
                              dialogBackgroundColor: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[850] // Fondo oscuro para tema dark
                                  : Colors.white,
                              textTheme: TextTheme(
                                bodyLarge: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white // Texto blanco para tema oscuro
                                      : Colors.black, // Texto negro para tema claro
                                ),
                              ),
                            ),
                            child: AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(17), // Bordes redondeados
                              ),
                              title: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.redAccent
                                        : Colors.red,
                                  ),
                                  SizedBox(width: 10),
                                  Text(
                                    'Error de registro',
                                    style: TextStyle(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.redAccent
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              content: Text(
                                errorMessage,
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  style: TextButton.styleFrom(
                                    backgroundColor: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.redAccent
                                        : Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'OK',
                                    style: TextStyle(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                      return;
                    }

                    if (_formKey.currentState != null && !_formKey.currentState!.validate()) {
                      return;
                    }

                    try {
                      // Realizar el registro
                      await Provider.of<AuthProvider>(context, listen: false).register(
                        _firstNameController.text,
                        _lastNameController.text,
                        _emailController.text,
                        _passwordController.text,
                        "${_dobYearController.text}-${_dobMonthController.text.padLeft(2, '0')}-${_dobDayController.text.padLeft(2, '0')}",
                        _selectedGender.toUpperCase(),
                        _acceptTerms,
                      );

                      // Enviar código de verificación por correo
                      await Provider.of<AuthProvider>(context, listen: false)
                          .sendVerificationCode(_emailController.text);

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CodeVerificationScreen(
                            email: _emailController.text,
                          ),
                        ),
                      );
                    } catch (e) {
                      print('Error durante el registro: $e');

                      if (e.toString().contains('202')) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CodeVerificationScreen(
                              email: _emailController.text,
                            ),
                          ),
                        );
                      } else {
                        // Mostrar un mensaje genérico para otros errores
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
                                      style: TextStyle(color: Colors.white, fontSize: 15),
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Hubo un error durante el registro. Por favor, inténtelo de nuevo.',
                                      style: TextStyle(color: Colors.white, fontSize: 15),
                                    ),
                                    SizedBox(height: 16),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        'OK',
                                        style: TextStyle(color: Colors.white, fontSize: 15),
                                      ),
                                    ),
                                  ],
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
                    padding: EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.cyan),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      'Registro',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: '¿Ya tienes una cuenta?',
                      style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.bold),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
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


  String? _validateFields() {

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
        _passwordController.text
            .contains(new RegExp(r'[!@#$%^&*(),.?":{}|<>]')))) {
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

    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final borderColor = isDarkMode ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.5);
    final focusedBorderColor = Colors.cyan;

    bool showError = false;
    String? errorText;

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
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: labelText,
        counterText: '',
        filled: true,
        fillColor: Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: showError ? Colors.red.withOpacity(0.5) : borderColor,
            width: 2.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: focusedBorderColor, width: 2.0),
        ),
        labelStyle: TextStyle(color: textColor),
        errorText: showError ? errorText : null, // Mostrar el mensaje de error si corresponde
      ),
      style: TextStyle(
        color: textColor,
      ),
    );
  }

  //email

  Widget _buildEmailField(String labelText, TextEditingController controller) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final borderColor = isDarkMode ? Colors.white : Colors.black;
    final focusedBorderColor = Colors.cyan;
    final errorTextColor = Colors.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          focusNode: _emailFocusNode,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: labelText,
            filled: true,
            fillColor: Colors.transparent,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor, width: 2.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: focusedBorderColor, width: 2.0),
            ),
            labelStyle: TextStyle(color: textColor),
            prefixIcon: Icon(Icons.email, color: textColor),
          ),
          style: TextStyle(color: textColor),
          onChanged: (value) {
            setState(() {
              if (value.isEmpty) {
                emailErrorMessage = 'Campo email es obligatorio';
              } else if (!validateEmail(value)) {
                emailErrorMessage = 'Dominios válidos: (gmail.com, outlook.com, hotmail.com)';
              } else {
                emailErrorMessage = null;
              }
            });
          },
        ),
        SizedBox(height: 8),
        Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 10), // Agrega un padding de 10 píxeles a la derecha
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (emailErrorMessage != null)
                Expanded(
                  child: Text(
                    emailErrorMessage!,
                    style: TextStyle(
                      color: errorTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              // Contador de caracteres
              Text(
                '${controller.text.length}/60',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 17),
      ],
    );
  }

  bool validateEmail(String email) {
    // Verifica si el email tiene un formato válido
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(email)) {
      return false;
    }

    // Verifica si el dominio es uno de los permitidos
    final allowedDomains = ['gmail.com', 'hotmail.com', 'outlook.com'];

    if (email.contains('@')) {
      final domain = email.split('@').last;
      return allowedDomains.contains(domain);
    }

    return false;
  }

  void _onEmailFocusChange() {
    if (_emailFocusNode.hasFocus) {
      setState(() {
        if (_emailController.text.isEmpty) {
          emailErrorMessage = 'Campo email es obligatorio';
        } else if (!validateEmail(_emailController.text)) {
          emailErrorMessage = 'Válidos: (gmail.com, outlook.com, hotmail.com)';
        } else {
          emailErrorMessage = null;
        }
      });
    }
  }

  //birthday
  bool _validateBirthday() {
    final int day = int.tryParse(_dobDayController.text.padLeft(2, '0')) ?? 0;
    final int month =
        int.tryParse(_dobMonthController.text.padLeft(2, '0')) ?? 0;
    final int year =
        int.tryParse(_dobYearController.text.substring(0, 4).padLeft(4, '0')) ??
            0;

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
      return false;
    }
    if ((day > 30 && (month == 4 || month == 6 || month == 9 || month == 11)) ||
        day > 31) {
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


  //contraseña
  Widget _buildPasswordField(String labelText, TextEditingController passwordController) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final borderColor = isDarkMode ? Colors.white : Colors.black;
    final focusedBorderColor = Colors.cyan;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _passwordController,
          focusNode: _passwordFocusNode, // Asocia el FocusNode aquí
          keyboardType: TextInputType.text,
          obscureText: _obscurePassword,
          maxLength: 25,
          decoration: InputDecoration(
            labelText: labelText,
            filled: true,
            fillColor: Colors.transparent,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor, width: 2.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: focusedBorderColor, width: 2.0),
            ),
            labelStyle: TextStyle(color: textColor),
            counterText: '',
            prefixIcon: Icon(Icons.lock, color: textColor),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: textColor,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          style: TextStyle(color: textColor),
          onChanged: (value) {
            setState(() {
              hasMinLength = value.length >= 8;
              hasLetter = value.contains(RegExp(r'[A-Za-z]'));
              hasNumber = value.contains(RegExp(r'[0-9]'));
              hasSpecialChar = value.contains(RegExp(r'[!@#$%^&*£°(),¥€.?"¡~:+-/{}|<>]'));

              // Actualiza el mensaje de error
              if (value.isEmpty) {
                errorMessage = 'La contraseña no puede estar vacía.';
              } else {
                errorMessage = null; // Resetea el mensaje si no está vacío
              }
            });
          },
        ),
        SizedBox(height: 8), // Espacio entre el TextField y la fila de validación
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mensajes de validación o error en la misma fila
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Mostrar el mensaje de error si existe
                  if (errorMessage != null)
                    _buildValidationText(errorMessage!, false, '')
                  else if (_passwordFocusNode.hasFocus && !(hasMinLength && hasLetter && hasNumber && hasSpecialChar)) ...[
                    // Mostrar mensajes de validación solo si el campo está enfocado y no todos son válidos
                    if (_passwordController.text.length >= 8) ...[
                      _buildValidationText('Al menos 8 caracteres', hasMinLength, 'Al menos 8 caracteres'),
                      _buildValidationText('Falta una letra', hasLetter, 'Completado'),
                      _buildValidationText('Falta un número', hasNumber, 'Completado'),
                      _buildValidationText('Falta un símbolo', hasSpecialChar, 'Completado'),
                    ],
                  ],
                ],
              ),
            ),
            // Contador de caracteres
            Padding(
              padding: const EdgeInsets.only(top: 2, right: 10),
              child: Text(
                '${_passwordController.text.length}/25',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
        SizedBox(height: 17),
      ],
    );
  }

  Widget _buildValidationText(String text, bool isValid, String successMessage) {
    return Row(
      children: [
        Icon(
          isValid ? Icons.check_circle : Icons.cancel,
          color: isValid ? Colors.green : Colors.red,
          size: 16,
        ),
        SizedBox(width: 5),
        Text(
          isValid ? successMessage : text,
          style: TextStyle(
            color: isValid ? Colors.green : Colors.red,
            fontSize: 12,
            fontWeight: isValid ? FontWeight.normal : FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void resetValidators() {
    hasMinLength = false;
    hasLetter = false;
    hasNumber = false;
    hasSpecialChar = false;
    errorMessage = null; // Resetea el mensaje de error
    setState(() {});
  }
}
