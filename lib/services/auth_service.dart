import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quicserve_flutter/constants/api_endpoints.dart';
import 'package:quicserve_flutter/services/api/base_api_service.dart';

class AuthService {
  final BaseApiService _apiService = BaseApiService();
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> loginAdmin(String email, String password) async {
    final response = await _apiService.post(
      ApiEndpoints.login,
      {
        'email': email,
        'password': password
      },
    );
    if (response['success']) {
      await _storage.write(key: 'token', value: response['data']['token']);
    }
    return response;
  }

  Future<Map<String, dynamic>> loginStaff(String pinNumber) async {
    final response = await _apiService.post(
      ApiEndpoints.stafflogin,
      {
        'pinNumber': pinNumber
      },
    );
    print('Staff login response: $response');
    if (response['success'] == true) {
      await _storage.write(key: 'token', value: response['data']['token']);
      await _storage.write(key: 'staffID', value: response['data']['user']['staffID'].toString());
      await _storage.write(key: 'cashierHourID', value: response['data']['cashierHourID']);
      print('Stored staff token: ${response['data']['token']}');
      print('Stored staffID: ${response['data']['user']['staffID']}');
      print('Stored cashierHourID: ${response['data']['cashierHourID']}');
    }
    return response;
  }

  Future<Map<String, dynamic>> logout(String cashierHourID) async {
    if (cashierHourID.isEmpty) {
      return {
        'success': false,
        'message': 'Missing cashierHourID'
      };
    }

    final response = await _apiService.post(ApiEndpoints.logout, {
      'cashierHourID': cashierHourID,
    });
    print('Logout response: $response');
    if (response['success'] == true) {
      await _storage.delete(key: 'token');
      print('Cleared token from storage');
    } else {
      final message = response['message']?.toString() ?? 'Logout failed';
      print('Logout failed: $message');
      return {
        'success': false,
        'message': message,
      };
    }
    return response;
  }

  Future<Map<String, dynamic>> authorizeLogin(String pin) async {
    final response = await _apiService.post(
      '${ApiEndpoints.sales}/login',
      {
        'pinNumber': pin
      },
    );

    return response;
  }
}
