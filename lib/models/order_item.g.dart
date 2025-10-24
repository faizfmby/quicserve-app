// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderItem _$OrderItemFromJson(Map<String, dynamic> json) => OrderItem(
      orderItemID: json['orderItemID'] as String?,
      itemQuantity: (json['itemQuantity'] as num?)?.toInt(),
      subTotal: _doubleFromJson(json['subTotal']),
      item: json['item'] == null
          ? null
          : MenuItem.fromJson(json['item'] as Map<String, dynamic>),
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$OrderItemToJson(OrderItem instance) => <String, dynamic>{
      'orderItemID': instance.orderItemID,
      'itemQuantity': instance.itemQuantity,
      'subTotal': _doubleToJson(instance.subTotal),
      'item': instance.item,
      'created_at': instance.createdAt,
    };
