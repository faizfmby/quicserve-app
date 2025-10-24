import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quicserve_flutter/constants/api_endpoints.dart';

class BaseApiService {
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    final token = await _storage.read(key: 'token');
    print('Retrieved token: $token');
    return token;
  }

  Future<Map<String, String>> _getHeaders({bool includeToken = true}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (includeToken) {
      final token = await _getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
        print('Authorization header set: Bearer $token');
      } else {
        print('No token found in storage');
      }
    }
    return headers;
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      print('GET request to ${ApiEndpoints.baseUrl}$endpoint');
      final response = await http
          .get(
            Uri.parse('${ApiEndpoints.baseUrl}$endpoint'),
            headers: await _getHeaders(),
          )
          .timeout(ApiEndpoints.timeout);

      return _handleResponse(response, endpoint);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    try {
      print('POST request to ${ApiEndpoints.baseUrl}$endpoint with data: $data');
      final response = await http
          .post(
            Uri.parse('${ApiEndpoints.baseUrl}$endpoint'),
            headers: await _getHeaders(includeToken: true),
            body: jsonEncode(data),
          )
          .timeout(ApiEndpoints.timeout);

      return _handleResponse(response, endpoint);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    try {
      print('PUT request to ${ApiEndpoints.baseUrl}$endpoint with data: $data');
      final response = await http
          .put(
            Uri.parse('${ApiEndpoints.baseUrl}$endpoint'),
            headers: await _getHeaders(includeToken: true),
            body: jsonEncode(data),
          )
          .timeout(ApiEndpoints.timeout);

      return _handleResponse(response, endpoint);
    } catch (e) {
      return _handleError(e);
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      print('DELETE request to ${ApiEndpoints.baseUrl}$endpoint');
      final response = await http
          .delete(
            Uri.parse('${ApiEndpoints.baseUrl}$endpoint'),
            headers: await _getHeaders(includeToken: true),
          )
          .timeout(ApiEndpoints.timeout);

      return _handleResponse(response, endpoint);
    } catch (e) {
      return _handleError(e);
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response, String endpoint) {
    final statusCode = response.statusCode;
    final body = response.body.isNotEmpty ? jsonDecode(response.body) as Map<String, dynamic> : {};
    print('Response [$statusCode]: ${response.body}'); // Log raw response

    if (statusCode >= 200 && statusCode < 300) {
      // Debug the body structure
      print('Response body keys: ${body.keys.toString()}');
      // Check for success based on status or success key
      final isSuccess = (body['status'] == 'success' || body['success'] == true) || statusCode == 201;
      print('isSuccess: $isSuccess, status: ${body['status']}, success: ${body['success']}');

      if (isSuccess) {
        final normalizedEndpoint = endpoint.split('?').first;
        if (normalizedEndpoint == '${ApiEndpoints.sales}/summary') {
          print('Returning raw body for sales/summary: $body');
          return Map<String, dynamic>.from(body); // Explicitly cast to Map<String, dynamic>
        }
        if (endpoint == ApiEndpoints.login || endpoint == ApiEndpoints.stafflogin) {
          return {
            'success': true,
            'data': {
              'token': body['token']?.toString() ?? '',
              'user': body['staff'] is Map ? Map<String, dynamic>.from(body['staff']) : (body['admin'] is Map ? Map<String, dynamic>.from(body['admin']) : {}),
              'cashierHourID': body['cashierHourID']?.toString() ?? '',
            },
          };
        }

        if (endpoint == '${ApiEndpoints.sales}/login') {
          return {
            'success': true,
            'staff': body['staff'] ?? {},
          };
        }
        // Return the original data structure for other endpoints
        return {
          'success': true,
          'data': body['data'] ?? {},
          'message': body['message']?.toString() ?? body['status']?.toString() ?? 'Success',
        };
      }
      // Fallback for non-success cases within 200-299 range
      return {
        'success': false,
        'message': body['message']?.toString() ?? body['error']?.toString() ?? 'Request processed but no success indicator',
      };
    } else {
      return {
        'success': false,
        'message': body['message']?.toString() ?? body['error']?.toString() ?? (body['errors'] is Map ? body['errors']['pinNumber']?.first?.toString() : null) ?? response.reasonPhrase ?? 'Request failed with status $statusCode',
      };
    }
  }

  Map<String, dynamic> _handleError(dynamic error) {
    print('Error: $error');
    if (error is http.ClientException) {
      return {
        'success': false,
        'message': 'Network error: Check your connection'
      };
    } else if (error is TimeoutException) {
      return {
        'success': false,
        'message': 'Request timed out'
      };
    }
    return {
      'success': false,
      'message': 'Unexpected error: $error'
    };
  }
}
