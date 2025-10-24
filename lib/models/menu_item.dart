import 'package:json_annotation/json_annotation.dart';

part 'menu_item.g.dart';

@JsonSerializable()
class MenuItem {
  @JsonKey(name: 'itemID')
  final String? itemID;
  @JsonKey(name: 'itemName')
  final String? itemName;
  @JsonKey(name: 'imageUrl')
  final String? imageUrl;
  @JsonKey(
    name: 'price',
    fromJson: _doubleFromJson,
    toJson: _doubleToJson,
  )
  final double? price;
  @JsonKey(name: 'categoryID')
  final int? categoryID;
  @JsonKey(name: 'categoryName')
  final String? categoryName;
  @JsonKey(name: 'disable')
  final int? disable;
  @JsonKey(name: 'hide')
  final int? hide;

  MenuItem({
    this.itemID,
    this.itemName,
    this.imageUrl,
    this.price,
    this.categoryID,
    this.categoryName,
    this.disable,
    this.hide,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) => _$MenuItemFromJson(json);
  Map<String, dynamic> toJson() => _$MenuItemToJson(this);

  /* factory MenuItem.fromJson(Map<String, dynamic> json) {
    return MenuItem(
      itemID: json['itemID'],
      itemName: json['itemName'],
      itemImage: json['itemImage'],
      price: double.parse(json['price']),
      categoryID: json['categoryID'],
      hide: json['hide'] == 1,
      image_url: json['image_url'],
    );
  } */
}

double? _doubleFromJson(dynamic value) {
  if (value == null) return null;
  try {
    return double.parse(value.toString());
  } catch (_) {
    return null;
  }
}

dynamic _doubleToJson(double? value) => value;
