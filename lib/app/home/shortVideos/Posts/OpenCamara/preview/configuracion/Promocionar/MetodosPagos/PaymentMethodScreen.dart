import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'package:intl/intl.dart';

class PaymentMethodScreen extends StatefulWidget {
  @override
  _PaymentMethodScreenState createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String _cardNumber = '';
  String _cardHolder = '';
  String _expiryDate = '';
  String _cvv = '';
  bool _isFlipped = false;
  late AnimationController _controller;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    setState(() {
      _isFlipped = !_isFlipped;
      if (_isFlipped) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 10),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue,
            hintColor: Colors.blue,
            colorScheme: ColorScheme.light(primary: Colors.blue),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        _expiryDate = DateFormat('MM/yy').format(pickedDate);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Agregar Método de Pago',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _flipAnimation,
                    builder: (context, child) {
                      return Transform(
                        transform: Matrix4.rotationY(_flipAnimation.value * pi),
                        alignment: Alignment.center,
                        child: _flipAnimation.value >= 0.5
                            ? _buildCardBack()
                            : _buildCardFront(),
                      );
                    },
                  ),
                ],
              ),
            ),
            // Contenedor para las flechas
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios, size: 30, color: Colors.black),
                    onPressed: () {
                      _flipCard();
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.arrow_forward_ios, size: 30, color: Colors.black),
                    onPressed: () {
                      _flipCard();
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    label: 'Número de Tarjeta',
                    onChanged: (value) {
                      setState(() {
                        _cardNumber = value.replaceAll(RegExp(r'\s+'), '');
                      });
                    },
                    validator: _validateCardNumber,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(16),
                    ],
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    label: 'Nombre del Titular',
                    onChanged: (value) {
                      setState(() {
                        _cardHolder = value;
                      });
                    },
                    validator: _validateCardHolder,
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => _selectExpiryDate(context),
                    child: AbsorbPointer(
                      child: _buildTextField(
                        label: 'Fecha de Vencimiento (MM/AA)',
                        onChanged: (value) => setState(() {
                          _expiryDate = value;
                        }),
                        validator: _validateExpiryDate,
                        keyboardType: TextInputType.none,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    label: 'CVV',
                    onChanged: (value) {
                      setState(() {
                        _cvv = value;
                        _isFlipped = true;
                        _controller.forward();
                      });
                    },
                    validator: _validateCVV,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _savePaymentMethod();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: Text('Guardar Tarjeta',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardFront() {
    return Container(
      width: 300,
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.white, Colors.black],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TARJETA DE CRÉDITO',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              _cardNumber.isEmpty ? '**** **** **** ****' : _formatCardNumber(_cardNumber),
              style: TextStyle(color: Colors.black, fontSize: 20),
            ),
            SizedBox(height: 20),
            Text(
              _cardHolder.isEmpty ? 'NOMBRE DEL TITULAR' : _cardHolder,
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            SizedBox(height: 10),
            Text(
              _expiryDate.isEmpty ? 'MM/AA' : _expiryDate,
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCardNumber(String cardNumber) {
    return cardNumber.replaceAllMapped(RegExp(r'.{4}'), (match) => '${match.group(0)} ').trim();
  }

  Widget _buildCardBack() {
    return Container(
      width: 300,
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1D2D50), // Azul oscuro
            Color(0xFF133B5C), // Azul intermedio
            Color(0xFFEBE6E6), // Gris claro
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10.0,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: Colors.black,
              height: 20,
            ),
            SizedBox(height: 20),
            Text(
              _cvv.isEmpty ? 'CVV' : _cvv,
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTextField({
    required String label,
    required ValueChanged<String> onChanged,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      onChanged: onChanged,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
      ),
    );
  }

  String? _validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Número de tarjeta requerido';
    }
    if (value.length != 16) {
      return 'Número de tarjeta debe tener 16 dígitos';
    }
    return null;
  }

  String? _validateCardHolder(String? value) {
    if (value == null || value.isEmpty) {
      return 'Nombre del titular requerido';
    }
    return null;
  }

  String? _validateExpiryDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Fecha de vencimiento requerida';
    }
    return null;
  }

  String? _validateCVV(String? value) {
    if (value == null || value.isEmpty) {
      return 'CVV requerido';
    }
    if (value.length != 3) {
      return 'CVV debe tener 3 dígitos';
    }
    return null;
  }

  void _savePaymentMethod() {
    // Lógica para guardar el método de pago
    print('Método de pago guardado: $_cardNumber, $_cardHolder, $_expiryDate, $_cvv');
  }
}
