import 'dart:async';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../../Globales/estadoDark-White/DarkModeProvider.dart';
import '../Politicas de la Empresa/Condiciones/CondicionesScreen.dart';
import '../Politicas de la Empresa/Politicas/PoliticasPrivacidadScreen.dart';
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

  bool _obscurePassword = true;
  bool _acceptTerms = false;

  final _codeControllers = List.generate(6, (index) => TextEditingController());

  bool _isRegistered = false;

  //email
  final FocusNode _emailFocusNode = FocusNode();
  String? emailErrorMessage;

  //gender
  String _selectedGender = 'Male';
  final List<String> genders = ['Male', 'Female', 'Other'];

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
                      SizedBox(height: 5),
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
                SizedBox(height: 15),
                _buildTextField('First Name', _firstNameController),
                SizedBox(height: 15),
                _buildTextField('Last Name', _lastNameController),
                SizedBox(height: 15),
                _buildEmailField('Email', _emailController),
                _buildPasswordField('Password', _passwordController),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextFieldBirthday(
                        'Día',
                        _dobDayController,
                        keyboardType: TextInputType.number,
                        maxLength: 2,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _buildTextFieldBirthday(
                        'Mes',
                        _dobMonthController,
                        keyboardType: TextInputType.number,
                        maxLength: 2,
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: _buildTextFieldBirthday(
                        'Año',
                        _dobYearController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        onFieldSubmitted: () {
                          // Aquí puedes validar la fecha al enviar el campo de año
                          if (_validateBirthday()) {
                            // Lógica cuando la fecha es válida
                          }
                        },
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: buildGenderDropdown(),
                ),
                SizedBox(height: 10),
                _buildTermsAndPrivacyCheckbox(),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: handleRegister,
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
                      style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
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
        _passwordController.text.contains(RegExp(r'[A-Za-z]')) &&
        _passwordController.text.contains(RegExp(r'[0-9]')) &&
        _passwordController.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')))) {
      return 'La contraseña debe tener al menos 8 caracteres, una letra, un número y un símbolo.';
    }

    // Validación de fecha de nacimiento
    String? birthdayError = _validateBirthdayDetailed();
    if (birthdayError != null) {
      return birthdayError;
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
    final borderColor = isDarkMode
        ? Colors.white.withOpacity(0.5)
        : Colors.black.withOpacity(0.5);
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
      cursorColor: Colors.cyan,
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
        errorText: showError
            ? errorText
            : null, // Mostrar el mensaje de error si corresponde
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
    final errorTextColor = Colors.red.shade800;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Theme(
          data: Theme.of(context).copyWith(
            textSelectionTheme: TextSelectionThemeData(
              selectionColor: Colors.cyan.shade200, // Color de la selección de texto
              cursorColor: Colors.cyan, // Color del cursor
            ),
          ),
          child: TextField(
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
                  emailErrorMessage =
                  'Dominios válidos: (gmail.com, outlook.com, hotmail.com)';
                } else {
                  emailErrorMessage = null;
                }
              });
            },
          ),
        ),
        SizedBox(height: 8),
        Container(
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 10),
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
                    ),
                  ),
                ),
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
  String? _validateBirthdayDetailed() {
    final int day = int.tryParse(_dobDayController.text.padLeft(2, '0')) ?? 0;
    final int month =
        int.tryParse(_dobMonthController.text.padLeft(2, '0')) ?? 0;
    final int year = int.tryParse(_dobYearController.text.padLeft(4, '0')) ?? 0;

    final DateTime now = DateTime.now();

    // Validar que el día sea válido (1-31)
    if (day < 1 || day > 31) {
      return 'El día debe estar entre 1 y 31.';
    }

    // Validar que el mes sea válido (1-12)
    if (month < 1 || month > 12) {
      return 'El mes debe estar entre 1 y 12.';
    }

    // Validar el número de días según el mes
    if (day > 28 && month == 2) {
      return 'El día no puede ser mayor a 28 en febrero.';
    }
    if ((day > 30 && (month == 4 || month == 6 || month == 9 || month == 11))) {
      return 'El día no puede ser mayor a 30 en este mes.';
    }

    // Calcular el año mínimo y máximo permitido
    final int minYear = now.year - 18; // Año mínimo para tener al menos 18 años
    final int maxYear =
        now.year - 130; // Año máximo permitido para no ser mayor de 130 años

    // Validar el año
    if (year < maxYear) {
      return 'El año no puede ser mayor a ${maxYear} años atrás.';
    }
    if (year > minYear) {
      return 'Debes tener al menos 18 años.';
    }

    // Validar la fecha completa
    final DateTime birthday = DateTime(year, month, day);
    if (birthday.isAfter(now)) {
      return 'La fecha de nacimiento no puede ser futura.';
    }

    return null; // Si no hay errores
  }

  bool _validateBirthday() {
    final int day = int.tryParse(_dobDayController.text.padLeft(2, '0')) ?? 0;
    final int month =
        int.tryParse(_dobMonthController.text.padLeft(2, '0')) ?? 0;
    final int year = int.tryParse(_dobYearController.text.padLeft(4, '0')) ?? 0;

    final DateTime now = DateTime.now();

    // Validar que el día sea válido (1-31)
    if (day < 1 || day > 31) return false;

    // Validar que el mes sea válido (1-12)
    if (month < 1 || month > 12) return false;

    // Validar el número de días según el mes
    if (day > 28 && month == 2) return false;
    if ((day > 30 && (month == 4 || month == 6 || month == 9 || month == 11)) ||
        day > 31) return false;

    final DateTime birthday = DateTime(year, month, day);
    int age = now.year - birthday.year;

    if (now.month < birthday.month ||
        (now.month == birthday.month && now.day < birthday.day)) {
      age--;
    }

    return age >= 18 && year <= now.year;
  }

  Widget _buildTextFieldBirthday(
    String labelText,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    Function()? onFieldSubmitted,
  }) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final borderColor = isDarkMode ? Colors.white70 : Colors.grey[400]!;
    final focusedBorderColor = Colors.blue[400]!;

    bool showError = false;
    String? errorText;

    if ((labelText == 'Día' && controller.text.isEmpty) ||
        (labelText == 'Mes' && controller.text.isEmpty) ||
        (labelText == 'Año' && controller.text.isEmpty)) {
      showError = true;
      errorText = 'Requerido $labelText.';
    }

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      cursorColor: Colors.cyan,
      onChanged: (value) {
        if (value.length == maxLength) {
          if (labelText == 'Día') {
            FocusScope.of(context).nextFocus();
          } else if (labelText == 'Mes') {
            FocusScope.of(context).nextFocus();
          } else if (labelText == 'Año') {
            FocusScope.of(context).unfocus();
          }
        }
      },
      onSubmitted: (value) => onFieldSubmitted?.call(),
      decoration: InputDecoration(
        labelText: labelText,
        counterText: '',
        filled: true,
        fillColor: Colors.transparent,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: showError ? Colors.red.withOpacity(0.5) : borderColor,
            width: 2.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: focusedBorderColor, width: 2.0),
        ),
        labelStyle: TextStyle(
          color: textColor,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        errorText: showError ? errorText : null,
        errorStyle: TextStyle(
          color: Colors.red.shade800,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      style: TextStyle(
        color: textColor,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  //contraseña
  Widget _buildPasswordField(
      String labelText, TextEditingController passwordController) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final borderColor = isDarkMode ? Colors.white : Colors.black;
    final focusedBorderColor = Colors.cyan;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _passwordController,
          focusNode: _passwordFocusNode,
          // Asocia el FocusNode aquí
          keyboardType: TextInputType.text,
          obscureText: _obscurePassword,
          cursorColor: Colors.cyan,
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
              hasSpecialChar =
                  value.contains(RegExp(r'[!@#$%^&*£°(),¥€.?"¡~:+-/{}|<>]'));

              // Actualiza el mensaje de error
              if (value.isEmpty) {
                errorMessage = 'La contraseña no puede estar vacía.';
              } else {
                errorMessage = null; // Resetea el mensaje si no está vacío
              }
            });
          },
        ),
        SizedBox(height: 8),
        // Espacio entre el TextField y la fila de validación
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
                  else if (_passwordFocusNode.hasFocus &&
                      !(hasMinLength &&
                          hasLetter &&
                          hasNumber &&
                          hasSpecialChar)) ...[
                    // Mostrar mensajes de validación solo si el campo está enfocado y no todos son válidos
                    if (_passwordController.text.length >= 8) ...[
                      _buildValidationText('Al menos 8 caracteres',
                          hasMinLength, 'Al menos 8 caracteres'),
                      _buildValidationText(
                          'Falta una letra', hasLetter, 'Completado'),
                      _buildValidationText(
                          'Falta un número', hasNumber, 'Completado'),
                      _buildValidationText(
                          'Falta un símbolo', hasSpecialChar, 'Completado'),
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

  Widget _buildValidationText(
      String text, bool isValid, String successMessage) {
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

  //genero
  Widget buildGenderDropdown() {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final backgroundColor = darkModeProvider.backgroundColor;

    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        hint: Row(
          children: [
            Icon(
              Icons.person,
              size: 18,
              color: iconColor, // Cambiar el color del ícono según el tema
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Select Gender',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black, // Cambiar color de texto según el tema
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        items: genders
            .map((String gender) => DropdownMenuItem<String>(
          value: gender,
          child: Text(
            gender,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.white : Colors.black, // Cambiar color de texto según el tema
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ))
            .toList(),
        value: _selectedGender,
        onChanged: (String? newValue) {
          setState(() {
            _selectedGender = newValue!;
          });
        },
        buttonStyleData: ButtonStyleData(
          height: 50,
          width: 200,
          padding: const EdgeInsets.only(left: 14, right: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: isDarkMode ? Colors.white : Colors.grey.shade300), // Cambiar color del borde según el tema
            color: isDarkMode ? Colors.grey.shade800 : Colors.white, // Cambiar el color del fondo del botón según el tema
          ),
          elevation: 2,
        ),
        iconStyleData: IconStyleData(
          icon: Icon(
            Icons.arrow_drop_down,
            color: iconColor, // Cambiar el color del ícono según el tema
          ),
          iconSize: 24,
        ),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 200,
          width: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: isDarkMode ? Colors.grey.shade800 : Colors.white, // Cambiar color de fondo del dropdown según el tema
            border: Border.all(color: isDarkMode ? Colors.white : Colors.grey.shade300), // Cambiar color del borde del dropdown
          ),
          offset: const Offset(0, -8),
          scrollbarTheme: ScrollbarThemeData(
            radius: const Radius.circular(40),
            thickness: MaterialStateProperty.all<double>(6),
            thumbVisibility: MaterialStateProperty.all<bool>(true),
          ),
        ),
        menuItemStyleData: const MenuItemStyleData(
          height: 40,
          padding: EdgeInsets.symmetric(horizontal: 14),
        ),
      ),
    );
  }

  //terminos y condiciones
  Widget _buildTermsAndPrivacyCheckbox() {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final iconColor = darkModeProvider.iconColor;
    final backgroundColor = darkModeProvider.backgroundColor;

    return Row(
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
                      // Navegar a la pantalla de Condiciones
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CondicionesScreen(),
                        ),
                      );
                    },
                ),
                TextSpan(
                  text: ' y ',
                  style: TextStyle(color: textColor, fontSize: 15),
                ),
                TextSpan(
                  text: 'Política de Privacidad',
                  style: TextStyle(
                    color: Colors.cyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      // Navegar a la pantalla de Políticas de Privacidad
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PoliticasPrivacidadScreen(),
                        ),
                      );
                    },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }


  //botom de registrarse:
