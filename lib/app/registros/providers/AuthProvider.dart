import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;


class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<void> register(String firstName, String lastName, String email, String password, String dob, String gender, bool acceptTerms) async {
    final url = 'http://your_backend_api/register';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'dateOfBirth': dob,
        'gender': gender,
        'acceptTerms': acceptTerms,
      }),
    );

    if (response.statusCode == 200) {
      _isAuthenticated = true;
      notifyListeners();
    } else {
      throw Exception('Failed to register');
    }
  }

  Future<void> login(String email, String password) async {
    final url = 'http://your_backend_api/login';
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
      throw Exception('Failed to login');
    }
  }

  Future<void> recoverPassword(String email) async {
    final url = 'http://your_backend_api/recover_password';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'email': email}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to send recovery email');
    }
  }

  Future<void> updatePassword(String email, String oldPassword, String newPassword) async {
    final url = 'http://your_backend_api/update_password';
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
      throw Exception('Failed to update password');
    }
  }
}
