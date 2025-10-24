// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SalesSummary _$SalesSummaryFromJson(Map<String, dynamic> json) => SalesSummary(
      success: json['success'] as bool?,
      selectedDate:
          const DateTimeConverter().fromJson(json['selectedDate'] as String?),
      salesID: (json['salesID'] as num?)?.toInt(),
      salesDate: json['salesDate'] as String?,
      sales: (json['sales'] as List<dynamic>?)
          ?.map((e) => Sale.fromJson(e as Map<String, dynamic>))
          .toList(),
      netSales: (json['netSales'] as num?)?.toDouble(),
      paymentMethodTotals: (json['paymentMethodTotals'] as List<dynamic>?)
          ?.map((e) => PaymentMethodTotal.fromJson(e as Map<String, dynamic>))
          .toList(),
      unpaidOrders: (json['unpaidOrders'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$SalesSummaryToJson(SalesSummary instance) =>
    <String, dynamic>{
      'success': instance.success,
      'selectedDate': const DateTimeConverter().toJson(instance.selectedDate),
      'salesID': instance.salesID,
      'salesDate': instance.salesDate,
      'sales': instance.sales?.map((e) => e.toJson()).toList(),
      'netSales': instance.netSales,
      'paymentMethodTotals':
          instance.paymentMethodTotals?.map((e) => e.toJson()).toList(),
      'unpaidOrders': instance.unpaidOrders,
    };

Sale _$SaleFromJson(Map<String, dynamic> json) => Sale(
      salesID: (json['salesID'] as num?)?.toInt(),
      salesAmount: json['salesAmount'] as String?,
      salesDate: json['salesDate'] as String?,
      orderID: json['orderID'] as String?,
      paymentID: (json['paymentID'] as num?)?.toInt(),
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      paymentMethod: json['payment_method'] == null
          ? null
          : PaymentMethod.fromJson(
              json['payment_method'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SaleToJson(Sale instance) => <String, dynamic>{
      'salesID': instance.salesID,
      'salesAmount': instance.salesAmount,
      'salesDate': instance.salesDate,
      'orderID': instance.orderID,
      'paymentID': instance.paymentID,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
      'payment_method': instance.paymentMethod?.toJson(),
    };

PaymentMethodTotal _$PaymentMethodTotalFromJson(Map<String, dynamic> json) =>
    PaymentMethodTotal(
      paymentID: (json['paymentID'] as num?)?.toInt(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$PaymentMethodTotalToJson(PaymentMethodTotal instance) =>
    <String, dynamic>{
      'paymentID': instance.paymentID,
      'totalAmount': instance.totalAmount,
    };

PaymentMethod _$PaymentMethodFromJson(Map<String, dynamic> json) =>
    PaymentMethod(
      paymentID: (json['paymentID'] as num?)?.toInt(),
      paymentType: json['paymentType'] as String?,
      status: (json['status'] as num?)?.toInt(),
      deletedAt: json['deleted_at'] as String?,
    );

Map<String, dynamic> _$PaymentMethodToJson(PaymentMethod instance) =>
    <String, dynamic>{
      'paymentID': instance.paymentID,
      'paymentType': instance.paymentType,
      'status': instance.status,
      'deleted_at': instance.deletedAt,
    };
