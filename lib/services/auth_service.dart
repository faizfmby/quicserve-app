import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quicserve_flutter/constants/api_endpoints.dart';
import 'package:quicserve_flutter/models/company.dart';
import 'package:quicserve_flutter/services/api/base_api_service.dart';

class AuthService {
  final BaseApiService _apiService = BaseApiService();
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> loginCompany(
      String email, String password) async {
    final response = await _apiService.post(
      ApiEndpoints.login,
      {'email': email, 'password': password},
    );
    if (response['success']) {
      await _storage.write(
          key: 'company-token', value: response['data']['token']);
      await _storage.write(
          key: 'company_slug', value: response['data']['company_slug']);
      await _storage.write(
          key: 'company_name',
          value: response['data']['user']['company']['company_name']);
    }
    return response;
  }

  Future<String?> getCompanySlug() async {
    return await _storage.read(key: 'company_slug');
  }

  Future<Map<String, dynamic>> loginStaff(String pinNumber) async {
    final companySlug = await getCompanySlug();
    print('companySlug in loginStaff: $companySlug');
    if (companySlug == null) {
      throw Exception('No company slug found. Please login first.');
    }

    final response = await _apiService.post(
      ApiEndpoints.withCompany(companySlug, ApiEndpoints.cashierLogin),
      {'pinNumber': pinNumber},
    );
    print('Staff login response: $response');
    if (response['success'] == true) {
      await _storage.write(
          key: 'cashier-token', value: response['data']['token']);
      await _storage.write(
          key: 'staffID',
          value: response['data']['user']['staffID'].toString());
      await _storage.write(
          key: 'cashierHourID', value: response['data']['cashierHourID']);
      print('Stored staff token: ${response['data']['token']}');
      print('Stored staffID: ${response['data']['user']['staffID']}');
      print('Stored cashierHourID: ${response['data']['cashierHourID']}');
    }
    return response;
  }

  Future<Map<String, dynamic>> logoutCashier(String cashierHourID) async {
    final companySlug = await getCompanySlug();
    print('Company slug: $companySlug');
    if (companySlug == null) {
      throw Exception('No company slug found. Please login first.');
    }

    if (cashierHourID.isEmpty) {
      return {'success': false, 'message': 'Missing cashierHourID'};
    }

    final response = await _apiService.post(
        ApiEndpoints.withCompany(companySlug, ApiEndpoints.cashierLogout), {
      'cashierHourID': cashierHourID,
    });
    print('Logout response: $response');
    if (response['success'] == true) {
      await _storage.delete(key: 'cashier-token');
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
    final companySlug = await getCompanySlug();
    if (companySlug == null) {
      throw Exception('No company slug found. Please login first.');
    }

    final response = await _apiService.post(
      '${ApiEndpoints.withCompany(companySlug, ApiEndpoints.sales)}/login',
      {'pinNumber': pin},
    );

    return response;
  }
}
