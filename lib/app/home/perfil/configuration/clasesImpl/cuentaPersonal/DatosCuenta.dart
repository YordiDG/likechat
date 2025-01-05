import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../../../../Globales/estadoDark-White/DarkModeProvider.dart';
import '../../../../../Globales/estadoDark-White/Fuentes/FontSizeProvider.dart';

class DatosCuenta extends StatefulWidget {
  final String email;
  final String phoneNumber;
  final String region;

  DatosCuenta({
    required this.email,
    required this.phoneNumber,
    required this.region,
  });

  @override
  _DatosCuentaState createState() => _DatosCuentaState();
}

class _DatosCuentaState extends State<DatosCuenta> {
  late String _email;
  late String _phoneNumber;
  late String _region;

  @override
  void initState() {
    super.initState();
    // Inicializar los valores con los datos recibidos
    _email = widget.email;
    _phoneNumber = widget.phoneNumber;
    _region = widget.region;

    // Log para debugging
    print('Email recibido: $_email');
    print('Teléfono recibido: $_phoneNumber');
    print('Región recibida: $_region');
  }

  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final username = parts[0];
    if (username.length <= 3) return email;
    return '${username.substring(0, 3)}******@${parts[1]}';
  }

  String _maskPhoneNumber(String phone) {
    if (phone.isEmpty) return '';
    // Asegurarse de que el número tenga el formato correcto
    String cleanPhone = phone.replaceAll(RegExp(r'\s+'), '');
    if (cleanPhone.length <= 6) return cleanPhone;
    return '${cleanPhone.substring(0, 3)}******${cleanPhone.substring(cleanPhone.length - 3)}';
  }

  String _extractPrefix(String phoneNumber) {
    if (phoneNumber.isEmpty) return '+51';
    final match = RegExp(r'^\+\d+').firstMatch(phoneNumber);
    return match?.group(0) ?? '+51';
  }

  Widget _buildInfoRow(
      IconData icon,
      String title,
      String info,
      String type,
      Function(String) onUpdate,
      BuildContext context,
      ) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final textColor = darkModeProvider.textColor;
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    String displayInfo;
    switch (type) {
      case 'email':
        displayInfo = _maskEmail(info);
        break;
      case 'phone':
        displayInfo = _maskPhoneNumber(info);
        break;
      default:
        displayInfo = info;
    }

    return InkWell(
      onTap: () {
        // Asegurarse de que se pase el valor correcto al DetailScreen
        String valueToPass = info;
        if (type == 'phone' && !info.startsWith('+')) {
          valueToPass = _phoneNumber; // Usar el número completo con prefijo
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(
              title: title,
              value: valueToPass,
              type: type,
              icon: icon,
              onUpdate: onUpdate,
              currentPrefix: type == 'phone' ? _extractPrefix(_phoneNumber) : null,
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Icon(icon, color: darkModeProvider.iconColor, size: 22),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: fontSizeProvider.fontSize + 1,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Text(
                    displayInfo,
                    style: TextStyle(
                      fontSize: fontSizeProvider.fontSize,
                      color: textColor.withOpacity(0.8),
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: fontSizeProvider.fontSize,
              color: textColor.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final backgroundColor = darkModeProvider.backgroundColor;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Datos de la Cuenta',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        centerTitle: true,
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: backgroundColor,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: isDarkMode ? Colors.grey[850] : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  Icons.email,
                  'Correo Electrónico',
                  _email,
                  'email',
                      (newValue) => setState(() => _email = newValue),
                  context,
                ),
                Divider(
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                  thickness: 1,
                ),
                _buildInfoRow(
                  Icons.phone,
                  'Teléfono',
                  _phoneNumber,
                  'phone',
                      (newValue) => setState(() => _phoneNumber = newValue),
                  context,
                ),
                Divider(
                  color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                  thickness: 1,
                ),
                _buildInfoRow(
                  Icons.location_on,
                  'Región',
                  _region,
                  'region',
                      (newValue) => setState(() => _region = newValue),
                  context,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DetailScreen extends StatefulWidget {
  final String title;
  final String value;
  final String type;
  final IconData icon;
  final Function(String) onUpdate;
  final String? currentPrefix;

  const DetailScreen({
    required this.title,
    required this.value,
    required this.type,
    required this.icon,
    required this.onUpdate,
    this.currentPrefix,
  });

  @override
  _DetailScreenState createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late TextEditingController _controller;
  String? _errorText;
  bool _isValidInput = false;
  late String _selectedPrefix;

  final List<String> _commonPrefixes = [
    '+51',  // Perú
    '+1',   // Estados Unidos, Canadá, y países del Caribe
    '+44',  // Reino Unido
    '+34',  // España
    '+57',  // Colombia
    '+55',  // Brasil
    '+56',  // Chile
    '+53',  // Cuba
    '+52',  // México
    '+61',  // Australia
    '+62',  // Indonesia
    '+63',  // Filipinas
    '+64',  // Nueva Zelanda
    '+65',  // Singapur
    '+66',  // Tailandia
    '+81',  // Japón
    '+82',  // Corea del Sur
    '+91'   // India
  ];


  @override
  void initState() {
    super.initState();

    // Inicialización mejorada del prefijo
    _selectedPrefix = widget.currentPrefix ?? '+51';
    if (!_commonPrefixes.contains(_selectedPrefix)) {
      _selectedPrefix = '+51';
    }

    // Inicialización mejorada del controlador
    if (widget.type == 'phone') {
      // Extrae solo los números del teléfono, ignorando el prefijo
      final phoneWithoutPrefix = widget.value.replaceFirst(RegExp(r'^\+\d+\s*'), '');
      _controller = TextEditingController(text: phoneWithoutPrefix.trim());
    } else {
      _controller = TextEditingController(text: widget.value);
    }

    // Validación inicial
    _validateInput(_controller.text);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _validateInput(String value) {
    setState(() {
      _errorText = null;
      _isValidInput = false;
    });

    if (value.isEmpty) {
      setState(() {
        _errorText = 'Este campo no puede estar vacío';
      });
      return false;
    }

    switch (widget.type) {
      case 'email':
      // Validación completa de email
        final emailRegex = RegExp(
            r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$'
        );
        if (!emailRegex.hasMatch(value)) {
          setState(() {
            _errorText = 'Ingresa un correo electrónico válido';
          });
          return false;
        }
        break;

      case 'phone':
      // Validación de teléfono (10 dígitos sin el prefijo)
        final phoneRegex = RegExp(r'^[0-9]{10}$');
        if (!phoneRegex.hasMatch(value)) {
          setState(() {
            _errorText = 'Ingresa un número de 10 dígitos';
          });
          return false;
        }
        break;

      case 'region':
      // Validación de región (solo letras, espacios y algunos caracteres especiales)
        final regionRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s\-\.,]{2,50}$');
        if (!regionRegex.hasMatch(value)) {
          setState(() {
            _errorText = 'Ingresa una región válida (2-50 caracteres)';
          });
          return false;
        }
        break;
    }

    setState(() {
      _isValidInput = true;
    });
    return true;
  }

  void _saveChanges() {
    if (_validateInput(_controller.text)) {
      try {
        final valueToSave = widget.type == 'phone'
            ? '$_selectedPrefix ${_controller.text}'
            : _controller.text;

        widget.onUpdate(valueToSave);

        Fluttertoast.showToast(
          msg: "Cambios guardados exitosamente",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey.shade800,
          textColor: Colors.white,
          fontSize: 11.0,
        );

        Navigator.pop(context);
      } catch (error) {
        Fluttertoast.showToast(
          msg: "Error al guardar los cambios",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 11.0,
        );
      }
    }
  }

  Widget _buildPhoneInput(TextStyle inputStyle) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Colors.grey.shade400,
                width: 1,
              ),
            ),
          ),
          child: DropdownButton<String>(
            value: _selectedPrefix, // Debe coincidir con uno de los valores en _commonPrefixes
            items: _commonPrefixes.map((String prefix) {
              return DropdownMenuItem<String>(
                value: prefix,
                child: Text(prefix, style: inputStyle),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  _selectedPrefix = newValue; // Actualiza el prefijo seleccionado
                });
              }
            },
            underline: Container(), // Elimina la línea del Dropdown
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _controller,
            style: inputStyle,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly, // Permite solo dígitos
              LengthLimitingTextInputFormatter(10),  // Limita la entrada a 10 dígitos
            ],
            onChanged: _validateInput,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              isDense: true,
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              errorText: _errorText, // Muestra el error si es necesario
            ),
          ),
        ),
      ],
    );
  }


  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;
    final textColor = darkModeProvider.textColor;
    final backgroundColor = darkModeProvider.backgroundColor;
    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    final inputStyle = TextStyle(
      color: textColor,
      fontSize: fontSizeProvider.fontSize,
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(widget.icon, size: 20, color: textColor),
            SizedBox(width: 8),
            Text(
              widget.title,
              style: TextStyle(
                color: textColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey[850] : Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ingresa tu ${widget.type == 'email' ? 'correo electrónico' : widget.type == 'phone' ? 'número telefónico' : 'región'}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: fontSizeProvider.fontSize + 1,
                        color: textColor,
                      ),
                    ),
                    SizedBox(height: 20),
                    widget.type == 'phone'
                        ? _buildPhoneInput(inputStyle)
                        : TextField(
                      controller: _controller,
                      style: inputStyle,
                      onChanged: _validateInput,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey.shade400),
                        ),
                        errorText: _errorText,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      _getValidationMessage(widget.type),
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: fontSizeProvider.fontSize - 4,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isValidInput ? _saveChanges : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isValidInput
                      ? Colors.cyan
                      : Colors.cyan.shade900,
                  minimumSize: Size(double.infinity, 45),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Guardar cambios',
                  style: TextStyle(
                    fontSize: fontSizeProvider.fontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.white
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getValidationMessage(String type) {
    switch (type) {
      case 'email':
        return '• Debe contener @ y un dominio válido\n• Sin espacios ni caracteres especiales\n• Ejemplo: usuario@dominio.com';
      case 'phone':
        return '• Debe contener 10 dígitos\n• Sin espacios ni caracteres especiales\n• Solo números';
      case 'region':
        return '• Entre 2 y 50 caracteres\n• Puede contener letras, espacios y guiones\n• Sin números ni caracteres especiales';
      default:
        return '';
    }
  }
}
