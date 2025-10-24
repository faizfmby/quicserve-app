import 'package:quicserve_flutter/constants/api_endpoints.dart';
import 'package:quicserve_flutter/models/order_receipts.dart';
import 'package:quicserve_flutter/models/sales.dart';
import 'package:quicserve_flutter/services/api/base_api_service.dart';

class ReportsServices {
  final BaseApiService _apiService = BaseApiService();

  Future<SalesSummary> fetchSalesSummary({required String date}) async {
    try {
      final response = await _apiService.get('${ApiEndpoints.sales}/summary?selected_date=$date');
      print('Raw API response: $response');

      if (response['success'] == true) {
        return SalesSummary.fromJson(response as Map<String, dynamic>);
      } else {
        throw Exception(response['message']?.toString() ?? 'Failed to load sales summary');
      }
    } catch (e) {
      throw Exception('Failed to load sales summary: $e');
    }
  }

  Future<Map<String, dynamic>> generateOrderReceipt(String orderID) async {
    try {
      final endpoint = '${ApiEndpoints.sales}/order-receipts?orderID=$orderID';
      final response = await _apiService.post(endpoint, {});
      print('Generate new order receipt raw response: $response');
      return response;
    } catch (e) {
      print('Error generate order receipt: $e');
      rethrow;
    }
  }

  Future<OrderReceipts> fetchLatestReceipt() async {
    try {
      const endpoint = '${ApiEndpoints.sales}/order-receipts/latest';
      final response = await _apiService.get(endpoint);

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        return OrderReceipts.fromJson(data);
      } else {
        throw Exception(response['message'] ?? 'Failed to fetch receipt');
      }
    } catch (e) {
      throw Exception('Fetch latest receipt error: $e');
    }
  }
}
