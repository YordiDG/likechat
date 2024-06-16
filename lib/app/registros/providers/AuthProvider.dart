import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<void> register(
      String firstName,
      String lastName,
      String email,
      String password,
      String dob, // Este debe ser dateOfBirth en tu solicitud
      String gender,
      bool acceptTerms,
      ) async {
    final url = 'http://192.168.0.10:8088/api/v1/auth/register';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'firstname': firstName,
          'lastname': lastName,
          'email': email,
          'password': password,
          'dateOfBirth': dob,
          'gender': gender,
          'acceptTerms': acceptTerms,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        _isAuthenticated = true;
        notifyListeners();
      } else {
        throw Exception('Failed to register: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to register: $e');
    }
  }

  Future<void> sendVerificationCode(String email) async {
    final url = 'http://localhost:8088/api/v1/auth/authenticate';// URL del endpoint para enviar el código de verificación, ajusta según tu backend
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send verification code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to send verification code: $e');
    }
  }


  Future<void> verifyCode(String email, String code) async {
    final url = 'http://localhost:8088/api/v1/auth/activate-account';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'code': code,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to verify code: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to verify code: $e');
    }
  }

  Future<void> login(String email, String password) async {
    final url = 'http://192.168.0.10:8088/api/v1/auth/login';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        _isAuthenticated = true;
        notifyListeners();
      } else {
        throw Exception('Failed to login: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to login: $e');
    }
  }

  Future<void> recoverPassword(String email) async {
    final url = '';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send recovery email: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to send recovery email: $e');
    }
  }

  Future<void> updatePassword(String email, String oldPassword, String newPassword) async {
    final url = '';
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'oldPassword': oldPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to update password: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }
}
