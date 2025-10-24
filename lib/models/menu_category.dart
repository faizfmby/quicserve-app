import 'package:json_annotation/json_annotation.dart';

part 'menu_category.g.dart';

@JsonSerializable()
class MenuCategory {
  @JsonKey(name: 'categoryID')
  final int? categoryID;
  @JsonKey(name: 'categoryName')
  final String? categoryName;
  @JsonKey(name: 'hide')
  final int? hide; // Changed to int? to match backend
  @JsonKey(name: 'created_at')
  final String? createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;

  MenuCategory({
    this.categoryID,
    this.categoryName,
    this.hide,
    this.createdAt,
    this.updatedAt,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) => _$MenuCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$MenuCategoryToJson(this);

  /* factory MenuCategory.fromJson(Map<String, dynamic> json) {
    return MenuCategory(
      categoryID: json['categoryID'] as int?,
      categoryName: json['categoryName'] as String?,
      hide: json['hide'] == 1 as bool?,
    );
  } */

  /*  Map<String, dynamic> toJson() {
    return {
      'id': categoryID,
      'name': categoryName,
      'hide': hide,
    };
  } */
}
