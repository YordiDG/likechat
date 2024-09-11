import 'package:flutter/material.dart';

import 'GenderScreen.dart';

class DOBScreen extends StatelessWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  final TextEditingController _dobDayController = TextEditingController();
  final TextEditingController _dobMonthController = TextEditingController();
  final TextEditingController _dobYearController = TextEditingController();

  DOBScreen({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fecha de Nacimiento'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _dobDayController,
                    decoration: InputDecoration(labelText: 'Día'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _dobMonthController,
                    decoration: InputDecoration(labelText: 'Mes'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _dobYearController,
                    decoration: InputDecoration(labelText: 'Año'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GenderScreen(
                      firstName: firstName,
                      lastName: lastName,
                      email: email,
                      password: password,
                      dob: '${_dobYearController.text}-${_dobMonthController.text}-${_dobDayController.text}',
                    ),
                  ),
                );
              },
              child: Text('Siguiente'),
            ),
          ],
        ),
      ),
    );
  }
}