// Método para manejar el registro
  Future<void> handleRegister() async {
    String? errorMessage = _validateFields();
    if (errorMessage != null) {
      _showErrorDialog(errorMessage);
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
      await Provider.of<AuthProvider>(context, listen: false).sendVerificationCode(_emailController.text);

      // Mostrar FlutterToast de éxito
      Fluttertoast.showToast(
        msg: "Registro exitoso, revisa tu correo para verificar tu cuenta",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
        fontSize: 16.0,
      );

      // Navegar a la pantalla de verificación de código
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CodeVerificationScreen(email: _emailController.text),
        ),
      );
    } catch (e) {
      print('Error durante el registro: $e');
      if (e.toString().contains('202')) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CodeVerificationScreen(email: _emailController.text),
          ),
        );
      } else {
        _showGenericErrorDialog();
      }
    }
  }

// Método para mostrar el diálogo de error
  void _showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Theme(
          data: ThemeData(
            dialogBackgroundColor: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[850]
                : Colors.white,
            textTheme: TextTheme(
              bodyLarge: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17),
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
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// Método para mostrar un diálogo de error genérico
  void _showGenericErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          content: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Registro fallido',
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Parece que el correo ya está registrado o hubo un problema en el registro. Por favor, inténtelo de nuevo.',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 15,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  TextButton(
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.redAccent,
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
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
