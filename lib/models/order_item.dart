import 'package:json_annotation/json_annotation.dart';
import 'package:quicserve_flutter/models/menu_item.dart';

part 'order_item.g.dart';

@JsonSerializable()
class OrderItem {
  @JsonKey(name: 'orderItemID')
  final String? orderItemID;
  @JsonKey(name: 'itemQuantity')
  final int? itemQuantity;
  @JsonKey(
    name: 'subTotal',
    fromJson: _doubleFromJson,
    toJson: _doubleToJson,
  )
  final double? subTotal;
  @JsonKey(name: 'item')
  final MenuItem? item;
  @JsonKey(name: 'created_at')
  final String? createdAt;

  OrderItem({
    this.orderItemID,
    this.itemQuantity,
    this.subTotal,
    this.item,
    this.createdAt,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);
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
