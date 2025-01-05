import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';
import '../../Globales/estadoDark-White/DarkModeProvider.dart';
import '../providers/AuthProvider.dart';

class CodeVerificationScreen extends StatefulWidget {
  final String email;
  CodeVerificationScreen({required this.email});

  @override
  _CodeVerificationScreenState createState() => _CodeVerificationScreenState();
}

class _CodeVerificationScreenState extends State<CodeVerificationScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _codeControllers = List.generate(6, (index) => TextEditingController());
  List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  int failedAttempts = 0;
  final int maxAttempts = 5;

  // Timer variables
  Timer? _timer;
  int _remainingTime = 60; // 3 minutos en segundos
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        timer.cancel();
        _showTimeoutDialog();
      }
    });
  }

  String get _timeDisplay {
    int minutes = _remainingTime ~/ 60;
    int seconds = _remainingTime % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final isDarkMode = darkModeProvider.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF9B30FF),
            Color(0xFF00BFFF),
            Color(0xFF00FFFF),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: Center(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.black.withOpacity(0.8)
                    : Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(isDarkMode),
                  SizedBox(height: 24),
                  _buildTimer(isDarkMode),
                  SizedBox(height: 24),
                  _buildInputFields(isDarkMode),
                  SizedBox(height: 24),
                  _buildVerifyButton(),
                  SizedBox(height: 16),
                  _buildResendButton(isDarkMode),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return email; // Verificar formato válido
    final localPart = parts[0];
    final domainPart = parts[1];

    // Mostrar los primeros 3 caracteres del nombre y el dominio completo
    final visibleLocal = localPart.length > 3 ? localPart.substring(0, 3) : localPart;
    return '$visibleLocal******@${domainPart}';
  }

  Widget _buildHeader(bool isDarkMode) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [Color(0xFF9B30FF), Color(0xFF00BFFF)],
          ).createShader(bounds),
          child: Icon(
            Icons.verified,
            size: 48,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 16),
        Text(
          'Verificación de Código',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Se ha enviado un código a tu correo',
          style: TextStyle(
            fontSize: 12,
            color: isDarkMode ? Colors.white70 : Colors.black54,
          ),
        ),
        Text(
          maskEmail(widget.email),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Color(0xFF00BFFF),
          ),
        ),
      ],
    );
  }


  Widget _buildTimer(bool isDarkMode) {
    final color = _remainingTime < 30 ? Colors.red : Color(0xFF00BFFF);
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.timer_outlined, size: 16, color: color),
          SizedBox(width: 8),
          Text(
            _timeDisplay,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputFields(bool isDarkMode) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = (constraints.maxWidth - 50) / 6; // Account for spacing
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: itemWidth,
                  height: 50,
                  child: TextFormField(
                    controller: _codeControllers[index],
                    focusNode: _focusNodes[index],
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9]')),
                      LengthLimitingTextInputFormatter(1),
                      UpperCaseTextFormatter(),
                    ],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18, // Slightly reduced font size
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? Colors.white : Colors.black,
                      letterSpacing: 1.2,
                    ),
                    cursorWidth: 2,
                    cursorHeight: 24,
                    cursorColor: Color(0xFF00BFFF),
                    decoration: InputDecoration(
                      counterText: '',
                      contentPadding: EdgeInsets.zero, // Reduce internal padding
                      filled: true,
                      fillColor: isDarkMode
                          ? Colors.white.withOpacity(0.12)
                          : Colors.grey.withOpacity(0.12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.3)
                              : Colors.black.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDarkMode
                              ? Colors.white.withOpacity(0.3)
                              : Colors.black.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Color(0xFF00BFFF),
                          width: 1.5,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Colors.red.shade400,
                          width: 1,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.length == 1 && index < 5) {
                        _focusNodes[index + 1].requestFocus();
                        _animationController.forward(from: 0.0);
                      } else if (value.isEmpty && index > 0) {
                        _focusNodes[index - 1].requestFocus();
                      }

                      if (index == 5 && value.length == 1) {
                        String completeCode = _codeControllers
                            .map((controller) => controller.text)
                            .join();
                        if (completeCode.length == 6) {
                          FocusScope.of(context).unfocus();
                        }
                      }
                    },
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }

  Widget _buildVerifyButton() {
    return Container(
      width: double.infinity,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF9B30FF), Color(0xFF00BFFF)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Color(0xFF00BFFF).withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _verifyCode,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Verificar Código',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildResendButton(bool isDarkMode) {
    return TextButton(
      onPressed: _remainingTime == 0 ? _resendCode : null,
      child: Text(
        'Reenviar código',
        style: TextStyle(
          fontSize: 12,
          color: _remainingTime == 0
              ? Color(0xFF00BFFF)
              : (isDarkMode ? Colors.white60 : Colors.black45),
        ),
      ),
    );
  }

  void _verifyCode() async {
    if (_formKey.currentState!.validate()) {
      final code = _codeControllers.map((controller) => controller.text).join('');
      try {
        await Provider.of<AuthProvider>(context, listen: false)
            .verifyCode(widget.email, code);
        _showSuccessDialog();
      } catch (e) {
        failedAttempts++;
        _handleVerificationError();
      }
    }
  }

  void _handleVerificationError() {
    if (failedAttempts >= maxAttempts) {
      _showMaxAttemptsError();
    } else {
      _showVerificationError();
    }
    _codeControllers.forEach((controller) => controller.clear());
    _focusNodes[0].requestFocus();
  }

  void _showMaxAttemptsError() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        elevation: 8,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF9B30FF),
                Color(0xFF00BFFF),
                Color(0xFF00FFFF),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
            ),
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Color(0xFF9B30FF),
                ),
                SizedBox(height: 16),
                Text(
                  'Demasiados intentos',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    foreground: Paint()
                      ..shader = LinearGradient(
                        colors: [
                          Color(0xFF9B30FF),
                          Color(0xFF00BFFF),
                        ],
                      ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'Por favor, intenta más tarde',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12), backgroundColor: Color(0xFF9B30FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Entendido',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  void _showVerificationError() {
    Fluttertoast.showToast(
      msg: "Código incorrecto. Intentos restantes: ${maxAttempts - failedAttempts}",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP, // Puedes cambiarlo a TOP o CENTER
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.grey.shade800,
      textColor: Colors.white,
      fontSize: 11.0,
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                'lib/assets/succes/success.json',
                width: 100,
                height: 100,
                repeat: false,
              ),
              SizedBox(height: 16),
              Text(
                '¡Verificación Exitosa!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF9B30FF),
                ),
              ),
              SizedBox(height: 24),
              Text(
                'Redirigiendo...',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacementNamed('/login');
    });
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? Color(0xFF1E1E1E)
            : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with icon
              Icon(
                Icons.timer_off_outlined,
                size: 48,
                color: Colors.white,
              ),

              // Title
              Padding(
                padding: EdgeInsets.only(top: 24, left: 24, right: 24),
                child: Text(
                  'Tiempo expirado',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'El código ha expirado. ¿Deseas solicitar uno nuevo?',
                  style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white70
                        : Colors.black87,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Divider
              Divider(height: 1),

              // Actions
              Container(
                padding: EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Cancel button
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    // Resend button
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF9B30FF), Color(0xFF00BFFF)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0xFF9B30FF).withOpacity(0.3),
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _resendCode();
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Reenviar',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
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

  void _resendCode() {
    setState(() {
      _remainingTime = 60;
    });
    _startTimer();

    // Mostrar Toast
    Fluttertoast.showToast(
      msg: "Nuevo código enviado",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.TOP, // Puedes cambiarlo a TOP, CENTER, etc.
      timeInSecForIosWeb: 2,
      backgroundColor: Colors.grey.shade800,
      textColor: Colors.white,
      fontSize: 11.0,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _codeControllers.forEach((controller) => controller.dispose());
    _focusNodes.forEach((node) => node.dispose());
    super.dispose();
  }
}

// Custom formatter for uppercase text
class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}