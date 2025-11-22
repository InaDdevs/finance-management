import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;

  String? _userName;
  String? _userEmail;

  bool get isAuthenticated => _isAuthenticated;
  String? get userName => _userName;
  String? get userEmail => _userEmail;

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isLoggedIn') ?? false;

    if (_isAuthenticated) {
      _userName = prefs.getString('userName');
      _userEmail = prefs.getString('userEmail');
    }

    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    final user = await DatabaseHelper.instance.getUser(email, password);

    if (user != null) {
      _isAuthenticated = true;

      _userName = user['name'];
      _userEmail = user['email'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('userName', _userName ?? 'Usuário');
      await prefs.setString('userEmail', _userEmail ?? email);

      notifyListeners();
      return true;
    }

    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      await DatabaseHelper.instance.registerUser({
        'name': name,
        'email': email,
        'password': password,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    _isAuthenticated = false;
    _userName = null;
    _userEmail = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    notifyListeners();
  }
}