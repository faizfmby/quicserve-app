import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quicserve_flutter/constants/custom_icon.dart';
import 'package:quicserve_flutter/constants/theme.dart';
import 'package:quicserve_flutter/models/menu_category.dart';
import 'package:quicserve_flutter/models/menu_item.dart';
import 'package:quicserve_flutter/models/order.dart';
import 'package:quicserve_flutter/models/order_item.dart';
import 'package:quicserve_flutter/screen/home/payment_screen.dart';
import 'package:quicserve_flutter/services/api/order_item_services.dart';
import 'package:quicserve_flutter/services/api/order_services.dart';
import 'package:quicserve_flutter/services/local/ticket_settings_storage.dart';
import 'package:quicserve_flutter/util/app_state.dart';
import 'package:quicserve_flutter/util/debounce.dart';
import 'package:quicserve_flutter/util/receipt_printer.dart';
import 'package:quicserve_flutter/widgets/alert_message.dart';
import 'package:quicserve_flutter/widgets/dialog/add_item_dialog.dart';
import 'package:quicserve_flutter/widgets/dialog/cancel_dialog.dart';
import 'package:quicserve_flutter/widgets/dialog/disable_box.dart';
import 'package:quicserve_flutter/widgets/dialog/edit_item_dialog.dart';
import 'package:quicserve_flutter/widgets/home_screen%20widget/section/menu_category_tabs.dart';
import 'package:quicserve_flutter/widgets/home_screen%20widget/section/menu_item_grid.dart';
import 'package:quicserve_flutter/services/api/menu_services.dart';
import 'package:quicserve_flutter/widgets/home_screen%20widget/section/order_section.dart';
//import 'package:quicserve_flutter/widgets/homescreen%20widget/order_item_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool isBlur = true;
  bool isLoading = false;
  bool isCreatingOrder = false;
  bool isDeletingOrder = false;
  bool isFOHEnabled = false;
  bool isBOHEnabled = false;
  List<String> selectedFOHCategories = [];
  List<String> selectedBOHCategories = [];

  String? _currentOrderId;
  int? _selectedCategoryIndex;

  double _subTotal = 0.0;
  double _total = 0.0;

  late Future<List<MenuCategory>> futureMenuCategories;
  Future<List<MenuItem>>? futureMenuItems;
  Future<List<OrderItem>>? futureOrderItems;
  Future<List<Order>>? futureOrderDetails;
  List<OrderItem> orderItems = [];
  List<MenuCategory> categories = [];
  List<MenuItem> item = [];
  List<Order> orderDetails = [];
  Map<String, MenuItem> itemMap = {};

  @override
  void initState() {
    super.initState();
    _loadTicketSettings();
    _loadOrderState();
    _loadOrderDetails();

    futureMenuCategories = MenuServices().fetchMenuCategory();
    futureMenuCategories.then((loadedCategories) {
      final validCategories = loadedCategories.where((c) => c.categoryID != null && c.categoryName != null && c.hide == 0).toList();
      if (validCategories.isNotEmpty) {
        setState(() {
          categories = validCategories;
          _selectedCategoryIndex = validCategories[0].categoryID;
          isLoading = true;
          futureMenuItems = MenuServices().fetchMenuItems(categoryID: _selectedCategoryIndex!).then((items) {
            final validItem = items.where((item) => item.itemID != null && item.itemName != null).toList();
            if (validItem.isNotEmpty) {
              setState(() {
                item = validItem;
                isLoading = false;
              });
            }
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

  Future<void> _refreshAllData() async {
    setState(() => isLoading = true);

    // Refresh categories
    futureMenuCategories = MenuServices().fetchMenuCategory();

    // Optionally refresh items if a category is selected
    if (_selectedCategoryIndex != null) {
      futureMenuItems = MenuServices().fetchMenuItems(categoryID: _selectedCategoryIndex!).then((items) => items.where((item) => item.itemID != null && item.itemName != null).toList());
    }

    // Optional: refresh order list, subtotal, etc.
    await Future.delayed(const Duration(milliseconds: 500)); // allow UI to show refresh animation

    setState(() => isLoading = false);
  }

  Future<void> _createOrder() async {
    if (isCreatingOrder) return;
    setState(() => isCreatingOrder = true);
    try {
      final response = await OrderServices().createOrder();

      final message = response['message']?.toString().toLowerCase() ?? '';
      final isLikelySuccessful = response['success'] == true || message.contains('success');
      final orderId = response['data'].toString();
      await _saveOrderState(orderId);
      if (isLikelySuccessful) {
        setState(() {
          isBlur = false;
          _currentOrderId = orderId;
          isCreatingOrder = false;
        });
        _loadOrderItems(orderId);
        _loadOrderDetails();
      } else {
        setState(() => isCreatingOrder = false);
        AlertMessage.showError(context, 'Failed to create order');
      }
    } catch (e) {
      setState(() => isCreatingOrder = false);
      AlertMessage.showError(context, 'Error: $e');
    }
  }

  Future<void> _saveOrder() async {
    try {
      final response = await OrderServices().saveOrder(orderID: _currentOrderId!);

      await SharedPreferences.getInstance()
        ..remove('order_id');

      final message = response['message']?.toString().toLowerCase() ?? '';
      if (message == 'order status is updated') {
        final newOrder = await OrderServices().fetchSelectedOrder(orderId: _currentOrderId!);

        final Map<String, MenuItem> tempItemMap = {};
        for (final order in newOrder) {
          for (final orderItem in order.orderItem ?? []) {
            final item = orderItem.item;
            final itemID = item?.itemID;
            if (item != null && itemID != null && itemID.isNotEmpty) {
              tempItemMap[itemID] = item;
            }
          }
        }

        setState(() {
          itemMap = tempItemMap;
          orderDetails = newOrder;
        });

        await printOrderTicket(
          isFOHEnabled: isFOHEnabled,
          isBOHEnabled: isBOHEnabled,
          selectedFOHCategories: selectedFOHCategories,
          selectedBOHCategories: selectedBOHCategories,
          context: context,
        );

        setState(() {
          _currentOrderId = null;
          orderItems = [];
          isBlur = true;
          _subTotal = 0.0;
          _total = 0.0;
        });

        AlertMessage.showSuccess(context, 'Order saved');
        AppState().setSelectedOrder(_currentOrderId);
        AppState().setStatusIndex(0);
      } else {
        throw Exception('Failed to save order: $message');
      }
    } catch (e) {
      AlertMessage.showError(context, 'Error saving order: $e');
    }
  }

  Future<void> _saveOrderState(String orderId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('order_id', orderId);
  }

  Future<void> _loadOrderState() async {
    final prefs = await SharedPreferences.getInstance();
    final savedOrderId = prefs.getString('order_id');

    if (savedOrderId != null) {
      setState(() {
        _currentOrderId = savedOrderId;
        isBlur = false;
      });
      _loadOrderItems(savedOrderId);
    }
  }

  Future<void> _loadOrderDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final orderID = prefs.getString('order_id');

      if (orderID != null) {
        print('Fetching order with orderID: $orderID');
        final order = await OrderServices().fetchSelectedOrder(orderId: orderID);
        print('Raw API response orders: $order');

        // Filter valid orders
        final validOrders = order.where((o) => o.orderID != null && o.orderTicket != null && o.orderStatus != null && o.totalAmount != null && o.date != null && o.time != null && (o.staff?.name != null || o.staff == null) && o.orderItem?.isNotEmpty == true && o.orderItem!.any((item) => (item.item?.imageUrl != null || item.item == null) && item.item?.itemID != null && item.item?.itemName != null && item.item?.categoryName != null && item.itemQuantity != null && item.item?.price != null)).toList();

        print('Valid orders after filtering: $validOrders');

        // Build itemMap
        final Map<String, MenuItem> tempItemMap = {};
        for (final order in validOrders) {
          for (final orderItem in order.orderItem ?? []) {
            final menuItem = orderItem.item;
            final itemID = menuItem?.itemID;
            if (menuItem != null && itemID != null && itemID.isNotEmpty) {
              tempItemMap[itemID] = menuItem;
            }
          }
        }

        setState(() {
          _currentOrderId = orderID;
          orderDetails = validOrders;
          itemMap = tempItemMap;
          isLoading = false;
          print(validOrders.isEmpty ? 'No valid orders' : 'Persisted OrderIndex: $orderID');
        });
      } else {
        setState(() {
          orderDetails = [];
          isLoading = false;
          print('No orderID found in SharedPreferences');
        });
      }
    } catch (e) {
      print('Error loading order details: $e');
      setState(() {
        orderDetails = [];
        AppState().setSelectedOrder(null);
        isLoading = false;
      });
    }
  }

  Future<void> _deleteOrder() async {
    if (_currentOrderId == null) return;
    if (isDeletingOrder) return; // 🛑 Prevent double call
    setState(() => isDeletingOrder = true);
    try {
      final response = await OrderServices().deleteOrder(_currentOrderId!);

      final message = response['message']?.toString().toLowerCase() ?? '';
      final isDeleteSuccessful = response['success'] == true || message.contains('success');
      await SharedPreferences.getInstance()
        ..remove('order_id');
      if (isDeleteSuccessful) {
        setState(() {
          isBlur = true;
          _currentOrderId = null;
          isDeletingOrder = false;
          orderItems = [];
          _subTotal = 0.0;
          _total = 0.0;
        });
      }
      //AlertMessage.showSuccess(context, 'Cancel order');
    } catch (e) {
      setState(() => isDeletingOrder = false);
      AlertMessage.showError(context, 'Error: $e');
    }
  }

  Future<void> _createOrderItem({
    required String itemID,
    required int quantity,
  }) async {
    if (_currentOrderId == null) return;

    try {
      final response = await OrderItemServices().createOrderItem(
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
    try {
      final items = await OrderItemServices().fetchOrderItem(orderId: orderId);
      //print('Fetched order items: $items'); // Debug fetched items
      setState(() {
        orderItems = items;
        // Calculate Sub Total and Total
        _subTotal = items.fold(0.0, (sum, item) => sum + ((item.item?.price ?? 0.0) * (item.itemQuantity ?? 0)));
        _total = _subTotal; // Tax is 0, so Total = Sub Total
        //print('Set state - orderItems: $orderItems, Sub Total: $_subTotal, Total: $_total'); // Debug state
      });
    } catch (e) {
      print('Error loading order items: $e');
      //AlertMessage.showError(context, 'Failed to load order item: $e');
    }
  }

  void showCancelOrderDialog(BuildContext context, String selectedOrderID) {
    print('Showing cancel dialog for order ID: $selectedOrderID');

    showDialog(
      context: context,
      builder: (context) => CancelDialog(
        selectedOrderID: selectedOrderID,
        onConfirm: (reason) async {
          print('Cancel reason received: $reason');
          try {
            print('Calling deleteOpenedOrder...');
            await OrderServices().cancelOrder(
              orderID: selectedOrderID,
              cancelReason: reason,
            );
            print('deleteOpenedOrder succeeded');

            setState(() {
              print('Updating UI state: isBlur=true, _currentOrderId=null, clearing orderItems');
              isBlur = true;
              _currentOrderId = null;
              orderItems = [];
            });

            print('Calling _deleteOrder()');
            await _deleteOrder();
            AlertMessage.showSuccess(context, 'Order cancel successfully');
            print('_deleteOrder() completed');
          } catch (e) {
            print('Failed to cancel order: $e');
            AlertMessage.showError(context, 'Failed to cancel order: $e');
          }
        },
      ),
    );
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

  Future<void> printOrderTicket({
    required bool isFOHEnabled,
    required bool isBOHEnabled,
    required List<String> selectedFOHCategories,
    required List<String> selectedBOHCategories,
    required BuildContext context,
  }) async {
    final printer = BlueThermalPrinter.instance;

    final isConnected = await printer.isConnected ?? false;
    if (!isConnected) {
      if (context.mounted) {
        AlertMessage.showError(context, 'Printer not connected. Please connect a printer');
      }
      return;
    }

    if (isFOHEnabled) {
      final fohItems = getOrderItems(
        orderItems: orderItems,
        isFOH: true,
        itemMap: itemMap,
        selectedFOHCategories: selectedFOHCategories,
        selectedBOHCategories: selectedBOHCategories,
      );

      print('itemMap keys: ${itemMap.keys}');

      if (fohItems.isNotEmpty) {
        await ReceiptPrinter.printTicket(
          printer: printer,
          orderDetails: orderDetails,
          orderID: _currentOrderId!,
          items: fohItems,
        );
        /* if (context.mounted) {
          AlertMessage.showSuccess(context, 'FOH Ticket Printed!');
        } */
      } /* else {
        if (context.mounted) {
          AlertMessage.showError(context, 'No FOH items to print.');
        }
      } */
    }

    if (isBOHEnabled) {
      final bohItems = getOrderItems(
        orderItems: orderItems,
        isFOH: false,
        itemMap: itemMap,
        selectedFOHCategories: selectedFOHCategories,
        selectedBOHCategories: selectedBOHCategories,
      );
      print('itemMap keys: ${itemMap.keys}');
      if (bohItems.isNotEmpty) {
        await ReceiptPrinter.printTicket(
          printer: printer,
          orderDetails: orderDetails,
          orderID: _currentOrderId!,
          items: bohItems,
        );
        /* if (context.mounted) {
          AlertMessage.showSuccess(context, 'BOH Ticket Printed!');
        } */
      } /* else {
        if (context.mounted) {
          AlertMessage.showError(context, 'No BOH items to print.');
        }
      } */
    }
  }

  List<OrderItem> getOrderItems({
    required List<OrderItem> orderItems,
    required bool isFOH,
    required Map<String, MenuItem> itemMap,
    required List<String> selectedFOHCategories,
    required List<String> selectedBOHCategories,
  }) {
    print('OrderItem IDs: ${orderItems.map((o) => o.item?.itemID).toList()}');
    final selectedCategories = isFOH ? selectedFOHCategories : selectedBOHCategories;

    final filteredItems = orderItems.where((orderItem) {
      final itemID = orderItem.item?.itemID;
      if (itemID == null) {
        print('[SKIP] Missing itemID');
        return false;
      }

      final menuItem = itemMap[itemID];
      if (menuItem == null) {
        print('[SKIP] itemID $itemID not found in itemMap');
        return false;
      }

      final categoryName = menuItem.categoryName;
      if (categoryName == null) {
        print('[SKIP] itemID $itemID has no categoryName');
        return false;
      }

      if (!selectedCategories.contains(categoryName)) {
        print('[SKIP] itemID $itemID category "$categoryName" not in selectedCategories');
        return false;
      }

      print('[PASS] itemID $itemID passed with category "$categoryName"');
      return true;
    }).toList();

    debugPrint(
      '[DEBUG] ${isFOH ? "FOH" : "BOH"} Items Fetched: '
      '${filteredItems.length} out of ${orderItems.length}',
    );

    return filteredItems;
  }

  void _loadTicketSettings() async {
    final fohEnabled = await TicketSettingsStorage.getFOHEnabled();
    final bohEnabled = await TicketSettingsStorage.getBOHEnabled();
    final fohCats = await TicketSettingsStorage.getFOHCategories();
    final bohCats = await TicketSettingsStorage.getBOHCategories();

    setState(() {
      isFOHEnabled = fohEnabled;
      isBOHEnabled = bohEnabled;
      selectedFOHCategories = fohCats;
      selectedBOHCategories = bohCats;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 14,
          child: RefreshIndicator(
            onRefresh: _refreshAllData,
            child: SizedBox(
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
                                        if (isBlur) {
                                          AlertMessage.showError(context, 'Please open order first!');
                                          return;
                                        }

                                        showDialog(
                                          context: context,
                                          barrierDismissible: true,
                                          barrierColor: Colors.black.withOpacity(0.3),
                                          builder: (context) => AddItemDialog(
                                            imageUrl: item.imageUrl ?? '',
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
          ),
        ),
        Expanded(
          flex: 5,
          child: OrderSection(
            orderItems: orderItems,
            currentOrderId: _currentOrderId,
            isBlur: isBlur,
            subTotal: _subTotal,
            total: _total,
            onCreateOrder: _createOrder,
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
            onCancelOrder: (orderId) {
              if (orderItems.isNotEmpty) {
                showCancelOrderDialog(context, orderId);
              } else {
                _deleteOrder();
              }
            },
            onSaveOrder: () => debounceAsync(action: _saveOrder),
            onPlaceOrder: () async {
              Navigator.of(context).push(
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => PaymentScreen1(
                    orderItems: orderItems,
                    currentOrderId: _currentOrderId,
                    subTotal: _subTotal,
                    total: _total,
                    isFOHEnabled: isFOHEnabled,
                    isBOHEnabled: isBOHEnabled,
                    selectedFOHCategories: selectedFOHCategories,
                    selectedBOHCategories: selectedBOHCategories,
                    orderDetails: orderDetails,
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
                const SizedBox(width: 130),
                if (orderId != null)
                  IconButton(
                    iconSize: 30,
                    icon: const Icon(
                      AppIcons.close,
                      color: AppColors.white,
                    ),
                    onPressed: () {
                      if (orderItems.isNotEmpty) {
                        showCancelOrderDialog(context, _currentOrderId!);
                      } else {
                        _deleteOrder();
                      }
                    },
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

  final TextEditingController _searchController = TextEditingController();

  Widget _search() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: const Color.fromARGB(255, 218, 218, 218),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search,
            color: Color.fromARGB(137, 43, 43, 43),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(
                color: Color.fromARGB(137, 29, 29, 29),
                fontSize: 11,
              ),
              decoration: const InputDecoration(
                hintText: 'Search menu here...',
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (value) {
                // You can filter your menu list here
                print("Search: $value");
              },
            ),
          ),
        ],
      ),
    );
  }
}
