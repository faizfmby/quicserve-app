import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quicserve_flutter/models/user.dart';
import 'package:quicserve_flutter/screen/login/pin_code_screen.dart';
import 'package:quicserve_flutter/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final _storage = const FlutterSecureStorage();
  User? _user;
  bool _isLoggedIn = false;

  User? get user => _user;
  bool get isLoggedIn => _isLoggedIn;

  Future<bool> loginAdmin(String email, String password) async {
    try {
      final result = await _authService.loginAdmin(email, password);
      if (result['success']) {
        _user = User.fromJson(result['data']['user']);
        _isLoggedIn = true;

        // Optionally store non-sensitive user data in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(result['data']['user']));

        notifyListeners();
        return true;
      } else {
        _isLoggedIn = false;
        _user = null;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoggedIn = false;
      _user = null;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithPin(String pin) async {
    try {
      final result = await _authService.loginStaff(pin);
      print('Login result: $result');
      if (result['success'] == true) {
        final userJson = result['data']['user'] as Map<String, dynamic>;
        _user = User.fromJson(userJson);

        // Validate required fields
        if (_user?.id == null || _user?.name == null || _user?.contact == null || _user?.role == null) {
          throw Exception('Invalid user data: missing required fields');
        }

        _isLoggedIn = true;

        // Optionally store non-sensitive user data in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(userJson));

        notifyListeners();
        return true;
      } else {
        _isLoggedIn = false;
        _user = null;
        notifyListeners();
        throw Exception(result['message'] ?? 'Invalid PIN');
      }
    } catch (e) {
      print('Login error: $e');
      _isLoggedIn = false;
      _user = null;
      notifyListeners();
      throw Exception('Login failed: $e');
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      final cashierHourID = await _storage.read(key: 'cashierHourID');

      if (cashierHourID == null || cashierHourID.isEmpty) {
        print('Missing cashierHourID. Cannot logout properly.');
        return;
      }

      final result = await _authService.logout(cashierHourID);
      print('Logout result: $result');
      if (!result['success']) {
        print('Server logout failed: ${result['message']}');
      }
    } catch (e) {
      print('Logout error: $e');
    } finally {
      // Always clear local state regardless of server response
      _user = null;
      _isLoggedIn = false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user');
      await _storage.deleteAll(); // Clear all storage (token, staffID, etc.)
      notifyListeners();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const PinCodeScreen()),
        (route) => false,
      );
    }
  }

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('user');
    final token = await _storage.read(key: 'token');

    if (userData != null && token != null) {
      _user = User.fromJson(jsonDecode(userData));
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  Future<bool> authorizeAccess(String pin) async {
    try {
      final result = await _authService.authorizeLogin(pin);
      print('Authorization response: $result');

      final isSuccess = result['success'] == true;
      final staff = result['staff'];

      if (isSuccess && staff != null) {
        final role = result['staff']['staffRole'];

        if (role == 'Manager' || role == 'Supervisor') {
          return true;
        } else {
          throw Exception('Only Manager and Supervisor have access');
        }
      } else {
        throw Exception(result['message'] ?? 'Authorization failed');
      }
    } catch (e) {
      print('Authorization error: $e');
      rethrow;
    }
  }
}
