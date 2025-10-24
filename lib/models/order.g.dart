// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Order _$OrderFromJson(Map<String, dynamic> json) => Order(
      orderID: json['orderID'] as String?,
      orderTicket: json['orderTicket'] as String?,
      date: json['date'] as String?,
      time: json['time'] as String?,
      orderStatus: json['orderStatus'] as String?,
      cancelReason: json['cancelReason'] as String?,
      totalAmount: _doubleFromJson(json['totalAmount']),
      staff: json['staff'] == null
          ? null
          : User.fromJson(json['staff'] as Map<String, dynamic>),
      paymentMethod: json['payment_method'] == null
          ? null
          : PaymentMethod.fromJson(
              json['payment_method'] as Map<String, dynamic>),
      sales: json['sales'] == null
          ? null
          : SalesSummary.fromJson(json['sales'] as Map<String, dynamic>),
      orderItem: (json['order_items'] as List<dynamic>?)
          ?.map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$OrderToJson(Order instance) => <String, dynamic>{
      'orderID': instance.orderID,
      'orderTicket': instance.orderTicket,
      'date': instance.date,
      'time': instance.time,
      'orderStatus': instance.orderStatus,
      'cancelReason': instance.cancelReason,
      'totalAmount': _doubleToJson(instance.totalAmount),
      'staff': instance.staff,
      'payment_method': instance.paymentMethod,
      'sales': instance.sales,
      'order_items': instance.orderItem,
    };
