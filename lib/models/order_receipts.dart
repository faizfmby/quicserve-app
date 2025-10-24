import 'package:json_annotation/json_annotation.dart';
import 'package:quicserve_flutter/models/order.dart';

part 'order_receipts.g.dart';

@JsonSerializable()
class OrderReceipts {
  @JsonKey(name: 'receiptID')
  final String? receiptID;
  @JsonKey(name: 'dateTime')
  final String? dateTime;
  @JsonKey(name: 'orderID')
  final String? orderID;
  @JsonKey(name: 'order')
  final Order? order;

  OrderReceipts({
    required this.receiptID,
    required this.dateTime,
    required this.orderID,
    required this.order,
  });

  factory OrderReceipts.fromJson(Map<String, dynamic> json) => _$OrderReceiptsFromJson(json);
  Map<String, dynamic> toJson() => _$OrderReceiptsToJson(this);
}
