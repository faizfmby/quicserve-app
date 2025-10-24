import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quicserve_flutter/constants/theme.dart';
import 'package:quicserve_flutter/models/menu_category.dart';
import 'package:quicserve_flutter/models/menu_item.dart';
import 'package:quicserve_flutter/models/order_item.dart';
import 'package:quicserve_flutter/screen/orders/payment_screen.dart';
import 'package:quicserve_flutter/widgets/order_screen%20widget/section/order_edit_section.dart';
import 'package:quicserve_flutter/services/api/order_item_services.dart';
import 'package:quicserve_flutter/services/api/order_services.dart';
import 'package:quicserve_flutter/widgets/alert_message.dart';
import 'package:quicserve_flutter/widgets/dialog/add_item_dialog.dart';
import 'package:quicserve_flutter/widgets/dialog/disable_box.dart';
import 'package:quicserve_flutter/widgets/dialog/edit_item_dialog.dart';
import 'package:quicserve_flutter/widgets/home_screen%20widget/section/menu_category_tabs.dart';
import 'package:quicserve_flutter/widgets/home_screen%20widget/section/menu_item_grid.dart';
import 'package:quicserve_flutter/services/api/menu_services.dart';
import 'package:quicserve_flutter/widgets/side_menu.dart';

class OrderEditScreen extends StatefulWidget {
  final String? selectedOrderIndex;
  final List<OrderItem>? orderItems;
  final double? totalAmount;

  const OrderEditScreen({
    super.key,
    required this.selectedOrderIndex,
    required this.orderItems,
    required this.totalAmount,
  });

  @override
  State<OrderEditScreen> createState() => _OrderEditScreenState();
}

class _OrderEditScreenState extends State<OrderEditScreen> with TickerProviderStateMixin {
  bool isLoading = false;
  bool isDeletingOrder = false;

  String? _currentOrderId;
  int? _selectedCategoryIndex;

  double _subTotal = 0.0;
  double _total = 0.0;

  late Future<List<MenuCategory>> futureMenuCategories;
  Future<List<MenuItem>>? futureMenuItems;
  Future<List<OrderItem>>? futureOrderItems;
  List<OrderItem> orderItems = [];
  List<MenuCategory> categories = [];

  @override
  void initState() {
    super.initState();

    _loadOrderItems(widget.selectedOrderIndex!);

    futureMenuCategories = MenuServices().fetchMenuCategory();
    futureMenuCategories.then((loadedCategories) {
      final validCategories = loadedCategories.where((c) => c.categoryID != null && c.categoryName != null && c.hide == 0).toList();
      if (validCategories.isNotEmpty) {
        setState(() {
          categories = validCategories;
          _selectedCategoryIndex = validCategories[0].categoryID;
          isLoading = true;
          futureMenuItems = MenuServices().fetchMenuItems(categoryID: _selectedCategoryIndex!).then((items) {
            setState(() => isLoading = false);
            return items.where((item) => item.itemID != null && item.itemName != null).toList();
          }).catchError((e) {
            print('Error fetching menu items: $e');
            setState(() => isLoading = false);
            return <MenuItem>[];
          });
        });
      } else {
        setState(() {
          categories = [];
          isLoading = false;
        });
      }
    }).catchError((e) {
      print('Error in initState: $e');
      setState(() => isLoading = false);
    });
  }

