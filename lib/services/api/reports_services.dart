import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:quicserve_flutter/constants/api_endpoints.dart';
import 'package:quicserve_flutter/models/order_receipts.dart';
import 'package:quicserve_flutter/models/sales.dart';
import 'package:quicserve_flutter/services/api/base_api_service.dart';

class ReportsServices {
  final BaseApiService _apiService = BaseApiService();
  final _storage = const FlutterSecureStorage();

  Future<SalesSummary> fetchSalesSummary({required String date}) async {
    try {
      final companySlug = await _storage.read(key: 'company_slug');
      if (companySlug == null) {
        throw Exception('No company slug found. Please login first.');
      }

      final response = await _apiService.get('${ApiEndpoints.withCompany(companySlug, ApiEndpoints.sales)}/summary?selected_date=$date');
      print('Raw API response: $response');

      if (response['success'] == true) {
        // Prefer payload from 'data' if present, else fall back to top-level
        final Map<String, dynamic> payload = response['data'] is Map ? Map<String, dynamic>.from(response['data'] as Map) : Map<String, dynamic>.from(response as Map);

        // Normalize API keys and types to match model expectations
        final normalized = _normalizeSalesSummaryPayload(payload);
        print('Normalized SalesSummary payload: $normalized');
        return SalesSummary.fromJson(normalized);
      } else {
        throw Exception(response['message']?.toString() ?? 'Failed to load sales summary');
      }
    } catch (e) {
      throw Exception('Failed to load sales summary: $e');
    }
  }

  // --- Normalization helpers to align API keys with model expectations ---
  Map<String, dynamic> _normalizeSalesSummaryPayload(Map<String, dynamic> raw) {
    final result = <String, dynamic>{};

    // Pass through success if present
    if (raw.containsKey('success')) result['success'] = raw['success'];

    // Top-level fields
    result['selectedDate'] = (raw['selectedDate'] ?? raw['selected_date'])?.toString();
    result['salesID'] = _asInt(raw['salesID'] ?? raw['sales_id']);
    result['salesDate'] = (raw['salesDate'] ?? raw['sales_date'])?.toString();
    result['netSales'] = _asDouble(raw['netSales'] ?? raw['net_sales']);
    result['unpaidOrders'] = _asDouble(raw['unpaidOrders'] ?? raw['unpaid_orders']);

    // paymentMethodTotals
    final pmtRaw = raw['paymentMethodTotals'] ?? raw['payment_method_totals'];
    if (pmtRaw is List) {
      result['paymentMethodTotals'] = pmtRaw.whereType<Map>().map((e) => _normalizePaymentMethodTotal(Map<String, dynamic>.from(e))).toList();
    }

    // sales list
    final salesRaw = raw['sales'];
    if (salesRaw is List) {
      result['sales'] = salesRaw.whereType<Map>().map((e) => _normalizeSale(Map<String, dynamic>.from(e))).toList();
    }

    return result;
  }

  Map<String, dynamic> _normalizeSale(Map<String, dynamic> raw) {
    final out = <String, dynamic>{};
    out['salesID'] = _asInt(raw['salesID'] ?? raw['sales_id']);
    out['salesAmount'] = (raw['salesAmount'] ?? raw['sales_amount'])?.toString();
    out['salesDate'] = (raw['salesDate'] ?? raw['sales_date'])?.toString();
    out['orderID'] = (raw['orderID'] ?? raw['order_id'])?.toString();
    out['paymentID'] = _asInt(raw['paymentID'] ?? raw['payment_id']);
    out['created_at'] = raw['created_at'];
    out['updated_at'] = raw['updated_at'];

    final pm = raw['payment_method'];
    if (pm is Map) {
      out['payment_method'] = _normalizePaymentMethod(Map<String, dynamic>.from(pm as Map<Object?, Object?>));
    }
    return out;
  }

  Map<String, dynamic> _normalizePaymentMethodTotal(Map<String, dynamic> raw) {
    return <String, dynamic>{
      'paymentID': _asInt(raw['paymentID'] ?? raw['payment_id']),
      'totalAmount': _asDouble(raw['totalAmount'] ?? raw['total_amount']),
    };
  }

  Map<String, dynamic> _normalizePaymentMethod(Map<String, dynamic> raw) {
    return <String, dynamic>{
      'paymentID': _asInt(raw['paymentID'] ?? raw['payment_id']),
      'paymentType': (raw['paymentType'] ?? raw['payment_type'])?.toString(),
      'status': _asInt(raw['status']),
      'deleted_at': raw['deleted_at'],
    };
  }

  int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  double? _asDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  Future<Map<String, dynamic>> generateOrderReceipt(String orderID) async {
    try {
      final companySlug = await _storage.read(key: 'company_slug');
      if (companySlug == null) {
        throw Exception('No company slug found. Please login first.');
      }

      final endpoint = '${ApiEndpoints.withCompany(companySlug, ApiEndpoints.sales)}/order-receipts?orderID=$orderID';
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
      final companySlug = await _storage.read(key: 'company_slug');
      if (companySlug == null) {
        throw Exception('No company slug found. Please login first.');
      }

      final endpoint = '${ApiEndpoints.withCompany(companySlug, ApiEndpoints.sales)}/order-receipts/latest';
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
