import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/local_auth.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'dart:async';

import '../../../../../Globales/estadoDark-White/DarkModeProvider.dart';
import '../../../../../Globales/estadoDark-White/Fuentes/FontSizeProvider.dart';

class VerificationCodeScreen extends StatefulWidget {
  @override
  _VerificationCodeScreenState createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen>
    with SingleTickerProviderStateMixin {
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  Timer? _timer;
  int _timeLeft = 0;
  bool _isRequestingCode = false;
  bool _isVerifying = false;
  String _error = '';
  int _attemptCount = 0;
  final int _maxAttempts = 3;
  DateTime? _lastRequestTime;
  bool _isBlocked = false;
  int _blockTimeLeft = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _requestCode();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final darkModeProvider = Provider.of<DarkModeProvider>(context);
    final backgroundColor = darkModeProvider.backgroundColor;
    final iconColor = darkModeProvider.iconColor;
    final textColor = darkModeProvider.textColor;
    final isDarkMode = darkModeProvider.isDarkMode;

    final fontSizeProvider = Provider.of<FontSizeProvider>(context);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: iconColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Verificación',
          style: TextStyle(
            color: textColor,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          if (_isBlocked) _buildBlockedMessage(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(),
                  const SizedBox(height: 40),
                  _buildVerificationFields(),
                  if (_error.isNotEmpty) _buildError(),
                  const SizedBox(height: 16),
                  _buildTimer(),
                  const SizedBox(height: 30),
                  _buildVerifyButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlockedMessage() {
    return Container(
      color: Colors.red[50],
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.red[400], size: 16),
          SizedBox(width: 8),
          Text(
            'Cuenta bloqueada por $_blockTimeLeft minutos',
            style: TextStyle(
                color: Colors.red[400],
                fontSize: 10,
                fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Ingresa el código de 6 dígitos',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Para cambiar o establecer una contraseña escribe \n el código de 6 digitos que te enviamos +51*****890',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w400,
            color: Colors.grey,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        6,
        (index) => Container(
          width: 40,
          margin: EdgeInsets.symmetric(horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                enabled: !_isBlocked,
                onChanged: (value) => _handleCodeInput(value, index),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  // Asegurar que no haya borde al no estar enfocado
                  focusedBorder: InputBorder.none,
                  // Sin borde al estar enfocado
                  counterText: '',
                  // Sin contador
                  contentPadding: EdgeInsets.zero, // Sin relleno adicional
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(1),
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              Container(
                height: 0.5, // Línea inferior más visible
                color: _controllers[index].text.isEmpty
                    ? Colors.grey[300]
                    : Colors.cyan,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: EdgeInsets.only(top: 16),
      child: Text(
        _error,
        style: TextStyle(
            color: Colors.red[400], fontSize: 9, fontWeight: FontWeight.w400),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildTimer() {
    return TextButton(
      onPressed: (_timeLeft == 0 && !_isRequestingCode && !_isBlocked)
          ? _canRequestNewCode
              ? _requestCode
              : null
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.refresh,
            size: 14,
            color: (_timeLeft == 0 && !_isBlocked && _canRequestNewCode)
                ? Colors.cyan
                : Colors.grey,
          ),
          SizedBox(width: 4),
          Text(
            _timeLeft > 0 ? 'Reenviar en $_timeLeft s' : 'Reenviar código',
            style: TextStyle(
              fontSize: 12,
              color: (_timeLeft == 0 && !_isBlocked && _canRequestNewCode)
                  ? Colors.cyan
                  : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerifyButton() {
    return SizedBox(
      width: double.infinity,
      height: 45,
      child: ElevatedButton(
        onPressed: (_isVerifying || _isBlocked) ? null : _verifyCode,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF9B30FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          elevation: 0,
        ),
        child: _isVerifying
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Verificar',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }

  bool get _canRequestNewCode {
    if (_lastRequestTime == null) return true;
    return DateTime.now().difference(_lastRequestTime!) > Duration(minutes: 2);
  }

  void _handleCodeInput(String value, int index) {
    if (value.length == 1) {
      if (index < 5) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  void _blockAccount() {
    setState(() {
      _isBlocked = true;
      _blockTimeLeft = 30;
    });

    Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {
        _blockTimeLeft--;
        if (_blockTimeLeft <= 0) {
          _isBlocked = false;
          _attemptCount = 0;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _verifyCode() async {
    String code = _controllers.map((controller) => controller.text).join();

    if (code.length != 6) {
      setState(() {
        _error = 'Por favor ingresa los 6 dígitos';
      });
      return;
    }

    if (_attemptCount >= _maxAttempts) {
      _blockAccount();
      return;
    }

    setState(() {
      _isVerifying = true;
      _error = '';
    });

    try {
      // Simular verificación de código
      await Future.delayed(Duration(seconds: 1));
      bool isValid = code == "123456"; // Simular código válido

      if (!isValid) {
        _attemptCount++;
        if (_attemptCount >= _maxAttempts) {
          _blockAccount();
        }
        throw Exception('Código inválido');
      }

      // Si el código es válido
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => PasswordChangeScreen(),
        ),
      );
    } catch (e) {
      setState(() {
        _error = 'Código inválido. Intento ${_attemptCount} de $_maxAttempts';
      });
    } finally {
      setState(() {
        _isVerifying = false;
      });
    }
  }

  Future<void> _requestCode() async {
    if (_isRequestingCode || _isBlocked) return;

    setState(() {
      _isRequestingCode = true;
      _error = '';
      _lastRequestTime = DateTime.now();
    });

    try {
      await Future.delayed(Duration(seconds: 1));
      _startTimer();

      // Limpiar campos
      _controllers.forEach((controller) => controller.clear());
      _focusNodes[0].requestFocus();
    } catch (e) {
      setState(() {
        _error = 'Error al enviar el código';
      });
    } finally {
      setState(() {
        _isRequestingCode = false;
      });
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _timeLeft = 60;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _controllers.forEach((controller) => controller.dispose());
    _focusNodes.forEach((node) => node.dispose());
    super.dispose();
  }
}

//cambiar password
class PasswordChangeScreen extends StatefulWidget {
  @override
  _PasswordChangeScreenState createState() => _PasswordChangeScreenState();
}

class _PasswordChangeScreenState extends State<PasswordChangeScreen>
    with SingleTickerProviderStateMixin {
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Controladores
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final List<TextEditingController> _codeControllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());

  // Estados
  String _currentStep = 'initial';
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  int _timerSeconds = 60;
  Map<String, String> _errors = {};

  // Animación
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Colores personalizados
  static const Color primaryPurple = Color(0xFF9B30FF);
  static const Color secondaryPurple = Color(0xFF7B68EE);

  static const Color primaryCyan = Colors.cyan;
  static const Color secondaryColor = Colors.cyan;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _checkBiometrics();
  }

  Future<void> _checkBiometrics() async {
    try {
      final canCheckBiometrics = await _localAuth.canCheckBiometrics;
      if (canCheckBiometrics) {
        await _authenticateWithBiometrics();
      } else {
        setState(() => _currentStep = 'password');
      }
    } catch (e) {
      setState(() => _currentStep = 'password');
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Por favor verifica tu identidad',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      if (authenticated) {
        setState(() => _currentStep = 'password');
      }
    } catch (e) {
      setState(() => _currentStep = 'password');
    }
  }

  void _validatePassword(String password) {
    if (password.isEmpty) {
      _errors['password'] = 'La contraseña no puede estar vacía';
    } else if (password.length < 8) {
      _errors['password'] = 'La contraseña debe tener al menos 8 caracteres';
    } else if (!RegExp(r'(?=.*[A-Z])').hasMatch(password)) {
      _errors['password'] = 'Debe incluir al menos una mayúscula';
    } else if (!RegExp(r'(?=.*[a-z])').hasMatch(password)) {
      _errors['password'] = 'Debe incluir al menos una minúscula';
    } else if (!RegExp(r'(?=.*[0-9])').hasMatch(password)) {
      _errors['password'] = 'Debe incluir al menos un número';
    } else if (!RegExp(r'(?=.*[!@#$%^&*])').hasMatch(password)) {
      _errors['password'] = 'Debe incluir al menos un carácter especial';
    } else {
      _errors.remove('password');
    }
    setState(() {});
  }

  Widget _buildCurrentPasswordInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contraseña actual',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _currentPasswordController,
          obscureText: _obscureCurrentPassword,
          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              // Bordes redondeados modernos.
              borderSide: BorderSide(
                  color: Colors.cyan, width: 2), // Borde cian al enfocarse.
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color: Colors.grey, width: 1), // Borde gris en estado normal.
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color: Colors.red, width: 1), // Borde rojo en caso de error.
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureCurrentPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: secondaryColor,
              ),
              onPressed: () => setState(
                  () => _obscureCurrentPassword = !_obscureCurrentPassword),
            ),
          ),
        ),
        if (_errors.containsKey('currentPassword'))
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              _errors['currentPassword']!,
              style: TextStyle(color: Colors.red, fontSize: 9),
            ),
          ),
      ],
    );
  }

  Widget _buildNewPasswordInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nueva contraseña',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _newPasswordController,
          obscureText: _obscureNewPassword,
          onChanged: _validatePassword,
          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              // Bordes redondeados modernos.
              borderSide: BorderSide(
                  color: Colors.cyan, width: 2), // Borde cian al enfocarse.
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color: Colors.grey, width: 1), // Borde gris en estado normal.
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color: Colors.red, width: 1), // Borde rojo en caso de error.
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                color: secondaryColor,
              ),
              onPressed: () =>
                  setState(() => _obscureNewPassword = !_obscureNewPassword),
            ),
          ),
        ),
        if (_errors.containsKey('password'))
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              _errors['password']!,
              style: TextStyle(color: Colors.red, fontSize: 10),
            ),
          ),
      ],
    );
  }

  Widget _buildVerificationCode() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 13),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline, size: 50, color: primaryPurple),
          SizedBox(height: 30),
          Text(
            'Verificación de seguridad',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Ingresa el código enviado a tu teléfono',
            style: TextStyle(fontSize: 10, color: Colors.grey),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              return Container(
                width: 45,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: primaryPurple.withOpacity(0.3)),
                ),
                child: TextField(
                  controller: _codeControllers[index],
                  focusNode: _focusNodes[index],
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  maxLength: 1,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    counterText: "",
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    if (value.length == 1 && index < 5) {
                      _focusNodes[index + 1].requestFocus();
                    }
                    if (value.length == 1 && index == 5) {
                      _verifyCode();
                    }
                  },
                ),
              );
            }),
          ),
          SizedBox(height: 30),
          if (_isLoading)
            Center(
              child: Lottie.asset(
                'lib/assets/loading/loading_infinity.json',
                width: 50,
                height: 50,
              ),
            ),
          if (!_isLoading)
            Text(
              '$_timerSeconds segundos restantes',
              style: TextStyle(
                color: secondaryPurple,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _verifyCode() async {
    setState(() => _isLoading = true);

    // Simulamos verificación del código
    await Future.delayed(Duration(seconds: 2));

    String code = _codeControllers.map((c) => c.text).join();
    if (code == '123456') {
      // Código de ejemplo
      setState(() {
        _isLoading = false;
        _currentStep = 'success';
      });
      _showSuccessDialog();
    } else {
      setState(() {
        _isLoading = false;
        _errors['code'] = 'Código incorrecto';
      });
      _showErrorSnackbar('Código incorrecto. Intenta nuevamente.');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'lib/assets/succes/success.json',
              width: 100,
              height: 100,
              repeat: false,
            ),
            SizedBox(height: 20),
            Text(
              '¡Contraseña actualizada!',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Tu contraseña ha sido actualizada exitosamente.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 10,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Aceptar',
              style: TextStyle(
                  color: primaryPurple,
                  fontSize: 12,
                  fontWeight: FontWeight.w500),
            ),
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      // También puedes usar TOP o CENTER
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey.shade800,
      textColor: Colors.white,
      fontSize: 10.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Theme(
      data: _getTheme(isDark),
      child: Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        appBar: AppBar(
          backgroundColor: isDark ? Colors.black : Colors.white,
          elevation: 0,
          title: Text(
            'Cambiar contraseña',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          // Centra el título
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: Duration(milliseconds: 300),
            child: _isLoading
                ? Center(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.grey.shade800
                            : Colors.grey.shade200,
                        // Fondo gris claro
                        borderRadius:
                            BorderRadius.circular(8), // Bordes redondeados
                      ),
                      child: Lottie.asset(
                        'lib/assets/loading/loading_infinity.json',
                        width: 50,
                        height: 50,
                      ),
                    ),
                  )
                : _buildCurrentStep(isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(bool isDark) {
    switch (_currentStep) {
      case 'verification':
        return _buildVerificationCode();

      case 'password':
        return SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCurrentPasswordInput(),
              SizedBox(height: 24),
              _buildNewPasswordInput(),
              SizedBox(height: 16),
              _buildPasswordStrengthIndicator(),
              SizedBox(height: 24),
              _buildConfirmPasswordInput(),
              SizedBox(height: 40),
              // Botón principal
              Container(
                width: double.infinity,
                height: 45,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [primaryPurple, secondaryPurple],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: primaryPurple.withOpacity(0.3),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: _isLoading ? null : _handleSubmit,
                    child: Center(
                      child: _isLoading
                          ? SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              'Continuar',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              // Hints de seguridad
              SizedBox(height: 24),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[900] : Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: secondaryColor.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: secondaryColor,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Consejos de seguridad',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    _buildSecurityHint(
                      'No uses la misma contraseña en múltiples sitios',
                      isDark,
                    ),
                    _buildSecurityHint(
                      'Evita usar información personal obvia',
                      isDark,
                    ),
                    _buildSecurityHint(
                      'Usa un gestor de contraseñas si es posible',
                      isDark,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

      default:
        return Center(
          child: Text(
            'Paso no válido',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        );
    }
  }

  Widget _buildSecurityHint(String text, bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 6),
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[600] : Colors.grey[400],
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmPasswordInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirmar contraseña',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
          onChanged: (value) {
            if (value != _newPasswordController.text) {
              setState(() {
                _errors['confirmPassword'] = 'Las contraseñas no coinciden';
              });
            } else {
              setState(() {
                _errors.remove('confirmPassword');
              });
            }
          },
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              // Bordes redondeados modernos.
              borderSide: BorderSide(
                  color: Colors.cyan, width: 2), // Borde cian al enfocarse.
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color: Colors.grey, width: 1), // Borde gris en estado normal.
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                  color: Colors.red, width: 1), // Borde rojo en caso de error.
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            // Menos altura
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_off
                    : Icons.visibility,
                color: secondaryColor,
              ),
              onPressed: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
          ),
        ),
        if (_errors.containsKey('confirmPassword'))
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              _errors['confirmPassword']!,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _isLoading = true;
      _errors.clear();
    });

    // Validaciones
    if (_currentPasswordController.text.isEmpty) {
      _errors['currentPassword'] = 'Ingresa tu contraseña actual';
    }

    _validatePassword(_newPasswordController.text);

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _errors['confirmPassword'] = 'Las contraseñas no coinciden';
    }

    if (_errors.isNotEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    // Simulamos verificación de la contraseña actual
    await Future.delayed(Duration(seconds: 2));

    // Aquí iría la verificación real con el backend
    if (_currentPasswordController.text == "contraseñaActual") {
      // Ejemplo
      setState(() {
        _isLoading = false;
        _currentStep = 'verification';
      });
      _startVerificationTimer();
    } else {
      setState(() {
        _isLoading = false;
        _errors['currentPassword'] = 'Contraseña incorrecta';
      });
      _showErrorSnackbar('La contraseña actual es incorrecta');
    }
  }

  void _startVerificationTimer() {
    setState(() => _timerSeconds = 60);
    const oneSec = Duration(seconds: 1);
    Future.doWhile(() async {
      await Future.delayed(oneSec);
      setState(() {
        if (_timerSeconds > 0) {
          _timerSeconds--;
        }
      });
      // Retornamos true si aún hay tiempo, false si el contador llega a 0.
      return _timerSeconds > 0;
    });
  }

  // Método para el modo claro/oscuro
  ThemeData _getTheme(bool isDark) {
    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      scaffoldBackgroundColor: isDark ? Colors.black : Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : Colors.black,
        ),
        titleTextStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          color: isDark ? Colors.white : Colors.black,
        ),
        bodyMedium: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: isDark ? Colors.grey[900] : Colors.grey[100],
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? primaryPurple.withOpacity(0.3) : primaryPurple,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  // Método para construir los indicadores de seguridad de la contraseña
  Widget _buildPasswordStrengthIndicator() {
    final password = _newPasswordController.text;
    final hasUppercase = password.contains(RegExp(r'[A-Z]'));
    final hasLowercase = password.contains(RegExp(r'[a-z]'));
    final hasNumbers = password.contains(RegExp(r'[0-9]'));
    final hasSpecialChars = password.contains(RegExp(r'[!@#$%^&*]'));
    final hasMinLength = password.length >= 8;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Requisitos de seguridad',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        _buildRequirementRow('Al menos 8 caracteres', hasMinLength),
        _buildRequirementRow('Al menos una mayúscula', hasUppercase),
        _buildRequirementRow('Al menos una minúscula', hasLowercase),
        _buildRequirementRow('Al menos un número', hasNumbers),
        _buildRequirementRow('Al menos un carácter especial', hasSpecialChars),
      ],
    );
  }

  Widget _buildRequirementRow(String text, bool isMet) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            color: isMet ? primaryCyan : Colors.grey,
            size: 13,
          ),
          SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
                color: isMet ? Colors.grey[400] : Colors.grey[600],
                fontSize: 8,
                fontWeight: isMet ? FontWeight.w400 : FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
