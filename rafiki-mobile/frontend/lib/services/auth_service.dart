import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'api.dart';

class AuthService extends ChangeNotifier {
  Map<String, dynamic>? _user;
  bool _isLoading = true;

  Map<String, dynamic>? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null) {
      try {
        final res = await Api.get('/auth/profile/');
        if (res.statusCode == 200) {
          _user = jsonDecode(res.body);
        } else {
          await logout();
        }
      } catch (_) {
        await logout();
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String username, String password) async {
    final res = await Api.post('/auth/login/', {
      'username': username,
      'password': password,
    });
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', data['access']);
      await prefs.setString('refresh_token', data['refresh']);
      final profile = await Api.get('/auth/profile/');
      _user = jsonDecode(profile.body);
      notifyListeners();
    } else {
      throw Exception('Login failed');
    }
  }

  Future<void> register(Map<String, dynamic> data) async {
    final res = await Api.post('/auth/register/', data);
    if (res.statusCode == 201) {
      await login(data['username'], data['password']);
    } else {
      final body = jsonDecode(res.body);
      throw Exception(body.toString());
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    _user = null;
    notifyListeners();
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final res = await Api.patch('/auth/profile/update/', data);
    if (res.statusCode == 200) {
      _user = jsonDecode(res.body);
      notifyListeners();
    }
  }
}
