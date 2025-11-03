// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Recommendation _$RecommendationFromJson(Map<String, dynamic> json) =>
    Recommendation(
      antecedents: (json['antecedents'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      recommendation: json['recommendation'] as String?,
      confidence: json['confidence'] as String?,
    );

Map<String, dynamic> _$RecommendationToJson(Recommendation instance) =>
    <String, dynamic>{
      'antecedents': instance.antecedents,
      'recommendation': instance.recommendation,
      'confidence': instance.confidence,
    };
