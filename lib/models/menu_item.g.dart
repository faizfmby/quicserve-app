// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'menu_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MenuItem _$MenuItemFromJson(Map<String, dynamic> json) => MenuItem(
      itemID: json['itemID'] as String?,
      itemName: json['itemName'] as String?,
      imageUrl: json['imageUrl'] as String?,
      price: _doubleFromJson(json['price']),
      categoryID: (json['categoryID'] as num?)?.toInt(),
      categoryName: json['categoryName'] as String?,
      disable: (json['disable'] as num?)?.toInt(),
      hide: (json['hide'] as num?)?.toInt(),
    );

Map<String, dynamic> _$MenuItemToJson(MenuItem instance) => <String, dynamic>{
      'itemID': instance.itemID,
      'itemName': instance.itemName,
      'imageUrl': instance.imageUrl,
      'price': _doubleToJson(instance.price),
      'categoryID': instance.categoryID,
      'categoryName': instance.categoryName,
      'disable': instance.disable,
      'hide': instance.hide,
    };
