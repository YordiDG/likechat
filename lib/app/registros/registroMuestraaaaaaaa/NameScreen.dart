import 'package:flutter/material.dart';
import '../login/LoginScreen.dart';
import 'EmailScreen.dart';


class NameScreen extends StatelessWidget {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
        return false;
      },
      child: Scaffold(
        backgroundColor: Color(0xFF0F101B),  // Fondo con el color #0F101B
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo centrado
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'lib/assets/logo.png', // Asegúrate de tener el logo en los assets
                      height: 200, // Ajusta el tamaño según el diseño deseado
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Register Account',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                // Input Primer Nombre
                TextField(
                  controller: _firstNameController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Primer Nombre',
                    labelStyle: TextStyle(color: Colors.cyan),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.cyan),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.pinkAccent, width: 2.0),
                    ),
                  ),
                  cursorColor: Colors.pinkAccent,
                ),
                SizedBox(height: 15),
                // Input Apellido
                TextField(
                  controller: _lastNameController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Apellido',
                    labelStyle: TextStyle(color: Colors.cyan),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.cyan),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.pinkAccent, width: 2.0),
                    ),
                  ),
                  cursorColor: Colors.pinkAccent,
                ),
                SizedBox(height: 30),
                // Botón "Siguiente" en la parte inferior derecha
                Align(
                  alignment: Alignment.bottomRight,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_firstNameController.text.isNotEmpty &&
                          _lastNameController.text.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EmailScreen(
                              firstName: _firstNameController.text,
                              lastName: _lastNameController.text,
                            ),
                          ),
                        );
                      } else {
                        // Mostrar un error si faltan datos
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Por favor ingresa ambos nombres',
                              style: TextStyle(color: Colors.white),
                            ),
                            backgroundColor: Colors.redAccent,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.cyan,
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Siguiente',
                      style: TextStyle(
                        fontSize: 18,
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
    );
  }
}