  Future<void> _saveOrder() async {
    try {
      final response = await OrderServices().saveOrder(orderID: _currentOrderId!);

      final message = response['message']?.toString().toLowerCase() ?? '';
      if (message == 'order status is updated') {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => const SideMenu2()), (Route<dynamic> route) => false);
        AlertMessage.showSuccess(context, 'Order saved');
      } else {
        throw Exception('Failed to save order: $message');
      }
    } catch (e) {
      AlertMessage.showError(context, 'Error saving order: $e');
    }
  }

  Future<void> _createOrderItem({
    required String itemID,
    required int quantity,
  }) async {
    _currentOrderId = widget.selectedOrderIndex!;
    if (_currentOrderId == null) return;

    try {
      final response = await OrderItemServices().addOrderItem(
        orderID: _currentOrderId!,
        itemID: itemID,
        itemQuantity: quantity,
      );

      if (response['success'] == true) {
        _loadOrderItems(_currentOrderId!);
      } else {
        AlertMessage.showError(context, 'Failed to add item!');
      }
    } catch (e) {
      AlertMessage.showError(context, 'Error adding item: $e');
    }
  }

  void _loadOrderItems(String orderId) async {
    _currentOrderId = widget.selectedOrderIndex!;
    try {
      final items = await OrderItemServices().fetchOrderItem(orderId: orderId);
      print('Fetched order items: $items'); // Debug fetched items
      setState(() {
        orderItems = items;
        // Calculate Sub Total and Total
        _subTotal = items.fold(0.0, (sum, item) => sum + ((item.item?.price ?? 0.0) * (item.itemQuantity ?? 0)));
        _total = _subTotal; // Tax is 0, so Total = Sub Total
        //print('Set state - orderItems: $orderItems, Sub Total: $_subTotal, Total: $_total'); // Debug state
      });
    } catch (e) {
      print('Error loading order items: $e');
      AlertMessage.showError(context, 'Failed to load order item: $e');
    }
  }

  void showDisableItemDialog(BuildContext context, MenuItem item, int? selectedCategoryIndex, VoidCallback refreshItems) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (context) {
        return DisableItemDialog(
          item: item,
          selectedCategoryIndex: selectedCategoryIndex,
          refreshItems: refreshItems,
        );
      },
    );
  }

  void showEditQuantityDialog(BuildContext context, OrderItem item) {
    showDialog(
      context: context,
      builder: (context) => EditItemDialog(
        imageUrl: item.item?.imageUrl ?? '',
        title: item.item?.itemName ?? '',
        price: item.item?.price ?? 0.0,
        initialQuantity: item.itemQuantity ?? 1,
        onUpdate: (newQty) async {
          await OrderItemServices().updateOrderItemQuantity(
            orderItemID: item.orderItemID!,
            newQuantity: newQty,
          );
          _loadOrderItems(_currentOrderId!);
        },
      ),
    );
  }

  void deleteAndRefresh(String orderItemID) async {
    try {
      final response = await OrderItemServices().deleteOrderItem(orderItemID: orderItemID);

      if (response['success'] == false) {
        _loadOrderItems(_currentOrderId!); // Refresh order items
        //print('Updated order items after deletion: $orderItems'); // Debug updated items
        //print('Updated summary - Sub Total: $_subTotal, Total: $_total');
        AlertMessage.showSuccess(context, 'Item removed successfully');
      } else {
        _loadOrderItems(_currentOrderId!);
        AlertMessage.showSuccess(context, 'Error ${response['success']}:${response['message'] ?? 'Unknown error'}');
      }
    } catch (e) {
      AlertMessage.showError(context, 'Error removing item: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true);
        return false;
      },
      child: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            Navigator.pop(context, true);
          }
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: Container(
                      height: double.infinity,
                      width: double.infinity,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.teal,
                              AppColors.blue.withOpacity(0.5),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.horizontal(right: Radius.circular(20))),
                      child: Icon(Icons.arrow_back_ios_new_rounded)),
                ),
              ),
              Expanded(
                flex: 14,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Column(
                    children: [
                      _topMenu(
                        title: 'Rumah Popia',
                        action: _search(),
                      ),
                      SizedBox(
                        height: 120,
                        child: MenuCategoryTabs(
                          futureMenuCategories: futureMenuCategories,
                          isLoading: isLoading,
                          selectedCategoryID: _selectedCategoryIndex, // Removed ! to allow null
                          onCategorySelected: (category) {
                            if (category.categoryID != null && category.hide == 0) {
                              setState(() {
                                _selectedCategoryIndex = category.categoryID;
                                isLoading = false;
                                futureMenuItems = MenuServices().fetchMenuItems(categoryID: _selectedCategoryIndex!).then((items) {
                                  setState(() => isLoading = false);
                                  return items.where((item) => item.itemID != null && item.itemName != null).toList();
                                }).catchError((e) {
                                  print('Error fetching menu items: $e');
                                  setState(() => isLoading = false);
                                  return <MenuItem>[];
                                });
                              });
                            }
                          },
                        ),
                      ),
                      Expanded(
                        child: futureMenuItems == null
                            ? const Center(child: Text('Select a category to load items.'))
                            : MenuItemGrid(
                                futureMenuItems: futureMenuItems!,
                                itemBuilder: (item) => GestureDetector(
                                  onTap: item.disable == 1
                                      ? null
                                      : () {
                                          showDialog(
                                            context: context,
                                            barrierDismissible: true,
                                            barrierColor: Colors.black.withOpacity(0.3),
                                            builder: (context) => AddItemDialog(
                                              imageUrl: item.imageUrl ?? 'https://via.placeholder.com/120',
                                              title: '${item.itemID ?? ''} ${item.itemName ?? ''}',
                                              price: item.price ?? 0.0,
                                              onAdd: (qty) => _createOrderItem(itemID: item.itemID!, quantity: qty),
                                            ),
                                          );
                                        }, // Empty onTap, disabled if disable == 1
                                  onLongPress: () {
                                    showDisableItemDialog(
                                      context,
                                      item,
                                      _selectedCategoryIndex,
                                      () {
                                        setState(() {
                                          futureMenuItems = MenuServices().fetchMenuItems(categoryID: _selectedCategoryIndex!).then((items) => items.where((item) => item.itemID != null && item.itemName != null).toList());
                                        });
                                      },
                                    );
                                  },
                                  child: _item(
                                    image: item.imageUrl ?? 'https://via.placeholder.com/120',
                                    title: '${item.itemID ?? ''} ${item.itemName ?? ''}',
                                    price: 'RM${(item.price ?? 0.0).toStringAsFixed(2)}',
                                    disable: item.disable, // Use disable instead of hide
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: OrderEditSection(
                  orderItems: orderItems,
                  currentOrderId: _currentOrderId,
                  subTotal: _subTotal,
                  total: _total,
                  onDeleteOrderItem: (orderItemID) async {
                    final removedItemIndex = orderItems.indexWhere((item) => item.orderItemID == orderItemID);
                    if (removedItemIndex != -1) {
                      final removedItem = orderItems[removedItemIndex];
                      orderItems.removeAt(removedItemIndex);
                      deleteAndRefresh(removedItem.orderItemID!);
                      setState(() {});
                    }
                  },
                  onEditOrderItem: (item) {
                    showEditQuantityDialog(context, item);
                  },
                  onSaveOrder: _saveOrder,
                  onPlaceOrder: () {
                    Navigator.of(context).push(
                      PageRouteBuilder(
                        pageBuilder: (_, __, ___) => PaymentScreen2(
                          orderItems: orderItems,
                          currentOrderId: _currentOrderId,
                          subTotal: _subTotal,
                          total: _total,
                        ),
                        transitionsBuilder: (_, animation, __, child) {
                          final tween = Tween(begin: const Offset(1.0, 0.0), end: Offset.zero).chain(CurveTween(curve: Curves.ease));
                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _itemOrder({
    required String image,
    required String title,
    required String qty,
    required String price,
  }) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.darkgrey1.withOpacity(0.9),
      ),
      child: Row(
        children: [
          Container(
            height: 70,
            width: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: NetworkImage(image.isEmpty ? 'https://via.placeholder.com/120' : image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: CustomFont.calibri16.copyWith(
                    fontSize: 14,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  price,
                  style: CustomFont.calibribold12.copyWith(
                    fontSize: 20,
                    color: AppColors.white,
                  ),
                )
              ],
            ),
          ),
          Text(
            'x $qty',
            style: CustomFont.calibribold12.copyWith(
              fontSize: 17,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _item({
    required String image,
    required String title,
    required String price,
    required int? disable,
  }) {
    final isDisable = disable == 1; // Check if hide == 1
    return Opacity(
      opacity: isDisable ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(right: 10, bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isDisable ? AppColors.lightgrey1.withOpacity(0.4) : AppColors.darkgrey3.withOpacity(0.5).withAlpha(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(image.isEmpty ? 'https://via.placeholder.com/120' : image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: CustomFont.calibri16.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.darkgrey1,
              ),
            ),
            const SizedBox(height: 0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  price,
                  style: CustomFont.calibribold24.copyWith(
                    color: AppColors.darkgrey1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _topMenu({
    required String title,
    required Widget action,
  }) {
    // Get current date and time
    final now = DateTime.now();
    final dateFormat = DateFormat('dd MMMM yyyy'); // e.g., 06 June 2025
    final timeFormat = DateFormat('HH:mm'); // e.g., 02:55
    final formattedDate = dateFormat.format(now);
    final formattedTime = timeFormat.format(now);

    return Padding(
      padding: const EdgeInsets.only(right: 30, top: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: CustomFont.daysone24.copyWith(
                  color: AppColors.darkgrey1,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    formattedDate,
                    style: CustomFont.daysone10.copyWith(
                      color: AppColors.lightgrey3,
                    ),
                  ),
                  const SizedBox(width: 60),
                  Text(
                    formattedTime,
                    style: CustomFont.daysone10.copyWith(
                      color: AppColors.lightgrey3,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(width: 50),
          Expanded(flex: 6, child: action),
        ],
      ),
    );
  }

  Widget _topOrder({
    required String title,
    required String? orderId,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: CustomFont.daysone32.copyWith(
                    fontSize: 30,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
            if (orderId != null) // ✅ Show only when order is created
              Text(
                'Order ID: $orderId',
                style: CustomFont.calibri16.copyWith(
                  color: AppColors.white.withOpacity(0.8),
                ),
              ),
          ],
        ),
        Expanded(flex: 1, child: Container(width: double.infinity)),
      ],
    );
  }

  Widget _search() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: Color.fromARGB(255, 218, 218, 218),
      ),
      child: Row(
        children: const [
          Icon(
            Icons.search,
            color: Color.fromARGB(137, 43, 43, 43),
          ),
          SizedBox(width: 10),
          Text(
            'Search menu here...',
            style: TextStyle(color: Color.fromARGB(137, 29, 29, 29), fontSize: 11),
          )
        ],
      ),
    );
  }
}
