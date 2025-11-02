// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cashier.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Cashier _$CashierFromJson(Map<String, dynamic> json) => Cashier(
      id: (json['id'] as num?)?.toInt(),
      staff: json['staff'] == null
          ? null
          : User.fromJson(json['staff'] as Map<String, dynamic>),
      staffID: json['staffID'] as String?,
      cashierSlug: json['cashierSlug'] as String?,
      pinNumber: json['pinNumber'] as String?,
    );

Map<String, dynamic> _$CashierToJson(Cashier instance) => <String, dynamic>{
      'id': instance.id,
      'staff': instance.staff,
      'staffID': instance.staffID,
      'cashierSlug': instance.cashierSlug,
      'pinNumber': instance.pinNumber,
    };
