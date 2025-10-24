// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_receipts.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderReceipts _$OrderReceiptsFromJson(Map<String, dynamic> json) =>
    OrderReceipts(
      receiptID: json['receiptID'] as String?,
      dateTime: json['dateTime'] as String?,
      orderID: json['orderID'] as String?,
      order: json['order'] == null
          ? null
          : Order.fromJson(json['order'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$OrderReceiptsToJson(OrderReceipts instance) =>
    <String, dynamic>{
      'receiptID': instance.receiptID,
      'dateTime': instance.dateTime,
      'orderID': instance.orderID,
      'order': instance.order,
    };
