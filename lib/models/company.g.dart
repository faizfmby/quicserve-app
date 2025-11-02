// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'company.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Company _$CompanyFromJson(Map<String, dynamic> json) => Company(
      companyId: (json['company_id'] as num?)?.toInt(),
      companyName: json['company_name'] as String?,
      companySlug: json['company_slug'] as String?,
    );

Map<String, dynamic> _$CompanyToJson(Company instance) => <String, dynamic>{
      'company_id': instance.companyId,
      'company_name': instance.companyName,
      'company_slug': instance.companySlug,
    };
