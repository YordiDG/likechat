import 'package:flutter/material.dart';

import 'DOBScreen.dart';

class EmailScreen extends StatelessWidget {
  final String firstName;
  final String lastName;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  EmailScreen({required this.firstName, required this.lastName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Email y Contraseña'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DOBScreen(
                      firstName: firstName,
                      lastName: lastName,
                      email: _emailController.text,
                      password: _passwordController.text,
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
