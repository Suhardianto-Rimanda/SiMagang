import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../api/auth_service.dart';
import '../models/user_model.dart';

// Enum untuk status autentikasi
enum AuthStatus { uninitialized, authenticated, authenticating, unauthenticated }

class AuthProvider with ChangeNotifier {
  AuthStatus _status = AuthStatus.uninitialized;
  UserModel? _user;
  String? _token;

  final AuthService _authService = AuthService();

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get token => _token;

  AuthProvider() {
    _tryAutoLogin();
  }

  Future<bool> login(String email, String password) async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    try {
      final result = await _authService.login(email, password);
      _user = result['user'];
      _token = result['token'];
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> _tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    _token = prefs.getString('token');
    final userData = jsonDecode(prefs.getString('user')!);
    _user = UserModel.fromJson(userData);
    _status = AuthStatus.authenticated;
    notifyListeners();
  }

  Future<void> logout() async {
    _status = AuthStatus.unauthenticated;
    _user = null;
    _token = null;
    await _authService.logout();
    notifyListeners();
  }
}
