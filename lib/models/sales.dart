import 'package:json_annotation/json_annotation.dart';
import 'package:intl/intl.dart';

part 'sales.g.dart';

@JsonSerializable(explicitToJson: true)
class SalesSummary {
  @JsonKey(name: 'success')
  final bool? success;
  @JsonKey(name: 'selectedDate')
  @DateTimeConverter()
  final DateTime? selectedDate;
  @JsonKey(name: 'salesID')
  final int? salesID;
  @JsonKey(name: 'salesDate')
  final String? salesDate;
  @JsonKey(name: 'sales')
  final List<Sale>? sales;
  @JsonKey(name: 'netSales')
  final double? netSales;
  @JsonKey(name: 'paymentMethodTotals')
  final List<PaymentMethodTotal>? paymentMethodTotals;
  @JsonKey(name: 'unpaidOrders')
  final double? unpaidOrders;

  SalesSummary({
    this.success,
    this.selectedDate,
    this.salesID,
    this.salesDate,
    this.sales,
    this.netSales,
    this.paymentMethodTotals,
    this.unpaidOrders,
  });

  factory SalesSummary.fromJson(Map<String, dynamic> json) {
    print('Deserializing SalesSummary: $json');
    final result = _$SalesSummaryFromJson(json);
    print('Deserialized SalesSummary: ${result.toJson()}');
    return result;
  }

  Map<String, dynamic> toJson() => _$SalesSummaryToJson(this);
}

@JsonSerializable(explicitToJson: true)
class Sale {
  @JsonKey(name: 'salesID')
  final int? salesID;
  @JsonKey(name: 'salesAmount')
  final String? salesAmount;
  @JsonKey(name: 'salesDate')
  final String? salesDate;
  @JsonKey(name: 'orderID')
  final String? orderID;
  @JsonKey(name: 'paymentID')
  final int? paymentID;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  @JsonKey(name: 'payment_method')
  final PaymentMethod? paymentMethod;

  Sale({
    this.salesID,
    this.salesAmount,
    this.salesDate,
    this.orderID,
    this.paymentID,
    this.createdAt,
    this.updatedAt,
    this.paymentMethod,
  });

  factory Sale.fromJson(Map<String, dynamic> json) => _$SaleFromJson(json);
  Map<String, dynamic> toJson() => _$SaleToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PaymentMethodTotal {
  @JsonKey(name: 'paymentID')
  final int? paymentID;
  @JsonKey(name: 'totalAmount')
  final double? totalAmount;

  PaymentMethodTotal({
    this.paymentID,
    this.totalAmount,
  });

  factory PaymentMethodTotal.fromJson(Map<String, dynamic> json) => _$PaymentMethodTotalFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentMethodTotalToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PaymentMethod {
  @JsonKey(name: 'paymentID')
  final int? paymentID;
  @JsonKey(name: 'paymentType')
  final String? paymentType;
  @JsonKey(name: 'status')
  final int? status;
  @JsonKey(name: 'deleted_at')
  final String? deletedAt;

  PaymentMethod({
    this.paymentID,
    this.paymentType,
    this.status,
    this.deletedAt,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => _$PaymentMethodFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentMethodToJson(this);
}

class DateTimeConverter implements JsonConverter<DateTime?, String?> {
  const DateTimeConverter();

  static final _jsonFormat = DateFormat('yyyy-MM-dd');

  @override
  DateTime? fromJson(String? json) {
    if (json == null) return null;
    try {
      return _jsonFormat.parse(json);
    } catch (e) {
      print('Error parsing date: $json, error: $e');
      return null;
    }
  }

  @override
  String? toJson(DateTime? dateTime) {
    if (dateTime == null) return null;
    return _jsonFormat.format(dateTime);
  }

  String? toUiString(DateTime? dateTime) {
    if (dateTime == null) return null;
    return DateFormat('dd MMM, yyyy').format(dateTime);
  }
}
