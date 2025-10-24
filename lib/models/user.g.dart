// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: json['staffID'] as String?,
      name: json['staffName'] as String?,
      contact: json['contactInfo'] as String?,
      role: json['staffRole'] as String?,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'staffID': instance.id,
      'staffName': instance.name,
      'contactInfo': instance.contact,
      'staffRole': instance.role,
    };
