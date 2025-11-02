//import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quicserve_flutter/constants/api_endpoints.dart';
import 'package:quicserve_flutter/models/order_item.dart';
import 'package:quicserve_flutter/services/api/base_api_service.dart';

class OrderItemServices {
  final BaseApiService _apiService = BaseApiService();
  final _storage = const FlutterSecureStorage();
  
  Future<String?> getCompanySlug() async {
    return await _storage.read(key: 'company_slug');
  }

  Future<Map<String, dynamic>> createOrderItem({
    required String orderID,
    required String itemID,
    required int itemQuantity,
  }) async {
    try {
      final companySlug = await getCompanySlug();
      if (companySlug == null) {
        throw Exception('No company slug found. Please login first.');
      }

      final response = await _apiService.post(
        ApiEndpoints.withCompany(companySlug, ApiEndpoints.orderItems),
        {
          'orderID': orderID,
          'itemID': itemID,
          'itemQuantity': itemQuantity,
        },
      );
      //print('Create order item raw response: $response');
      return response;
    } catch (e) {
      print('Error creating order item: $e');
      rethrow;
    }
  }

  Future<List<OrderItem>> fetchOrderItem({required String orderId}) async {
    try {
      final companySlug = await getCompanySlug();
      if (companySlug == null) {
        throw Exception('No company slug found. Please login first.');
      }
      
      final response = await _apiService.get('${ApiEndpoints.withCompany(companySlug, ApiEndpoints.orderItems)}/$orderId');

      if (response['success'] == true) {
        final data = response['data'] as Map<String, dynamic>;
        final items = data['order_items'] as List<dynamic>? ?? [];
        final parsedItems = items.map((item) => OrderItem.fromJson(item as Map<String, dynamic>)).toList();

        parsedItems.sort((a, b) {
          final aTime = DateTime.tryParse(a.createdAt ?? '') ?? DateTime.now();
          final bTime = DateTime.tryParse(b.createdAt ?? '') ?? DateTime.now();
          return aTime.compareTo(bTime); // ascending order
        });

        //print('Parsed Items: ${items.length}');

        return parsedItems;
      } else {
        throw Exception(response['message']?.toString() ?? 'Failed to load order items');
      }
    } catch (e) {
      print('Error fetching order items: $e');
      throw Exception('Failed to load order items: $e');
    }
  }

  Future<Map<String, dynamic>> updateOrderItemQuantity({
    required String orderItemID,
    required int newQuantity,
  }) async {
    try {
      final companySlug = await getCompanySlug();
      if (companySlug == null) {
        throw Exception('No company slug found. Please login first.');
      }
      
      final response = await _apiService.put(
        '${ApiEndpoints.withCompany(companySlug, ApiEndpoints.orderItems)}/$orderItemID/update',
        {
          'itemQuantity': newQuantity
        },
      );
      return response;
    } catch (e) {
      print('Error updating order item: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> deleteOrderItem({required String orderItemID}) async {
    try {
      final companySlug = await getCompanySlug();
      if (companySlug == null) {
        throw Exception('No company slug found. Please login first.');
      }

      final response = await _apiService.delete('${ApiEndpoints.withCompany(companySlug, ApiEndpoints.orderItems)}/$orderItemID/delete');
      return response;
    } catch (e) {
      print('Error deleting order item: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> addOrderItem({
    required String orderID,
    required String itemID,
    required int itemQuantity,
  }) async {
    try {
      final companySlug = await getCompanySlug();
      if (companySlug == null) {
        throw Exception('No company slug found. Please login first.');
      }

      final response = await _apiService.post(
        '${ApiEndpoints.withCompany(companySlug, ApiEndpoints.orderItems)}/$orderID/add',
        {
          'itemID': itemID,
          'itemQuantity': itemQuantity,
        },
      );
      //print('Create order item raw response: $response');
      return response;
    } catch (e) {
      print('Error creating order item: $e');
      rethrow;
    }
  }
}
