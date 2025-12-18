import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String _userId = ''; // Store MongoDB _id
  String _username = '';
  String _email = '';
  String _phone = '';

  bool get isLoggedIn => _isLoggedIn;
  String get userId => _userId;
  String get username => _username;
  String get email => _email;
  String get phone => _phone;

  // Login
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          _isLoggedIn = true;
          _userId = data['user']['id'];
          _email = data['user']['email'];
          _username = data['user']['name'];
          _phone = data['user']['phone'] ?? '';
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      print('Error Login: $e');
    }
    return false;
  }

  // Register
  Future<bool> register(
      String name, String email, String password, String phone) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(
          {
            'name': name,
            'email': email,
            'password': password,
            'phone': phone,
          },
        ),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          _isLoggedIn = true;
          _email = data['user']['email'];
          _username = data['user']['name'];
          _phone = data['user']['phone'] ?? '';
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      print('Error Register: $e');
    }
    return false;
  }

  // Logout
  void logout() {
    _isLoggedIn = false;
    _username = '';
    _email = '';
    notifyListeners();
  }

  // Update Profile (Mock for now as backend doesn't support yet)
  Future<void> updateProfile(String newName) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _username = newName;
    notifyListeners();
  }

  // Change Password
  Future<bool> changePassword(String currentPass, String newPass) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.changePassword),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': _email,
          'oldPassword': currentPass,
          'newPassword': newPass,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'];
      }
    } catch (e) {
      print('Error Change Password: $e');
    }
    return false;
  }
}
