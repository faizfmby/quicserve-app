import 'package:json_annotation/json_annotation.dart';
import 'package:quicserve_flutter/models/order_item.dart';
import 'package:quicserve_flutter/models/payment_method.dart';
import 'package:quicserve_flutter/models/sales.dart' hide PaymentMethod;
import 'package:quicserve_flutter/models/user.dart';

part 'order.g.dart';

@JsonSerializable()
class Order {
  @JsonKey(name: 'orderID')
  final String? orderID;
  @JsonKey(name: 'orderTicket')
  final String? orderTicket;
  @JsonKey(name: 'date')
  final String? date;
  @JsonKey(name: 'time')
  final String? time;
  @JsonKey(name: 'orderStatus')
  final String? orderStatus;
  @JsonKey(name: 'cancelReason')
  final String? cancelReason;
  @JsonKey(
    name: 'totalAmount',
    fromJson: _doubleFromJson,
    toJson: _doubleToJson,
  )
  final double? totalAmount;
  @JsonKey(name: 'staff')
  final User? staff;
  @JsonKey(name: 'payment_method')
  final PaymentMethod? paymentMethod;
  @JsonKey(name: 'sales')
  final SalesSummary? sales;
  @JsonKey(name: 'order_items')
  final List<OrderItem>? orderItem;

  Order({
    this.orderID,
    this.orderTicket,
    this.date,
    this.time,
    this.orderStatus,
    this.cancelReason,
    this.totalAmount,
    this.staff,
    this.paymentMethod,
    this.sales,
    this.orderItem,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  Map<String, dynamic> toJson() => _$OrderToJson(this);
}

double? _doubleFromJson(dynamic value) {
  if (value == null) return null;
  try {
    return double.parse(value.toString());
  } catch (_) {
    return null;
  }
}

dynamic _doubleToJson(double? value) => value;
