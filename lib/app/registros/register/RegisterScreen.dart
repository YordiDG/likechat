import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    SizedBox(height: 60),
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
              _buildEmailField(
                  'Email', _emailController),
              SizedBox(height: 19),
              _buildPasswordField('Password', _passwordController),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                        'Day', _dobDayController, TextInputType.number),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                        'Month', _dobMonthController, TextInputType.number),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _buildTextField(
                        'Year', _dobYearController, TextInputType.number),
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
                    child: Row(
                      children: [
                        Text(
                          'Aceptar las ',
                          style: TextStyle(color: Colors.white),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Agrega aquí la lógica para el enlace
                          },
                          child: Text(
                            'Condiciones',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          ' y ',
                          style: TextStyle(color: Colors.white),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Agrega aquí la lógica para el enlace
                          },
                          child: Text(
                            'Política de Privacidad',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                ],
              ),
              SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _acceptTerms
                      ? () async {
                    try {
                      if (_validateBirthday()) {
                        await Provider.of<AuthProvider>(context,
                            listen: false)
                            .register(
                          _usernameController.text,
                          _emailController.text,
                          _passwordController.text,
                          _firstNameController.text,
                          _lastNameController.text,
                          "${_dobYearController.text}-${_dobMonthController.text.padLeft(2, '0')}-${_dobDayController.text.padLeft(2, '0')}",
                          _acceptTerms,
                        );
                        Navigator.pushReplacementNamed(context, '/home');
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'Invalid birthday. You must be at least 18 years old.')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Registration failed')),
                      );
                    }
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFD9F103),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Register',
                    style: TextStyle(
                      color: Color(0xFF0D0D55),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
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

  Widget _buildTextField(String labelText, TextEditingController controller,
      [TextInputType keyboardType = TextInputType.text]) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
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
    );
  }



  Widget _buildEmailField(String labelText, TextEditingController controller) {
    bool showError = false;

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
              borderSide: BorderSide(color: Colors.white, width: 2.0), // Ancho del borde ajustado a 2.0
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Color(0xFFD9F103), width: 2.0), // Ancho del borde ajustado a 2.0
            ),
            labelStyle: TextStyle(color: Colors.white),
          ),
          style: TextStyle(color: Colors.white),
          onChanged: (value) {
            setState(() {
              showError = !validateEmail(value);
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
    final int day = int.tryParse(_dobDayController.text) ?? 0;
    final int month = int.tryParse(_dobMonthController.text) ?? 0;
    final int year = int.tryParse(_dobYearController.text) ?? 0;

    final DateTime now = DateTime.now();
    final DateTime birthday = DateTime(year, month, day);

    int age = now.year - birthday.year;

    if (now.month < birthday.month ||
        (now.month == birthday.month && now.day < birthday.day)) {
      age--;
    }

    return age >= 18 && year <= now.year;
  }

  Widget _buildPasswordField(String labelText, TextEditingController controller) {
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
