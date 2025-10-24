import 'package:json_annotation/json_annotation.dart';

part 'payment_method.g.dart';

@JsonSerializable()
class PaymentMethod {
  @JsonKey(name: 'paymentID')
  final int? paymentID;
  @JsonKey(name: 'paymentType')
  final String? paymentType;
  @JsonKey(name: 'status')
  final int? status;

  PaymentMethod({
    this.paymentID,
    this.paymentType,
    this.status,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) => _$PaymentMethodFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentMethodToJson(this);
}
