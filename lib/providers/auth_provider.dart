import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quicserve_flutter/models/admin.dart';
import 'package:quicserve_flutter/models/cashier.dart';
import 'package:quicserve_flutter/models/user.dart';
import 'package:quicserve_flutter/screen/login/pin_code_screen.dart';
import 'package:quicserve_flutter/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final _storage = const FlutterSecureStorage();
  Admin? _admin;
  Cashier? _cashier;
  bool _isLoggedIn = false;
  bool _isCompanyLoggedIn = false;

  Admin? get admin => _admin;
  Cashier? get cashier => _cashier;
  bool get isLoggedIn => _isLoggedIn;
  bool get isCompanyLoggedIn => _isCompanyLoggedIn;

  Future<bool> loginCompany(String email, String password) async {
    try {
      final result = await _authService.loginCompany(email, password);
      print('Login result from authService: $result');
      if (result['success']) {
        _admin = Admin.fromJson(result['data']['user']);
        _isCompanyLoggedIn = true;

        // Save user session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user', jsonEncode(_admin));

        notifyListeners();
        return true;
      } else {
        _isCompanyLoggedIn = false;
        _cashier = null;
        notifyListeners();
        return false;
      }
    } catch (e, stack) {
      print('LoginCompany Error: $e');
      print(stack);
      _isCompanyLoggedIn = false;
      _cashier = null;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginWithPin(String pin) async {
    try {
      final result = await _authService.loginStaff(pin);
      print('Login result: $result');
      if (result['success'] == true) {
        final cashierJson = result['data']['user'] as Map<String, dynamic>;
        _cashier = Cashier.fromJson(cashierJson);

        // Validate required fields
        if (_cashier?.id == null ||
            _cashier?.staff == null ||
            _cashier?.cashierSlug == null ||
            _cashier?.pinNumber == null) {
          throw Exception('Invalid cashier data: missing required fields');
        }

        _isLoggedIn = true;

        // Optionally store non-sensitive cashier data in SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('cashier', jsonEncode(cashierJson));

        notifyListeners();
        return true;
      } else {
        _isLoggedIn = false;
        _cashier = null;
        notifyListeners();
        throw Exception(result['message'] ?? 'Invalid PIN');
      }
    } catch (e) {
      print('Login error: $e');
      _isLoggedIn = false;
      _cashier = null;
      notifyListeners();
      throw Exception('Login failed: $e');
    }
  }

  Future<void> logoutCashier(BuildContext context) async {
    try {
      final cashierHourID = await _storage.read(key: 'cashierHourID');

      if (cashierHourID == null || cashierHourID.isEmpty) {
        print('Missing cashierHourID. Cannot logout properly.');
        return;
      }

      final result = await _authService.logoutCashier(cashierHourID);
      print('Logout result: $result');
      if (!result['success']) {
        print('Server logout failed: ${result['message']}');
      }
    } catch (e) {
      print('Logout error: $e');
    } finally {
      // Only clear cashier-related state and storage
      _cashier = null;
      _isLoggedIn = false;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cashier');
      await _storage.delete(key: 'cashier-token');
      await _storage.delete(key: 'staffID');
      await _storage.delete(key: 'cashierHourID');
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
      _cashier = Cashier.fromJson(jsonDecode(userData));
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  Future<bool> authorizeAccess(String pin) async {
    try {
      final result = await _authService.authorizeLogin(pin);
      print('Authorization response: $result');

      final isSuccess = result['success'] == true;
      final cashier = result['cashier'];

      if (isSuccess && cashier != null) {
        final staff = cashier['staff'];
        final role = staff != null ? staff['staffRole'] : null;

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
