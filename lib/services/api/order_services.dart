import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quicserve_flutter/constants/api_endpoints.dart';
import 'package:quicserve_flutter/models/order.dart';
import 'package:quicserve_flutter/services/api/base_api_service.dart';

class OrderServices {
  final BaseApiService _apiService = BaseApiService();
  final _storage = const FlutterSecureStorage();

  Future<Map<String, dynamic>> createOrder() async {
    try {
      final staffID = await _storage.read(key: 'staffID');
      if (staffID == null) {
        throw Exception('Staff ID not found in storage. Please log in again.');
      }
      final endpoint = '${ApiEndpoints.orders}/create?staffID=$staffID';
      final response = await _apiService.post(endpoint, {});
      print('Create order raw response: $response');
      return response;
    } catch (e) {
      print('Error creating order: $e');
      rethrow;
    }
  }

  Future<List<Order>> fetchOrderDetails() async {
    try {
      final response = await _apiService.get(ApiEndpoints.orders);

      if (response['success'] == true) {
        final data = response['data'] as List<dynamic>? ?? [];
        return data.map((order) => Order.fromJson(order as Map<String, dynamic>)).toList();
      } else {
        throw Exception(response['message']?.toString() ?? 'Failed to load order');
      }
    } catch (e) {
      throw Exception('Failed to load order: $e');
    }
  }

  Future<List<Order>> fetchSelectedOrder({required String orderId}) async {
    try {
      final response = await _apiService.get('${ApiEndpoints.orders}/$orderId');
      //print('Selected order details: ${jsonEncode(response)}');

      if (response['success'] == true) {
        final data = response['data'];
        if (data == null) {
          print('Warning: No data field for selected order in response: $response');
          return [];
        }
        if (data is! Map<String, dynamic>) {
          print('Error: Data is not an object: $data');
          throw Exception('Unexpected response format: Data is not an object');
        }
        try {
          final order = Order.fromJson(data);
          return [
            order
          ]; // Return as a single-item list
        } catch (e) {
          print('Error parsing order JSON: $data, Error: $e');
          return [];
        }
      } else {
        print('API reported failed: ${response['message'] ?? 'No message'}');
        throw Exception('Failed to load selected order: ${response['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Error fetching selected order: $e');
      throw Exception('Failed to load selected order: $e');
    }
  }

  Future<List<Order>> fetchOrderByStatus({required String orderStatus}) async {
    try {
      final response = await _apiService.get('${ApiEndpoints.orders}/status/$orderStatus');
      print('Raw API response before processing: ${jsonEncode(response)}');

      if (response['success'] == true) {
        // Changed from response['status'] == 'success'
        final data = response['data'];
        if (data == null) {
          print('Warning: No data field in response: $response');
          return [];
        }
        if (data is! List) {
          print('Error: Data is not a list: $data');
          throw Exception('Unexpected response format: Data is not a list');
        }
        final List<dynamic> orderList = data;
        return orderList
            .map((json) {
              try {
                if (json is! Map<String, dynamic>) {
                  print('Error: Invalid order JSON: $json');
                  return null;
                }
                return Order.fromJson(json);
              } catch (e) {
                print('Error parsing order JSON: $json, Error: $e');
                return null;
              }
            })
            .whereType<Order>()
            .toList();
      } else {
        print('API reported failure: ${response['message'] ?? 'No message'}');
        throw Exception('Failed to load order: ${response['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      print('Error fetching orders: $e');
      throw Exception('Failed to load order: $e');
    }
  }

  Future<Map<String, dynamic>> saveOrder({
    required String orderID,
  }) async {
    try {
      final response = await _apiService.post('${ApiEndpoints.orders}/$orderID/update', {});

      final message = response['message']?.toString().toLowerCase() ?? '';
      print('Payment response message: $message'); // Debug log

      // Accept "order marked as pending" as a success message
      if (message == 'order status is updated') {
        return response; // Return the response on success
      } else {
        throw Exception(response['message']?.toString() ?? 'Failed to save order');
      }
    } catch (e) {
      print('Error on saving order: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> paidOrder({
    required String orderID,
    required int paymentID,
  }) async {
    try {
      final response = await _apiService.put(
        '${ApiEndpoints.orders}/$orderID/paid',
        {
          'paymentID': paymentID,
        },
      );

      final message = response['message']?.toString().toLowerCase() ?? '';
      print('Payment response message: $message'); // Debug log

      // Accept "order marked as paid" as a success message
      if (message == 'order marked as paid' || message == 'success') {
        return response; // Return the response on success
      } else {
        throw Exception(response['message']?.toString() ?? 'Failed to make payment');
      }
    } catch (e) {
      print('Error making payment: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteOrder(String orderID) async {
    try {
      final response = await _apiService.delete('${ApiEndpoints.orders}/$orderID/delete');
      print('Delete order response: $response');
      return response;
    } catch (e) {
      print('Error deleting order: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> cancelOrder({
    required String orderID,
    required String cancelReason,
  }) async {
    try {
      final response = await _apiService.put(
        '${ApiEndpoints.orders}/$orderID/cancel',
        {
          'cancelReason': cancelReason
        },
      );

      print('Cancel reason for this order: $response');

      final message = response['message']?.toString().toLowerCase() ?? '';
      if (message != 'success' && message != 'order canceled') {
        throw Exception(response['message']?.toString() ?? 'Failed to delete opened order');
      }

      return response; // Return the response so the caller can check it
    } catch (e) {
      print('Error deleting opened order: $e');
      rethrow;
    }
  }
}
