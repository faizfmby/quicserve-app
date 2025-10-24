// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_method.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentMethod _$PaymentMethodFromJson(Map<String, dynamic> json) =>
    PaymentMethod(
      paymentID: (json['paymentID'] as num?)?.toInt(),
      paymentType: json['paymentType'] as String?,
      status: (json['status'] as num?)?.toInt(),
    );

Map<String, dynamic> _$PaymentMethodToJson(PaymentMethod instance) =>
    <String, dynamic>{
      'paymentID': instance.paymentID,
      'paymentType': instance.paymentType,
      'status': instance.status,
    };
