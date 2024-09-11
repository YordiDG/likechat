import 'package:flutter/material.dart';

class GenderScreen extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String dob;
  String _selectedGender = 'Male';

  GenderScreen({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.dob,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecciona tu Género'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: _selectedGender,
              items: ['Male', 'Female', 'Other'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                _selectedGender = newValue!;
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Lógica para registrar al usuario con todos los datos
                print('Registro completo: $firstName, $lastName, $email, $password, $dob, $_selectedGender');
              },
              child: Text('Registrar'),
            ),
          ],
        ),
      ),
    );
  }
}

