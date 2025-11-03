import 'package:json_annotation/json_annotation.dart';

part 'recommendation.g.dart';

@JsonSerializable()
class Recommendation {
  @JsonKey(name: 'antecedents')
  final List<String>? antecedents;
  @JsonKey(name: 'recommendation')
  final String? recommendation;
  @JsonKey(name: 'confidence')
  final String? confidence;

  Recommendation({
    this.antecedents,
    this.recommendation,
    this.confidence,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) =>
      _$RecommendationFromJson(json);
  Map<String, dynamic> toJson() => _$RecommendationToJson(this);
}
