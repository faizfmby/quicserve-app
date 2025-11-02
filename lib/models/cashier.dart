import 'package:json_annotation/json_annotation.dart';
import 'package:quicserve_flutter/models/user.dart';

part 'cashier.g.dart';

@JsonSerializable()
class Cashier {
  @JsonKey(name: 'id')
  final int? id;
  @JsonKey(name: 'staff')
  final User? staff;
  @JsonKey(name: 'staffID')
  final String? staffID;
  @JsonKey(name: 'cashierSlug')
  final String? cashierSlug;
  @JsonKey(name: 'pinNumber')
  final String? pinNumber;

  Cashier({
    this.id,
    this.staff,
    this.staffID,
    this.cashierSlug,
    this.pinNumber,
  });

  factory Cashier.fromJson(Map<String, dynamic> json) => _$CashierFromJson(json);
  Map<String, dynamic> toJson() => _$CashierToJson(this);
}
