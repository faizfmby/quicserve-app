import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  @JsonKey(name: 'staffID')
  final String? id;
  @JsonKey(name: 'staffName')
  final String? name;
  @JsonKey(name: 'contactInfo')
  final String? contact;
  @JsonKey(name: 'staffRole')
  final String? role;

  User({required this.id, required this.name, required this.contact, required this.role});

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
