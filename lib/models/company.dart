import 'package:json_annotation/json_annotation.dart';

part 'company.g.dart';

@JsonSerializable()
class Company {
  @JsonKey(name: 'company_id')
  final int? companyId;
  @JsonKey(name: 'company_name')
  final String? companyName;
  @JsonKey(name: 'company_slug')
  final String? companySlug;

  Company({
    required this.companyId,
    required this.companyName,
    required this.companySlug,
  });

  factory Company.fromJson(Map<String, dynamic> json) => _$CompanyFromJson(json);
  Map<String, dynamic> toJson() => _$CompanyToJson(this);
}