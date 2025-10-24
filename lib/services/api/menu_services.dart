import 'package:quicserve_flutter/constants/api_endpoints.dart';
import 'package:quicserve_flutter/models/menu_category.dart';
import 'package:quicserve_flutter/models/menu_item.dart';
import 'package:quicserve_flutter/services/api/base_api_service.dart';

class MenuServices {
  final BaseApiService _apiService = BaseApiService();

  // Menu Category
  Future<List<MenuCategory>> fetchMenuCategory() async {
    try {
      final response = await _apiService.get(ApiEndpoints.menucategory);
      /* print('Fetch menu categories response: $response');
      print('Menu categories data: ${response['data']}'); */

      if (response['success'] == true) {
        final data = response['data'] as List<dynamic>? ?? [];
        return data.map((item) => MenuCategory.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        throw Exception(response['message']?.toString() ?? 'Failed to load menu categories');
      }
    } catch (e) {
      print('Error fetching menu categories: $e');
      throw Exception('Failed to load menu categories: $e');
    }
  }

  // Menu Item
  Future<List<MenuItem>> fetchMenuItems({required int categoryID}) async {
    try {
      final response = await _apiService.get('${ApiEndpoints.items}?categoryID=$categoryID');
      /* print('Fetch menu items response: $response');
      print('Menu items data: ${response['data']}'); */

      if (response['success'] == true) {
        final data = response['data'] as List<dynamic>? ?? [];
        return data.map((item) => MenuItem.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        throw Exception(response['message']?.toString() ?? 'Failed to load menu items');
      }
    } catch (e) {
      print('Error fetching menu items: $e');
      throw Exception('Failed to load menu items: $e');
    }
  }

  Future<void> updateItemDisable(String itemID, int disable) async {
    try {
      final response = await _apiService.put('${ApiEndpoints.items}/$itemID', {
        'disable': disable,
      });
      print('Update item disable response: $response');
      if (response['message'] != 'Success') {
        throw Exception(response['message']?.toString() ?? 'Failed to update item');
      }
    } catch (e) {
      print('Error updating item disable: $e');
      rethrow;
    }
  }
}
