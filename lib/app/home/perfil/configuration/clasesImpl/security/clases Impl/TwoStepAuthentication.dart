import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'dart:async';

class TwoStepAuthentication extends StatefulWidget {
  final Function(String) onVerificationComplete;
  final Future<bool> Function(String) validateCode;
  final Future<void> Function() resendCode;

  const TwoStepAuthentication({
    Key? key,
    required this.onVerificationComplete,
    required this.validateCode,
    required this.resendCode,
  }) : super(key: key);

  @override
  State<TwoStepAuthentication> createState() => _TwoStepAuthenticationState();
}

class _TwoStepAuthenticationState extends State<TwoStepAuthentication> {
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;
  String _errorText = '';
  int _resendTimeout = 60;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    setState(() {
      _canResend = false;
      _resendTimeout = 60;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendTimeout > 0) {
          _resendTimeout--;
        } else {
          _canResend = true;
          timer.cancel();
        }
      });
    });
  }

  Future<void> _verifyCode(String code) async {
    if (code.length != 6) return;

    setState(() {
      _isLoading = true;
      _errorText = '';
    });

    try {
      final isValid = await widget.validateCode(code);
      if (isValid) {
        widget.onVerificationComplete(code);
      } else {
        setState(() {
          _errorText = 'Invalid verification code. Please try again.';
          _pinController.clear();
        });
      }
    } catch (e) {
      setState(() {
        _errorText = 'An error occurred. Please try again.';
        _pinController.clear();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleResendCode() async {
    if (!_canResend) return;

    setState(() {
      _isLoading = true;
      _errorText = '';
    });

    try {
      await widget.resendCode();
      _startResendTimer();
    } catch (e) {
      setState(() {
        _errorText = 'Failed to resend code. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Verification Code',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Enter the 6-digit code sent to your device',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),
                PinCodeTextField(
                  appContext: context,
                  length: 6,
                  controller: _pinController,
                  obscureText: false,
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(8),
                    fieldHeight: 56,
                    fieldWidth: 44,
                    activeFillColor: Colors.white,
                    inactiveFillColor: Colors.grey[100],
                    selectedFillColor: Colors.white,
                    activeColor: Theme.of(context).primaryColor,
                    inactiveColor: Colors.grey[300],
                    selectedColor: Theme.of(context).primaryColor,
                  ),
                  animationDuration: const Duration(milliseconds: 300),
                  enableActiveFill: true,
                  errorAnimationController: null,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {
                      _errorText = '';
                    });
                  },
                  onCompleted: _verifyCode,
                ),
                if (_errorText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      _errorText,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                Center(
                  child: TextButton(
                    onPressed: _canResend ? _handleResendCode : null,
                    child: Text(
                      _canResend
                          ? 'Resend Code'
                          : 'Resend Code in $_resendTimeout seconds',
                      style: TextStyle(
                        color: _canResend
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                      ),
                    ),
                  ),
                ),
                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: CircularProgressIndicator(),
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