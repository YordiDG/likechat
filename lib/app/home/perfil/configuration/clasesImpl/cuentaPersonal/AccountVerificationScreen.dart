import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart'; // Paquete para escaneo QR
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

import '../../../../../Globales/estadoDark-White/DarkModeProvider.dart'; // Paquete para Facebook


class AccountVerificationScreen extends StatefulWidget {
  @override
  _AccountVerificationScreenState createState() => _AccountVerificationScreenState();
}

class _AccountVerificationScreenState extends State<AccountVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  PlatformFile? _document;
  String? _selectedDocumentType;
  String _documentNumber = '';
  QRViewController? _qrController;

  final Map<String, String> _documentPrefixes = {
    'Cédula': 'CE-',
    'Visa': 'VI-',
    'DNI': 'DNI-',
  };

  final Map<String, RegExp> _documentValidators = {
    'Cédula': RegExp(r'^\d{10}$'), // Ejemplo para cédula (10 dígitos)
    'Visa': RegExp(r'^[A-Z0-9]{10}$'), // Ejemplo para visa
    'DNI': RegExp(r'^\d{8}$'), // Ejemplo para DNI (8 dígitos)
  };

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final backgroundColor = darkModeProvider.backgroundColor;
    final textColor = darkModeProvider.textColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Verificación de Cuenta',
          style: TextStyle(color: textColor),
        ),
        backgroundColor: backgroundColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Solicita la verificación de tu cuenta',
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  fontSize: 18,
                ),
              ),
              SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      icon: FontAwesomeIcons.user,
                      label: 'Nombre Completo',
                      validator: (value) => value!.isEmpty ? 'Este campo es obligatorio' : null,
                    ),
                    _buildTextField(
                      icon: FontAwesomeIcons.userAlt,
                      label: 'Nombre de Usuario',
                      validator: (value) => value!.isEmpty ? 'Este campo es obligatorio' : null,
                    ),
                    _buildTextField(
                      icon: FontAwesomeIcons.envelope,
                      label: 'Correo Electrónico',
                      validator: (value) => value!.isEmpty ? 'Este campo es obligatorio' : null,
                    ),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Tipo de Documento',
                        prefixIcon: Icon(FontAwesomeIcons.idCard, color: Colors.blue),
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 12.0),
                      ),
                      value: _selectedDocumentType,
                      hint: Text('Selecciona un tipo de documento'),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedDocumentType = newValue;
                          _documentNumber = _getDocumentPrefix(newValue) + _documentNumber.replaceAll(RegExp(r'^\w+-'), ''); // Ajusta el número de documento para que mantenga solo el número después del prefijo
                        });
                      },
                      items: [
                        'Cédula',
                        'Visa',
                        'DNI',
                        // Agrega más tipos si es necesario
                      ].map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      validator: (value) => value == null ? 'Selecciona un tipo de documento' : null,
                    ),
                    SizedBox(height: 20),
                    _buildTextField(
                      icon: FontAwesomeIcons.idCard,
                      label: 'Número de Documento',
                      initialValue: _documentNumber,
                      validator: (value) {
                        if (value!.isEmpty) return 'Este campo es obligatorio';
                        if (_selectedDocumentType != null && !_documentValidators[_selectedDocumentType!]!.hasMatch(value)) {
                          return 'Número de documento no válido para el tipo seleccionado';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        setState(() {
                          _documentNumber = _getDocumentPrefix(_selectedDocumentType) + value.replaceAll(RegExp(r'^\w+-'), ''); // Mantiene el prefijo y actualiza el resto del número
                        });
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _pickDocument,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.attach_file, color: Colors.white),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _document != null ? 'Documento Seleccionado: ${_document!.name}' : 'Adjuntar Documento',
                              style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 12.0),
                        textStyle: TextStyle(fontSize: 16, color: textColor),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _scanQRCode,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.qr_code_scanner, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Escanear Código QR',
                            style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 22.0),
                        textStyle: TextStyle(fontSize: 16, color: textColor),
                      ),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _loginWithFacebook,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(FontAwesomeIcons.facebook, color: Colors.white),
                          SizedBox(width: 10),
                          Text(
                            'Verificar con Facebook',
                            style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 22.0),
                        textStyle: TextStyle(fontSize: 16, color: textColor),
                      ),
                    ),
                    SizedBox(height: 20),
                    _isSubmitting
                        ? Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                      onPressed: _isSubmitting ? null : _submitVerificationRequest,
                      child: Text(
                        'Enviar Solicitud',
                        style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 22.0),
                        textStyle: TextStyle(fontSize: 16, color: textColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required IconData icon,
    required String label,
    required String? Function(String?) validator,
    String? initialValue,
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue),
          labelText: label,
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey), // Color del borde por defecto
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.cyan, width: 2.0), // Color del borde al enfocar
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 12.0),
        ),
        validator: validator,
        onChanged: onChanged,
      ),
    );
  }



  String _getDocumentPrefix(String? documentType) {
    return _documentPrefixes[documentType] ?? '';
  }

  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        _document = result.files.first;
      });
    }
  }

  Future<void> _scanQRCode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => QRViewExample(onResult: (String result) {
        setState(() {
          _documentNumber = result;
        });
      })),
    );
  }

  Future<void> _loginWithFacebook() async {
    try {
      final result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        // Aquí puedes validar la información del usuario o hacer algo más
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verificación con Facebook exitosa.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al verificar con Facebook.')),
      );
    }
  }

  void _submitVerificationRequest() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      // Simular un retraso de red
      await Future.delayed(Duration(seconds: 2));

      // Mostrar mensaje de confirmación
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Solicitud de verificación enviada.')),
      );

      // Volver al menú
      Navigator.pop(context);
      setState(() {
        _isSubmitting = false;
      });
    }
  }
}

class QRViewExample extends StatefulWidget {
  final Function(String) onResult;

  QRViewExample({required this.onResult});

  @override
  _QRViewExampleState createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  QRViewController? _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Escanear Código QR'),
      ),
      body: QRView(
        key: GlobalKey(debugLabel: 'QR'),
        onQRViewCreated: (controller) {
          setState(() {
            _controller = controller;
          });
          _controller!.scannedDataStream.listen((scanData) {
            if (scanData.code != null) {
              widget.onResult(scanData.code!);
              Navigator.pop(context);
            }
          });
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }
}

