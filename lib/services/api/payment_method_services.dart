import 'package:quicserve_flutter/constants/api_endpoints.dart';
import 'package:quicserve_flutter/models/payment_method.dart';
import 'package:quicserve_flutter/services/api/base_api_service.dart';

class PaymentMethodServices {
  final BaseApiService _apiService = BaseApiService();

  Future<List<PaymentMethod>> getPaymentMethod() async {
    try {
      final response = await _apiService.get(ApiEndpoints.paymentMethod);

      if (response['success'] == true) {
        final data = response['data'] as List<dynamic>? ?? [];
        return data.map((payment) => PaymentMethod.fromJson(payment as Map<String, dynamic>)).toList();
      } else {
        throw Exception(response['message']?.toString() ?? 'Failed to load payment');
      }
    } catch (e) {
      throw Exception('Failed to load payment: $e');
    }
  }
}
