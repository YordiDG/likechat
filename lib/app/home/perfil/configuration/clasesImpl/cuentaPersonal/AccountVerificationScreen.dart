import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import '../../../../../Globales/estadoDark-White/DarkModeProvider.dart';

class AccountVerificationScreen extends StatefulWidget {
  const AccountVerificationScreen({Key? key}) : super(key: key);

  @override
  _AccountVerificationScreenState createState() =>
      _AccountVerificationScreenState();
}

class _AccountVerificationScreenState extends State<AccountVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  PlatformFile? _document;
  String? _selectedDocumentType;

  // Controladores de texto
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _documentNumberController = TextEditingController();

  List<File> _documentImages = []; // Lista para almacenar las imágenes seleccionadas.

  final Map<String, String> _documentPrefixes = {
    'Cédula': 'CE-',
    'Pasaporte': 'PA-',
    'DNI': 'DNI-',
  };

  final Map<String, RegExp> _documentValidators = {
    'Cédula': RegExp(r'^\d{10}$'),
    'Pasaporte': RegExp(r'^[A-Z0-9]{9}$'),
    'DNI': RegExp(r'^\d{8}$'),
  };

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _documentNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final backgroundColor = darkModeProvider.backgroundColor;
    final textColor = darkModeProvider.textColor;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildPersonalInfoSection(context),
                      SizedBox(height: 20),
                      _buildDocumentVerificationSection(context),
                      SizedBox(height: 20),
                      _buildVerificationMethodsSection(context),
                      SizedBox(height: 30),
                      _buildSubmitButton(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, // Alinear a la izquierda.
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 25,
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Acción para retroceder.
                },
              ),
              Expanded(
                child: Text(
                  'Verificación de Cuenta',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1, // Limitar a una línea.
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Text(
            'Completa tu perfil para desbloquear todas las funciones',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, 4),
          )
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Información Personal',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
          SizedBox(height: 15),
          _buildCustomTextField(
            controller: _fullNameController,
            label: 'Nombre Completo',
            icon: Icons.person,
            validator: (value) => value!.isEmpty ? 'Nombre es requerido' : null,
          ),
          SizedBox(height: 15),
          _buildCustomTextField(
            controller: _usernameController,
            label: 'Nombre de Usuario',
            icon: Icons.alternate_email,
            validator: (value) =>
                value!.isEmpty ? 'Usuario es requerido' : null,
          ),
          SizedBox(height: 15),
          _buildCustomTextField(
            controller: _emailController,
            label: 'Correo Electrónico',
            icon: Icons.email,
            validator: (value) {
              if (value!.isEmpty) return 'Correo es requerido';
              final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              return !emailRegExp.hasMatch(value)
                  ? 'Correo electrónico no válido'
                  : null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentVerificationSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, 4),
          )
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Verificación de Identidad',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
          SizedBox(height: 15),
          _buildDocumentTypeDropdown(),
          SizedBox(height: 15),
          _buildCustomTextField(
            controller: _documentNumberController,
            label: 'Número de Documento',
            icon: Icons.credit_card,
            validator: (value) {
              if (value!.isEmpty) return 'Número de documento es requerido';
              if (_selectedDocumentType != null &&
                  !_documentValidators[_selectedDocumentType!]!
                      .hasMatch(value)) {
                return 'Número de documento no válido';
              }
              return null;
            },
          ),
          SizedBox(height: 15),
          _buildDocumentUploadButton(),
        ],
      ),
    );
  }

  Widget _buildVerificationMethodsSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, 4),
          )
        ],
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Métodos de Verificación',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade700,
            ),
          ),
          SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildVerificationMethodButton(
                  icon: Icons.qr_code_scanner,
                  label: 'Escanear QR',
                  onPressed: _scanQRCode,
                  color: Colors.green,
                ),
              ),
              SizedBox(width: 15),
              Expanded(
                child: _buildVerificationMethodButton(
                  icon: Icons.face,
                  label: 'Facial',
                  onPressed: _takeSelfie,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationMethodButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(17),
        ),
        elevation: 5,
      ),
    );
  }

  Widget _buildDocumentTypeDropdown() {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Tipo de Documento',
        prefixIcon: Icon(Icons.document_scanner, color: Colors.blue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      value: _selectedDocumentType,
      items: _documentPrefixes.keys.map((type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text('$type (${_documentPrefixes[type]})'),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedDocumentType = value;
          _documentNumberController.clear();
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Por favor, seleccione un tipo de documento';
        }
        return null;
      },
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      validator: validator,
    );
  }


// Método para seleccionar documentos
  Future<void> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      allowMultiple: true, // Permitir seleccionar múltiples archivos.
      type: FileType.image, // Solo imágenes.
    );

    if (result != null) {
      final selectedFiles =
      result.paths.map((path) => File(path!)).toList(); // Convertir rutas a `File`.

      if (_documentImages.length + selectedFiles.length > 3) {
        Fluttertoast.showToast(
          msg: "Se permiten un máximo de 4 imágenes.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      } else {
        setState(() {
          _documentImages.addAll(selectedFiles);
        });
        Fluttertoast.showToast(
          msg: "${selectedFiles.length} imágenes añadidas.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
        );
      }
    }
  }

  // Construir botón de carga y vista previa de los documentos
  Widget _buildDocumentUploadButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: _pickDocument,
          icon: Icon(Icons.upload_file, color: Colors.white),
          label: Text(
            'Subir Documento',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 30),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(17),
            ),
            elevation: 5,
          ),
        ),
        if (_documentImages.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _documentImages.map((image) {
                  return Stack(
                    children: [
                      Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.file(
                            image,
                            fit: BoxFit.cover,
                            width: 150,
                            height: 150,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _documentImages.remove(image);
                            });
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white, // Fondo blanco.
                              shape: BoxShape.circle,
                            ),
                            padding: EdgeInsets.all(4),
                            child: Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return ElevatedButton(
      onPressed: _isSubmitting ? null : _submitForm,
      child: _isSubmitting
          ? CircularProgressIndicator(color: Colors.cyan)
          : Text('Verificar Cuenta', style: TextStyle(fontSize: 14,color: Colors.white, fontWeight: FontWeight.w600)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 100),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(17),
        ),
        elevation: 5,
      ),
    );
  }

  Future<void> _scanQRCode() async {
    // Implementar el escaneo del código QR
    print("Escanear código QR");
  }

  Future<void> _takeSelfie() async {
    // Implementar la toma de un selfie
    print("Tomar Selfie");
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });
      // Simular una operación de envío
      await Future.delayed(Duration(seconds: 2));
      setState(() {
        _isSubmitting = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Cuenta Verificada')));
    }
  }
}
