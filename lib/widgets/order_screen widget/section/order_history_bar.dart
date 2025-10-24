import 'package:flutter/material.dart';
import 'package:quicserve_flutter/constants/theme.dart';
import 'package:quicserve_flutter/models/order.dart';
import 'package:quicserve_flutter/screen/orders/order_detail_screen.dart';
import 'package:quicserve_flutter/screen/orders/order_edit_screen.dart';
import 'package:quicserve_flutter/services/api/order_services.dart';
import 'package:quicserve_flutter/util/app_state.dart';
import 'package:quicserve_flutter/widgets/alert_message.dart';
import 'package:quicserve_flutter/widgets/dialog/cancel_dialog.dart';
import 'package:quicserve_flutter/widgets/order_screen%20widget/control_button.dart';
import 'package:quicserve_flutter/widgets/order_screen%20widget/section/order_list_tabs.dart';

class OrderHistory extends StatefulWidget {
  const OrderHistory({
    super.key,
  });

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  bool isLoading = false;
  String? _selectedOrderIndex;
  Future<List<Order>>? futureOrderList;
  List<Order> orderDetails = [];
  List<Order> orderItems = [];
  int statusIndex = 0;
  final GlobalKey<OrderListTabsState> _orderListKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    statusIndex = AppState().getStatusIndex() ?? 0; // Default to 0 if null
    _selectedOrderIndex = AppState().getSelectedOrder();
    _loadOrderList().then((_) {
      // Wait for the frame to render, then scroll
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _orderListKey.currentState?.scrollToSelected();
      });
    });
    //_initializeStatusAndLoadOrders();
  }

  Future<void> _loadOrderList() async {
    setState(() => isLoading = true);
    try {
      final status = _getStatusFromToggle(statusIndex);
      futureOrderList = OrderServices().fetchOrderByStatus(orderStatus: status);
      final loadedOrders = await futureOrderList!;
      final validOrders = loadedOrders.where((o) => o.orderTicket != null && o.totalAmount != null && o.date != null && o.time != null).toList();
      if (validOrders.isNotEmpty) {
        setState(() {
          orderItems = validOrders;
          if (_selectedOrderIndex == null || !validOrders.any((o) => o.orderID == _selectedOrderIndex)) {
            _selectedOrderIndex = _selectedOrderIndex;
            AppState().setSelectedOrder(_selectedOrderIndex);
          }
          isLoading = false;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _orderListKey.currentState?.scrollToSelected();
        });
      } else {
        setState(() {
          orderItems = [];
          _selectedOrderIndex = null;
          AppState().setSelectedOrder(null);
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading order list: $e');
      setState(() {
        orderItems = [];
        _selectedOrderIndex = null;
        AppState().setSelectedOrder(null);
        isLoading = false;
      });
    }
  }

  int _getIndexFromStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return 0;
      case 'completed':
        return 1;
      case 'cancelled':
        return 2;
      default:
        return 0; // default to pending
    }
  }

  String _getStatusFromToggle(int index) {
    const statuses = [
      'pending',
      'completed',
      'cancelled'
    ];
    final status = statuses[index % statuses.length];
    print('Status selected: $status (index: $index)'); // Log status change
    return status;
  }

  Future<void> onEditOrder() async {
    try {
      futureOrderList = OrderServices().fetchSelectedOrder(orderId: _selectedOrderIndex!);
      final editOrders = await futureOrderList!;
      final validEditOrders = editOrders.where((o) => o.orderID != null && o.orderTicket != null && o.orderStatus != null && o.totalAmount != null && o.date != null && o.time != null && (o.staff?.name != null || o.staff == null) && o.orderItem?.isNotEmpty == true && o.orderItem!.any((item) => (item.item?.imageUrl != null || item.item == null) && item.item?.itemID != null && item.item?.itemName != null && item.itemQuantity != null && (item.item?.price != null))).toList();
      setState(() {
        orderDetails = validEditOrders;
      });

      if (validEditOrders.isNotEmpty) {
        final order = validEditOrders.first;

        final shouldRefresh = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (context) => OrderEditScreen(
              selectedOrderIndex: order.orderID,
              orderItems: order.orderItem,
              totalAmount: order.totalAmount,
            ),
          ),
        );

        if (shouldRefresh == true) {
          _loadOrderList();
        }
      } else {
        AlertMessage.showError(context, 'No valid order to edit');

        _loadOrderList();
      }
    } catch (e) {
      print('Error edit order: $e');
      AlertMessage.showError(context, 'Failed to edit order: $e');
    }
  }

  void showCancelOrderDialog(BuildContext context, String selectedOrderID) {
    print('Showing cancel dialog for order ID: $selectedOrderID');

    showDialog(
      context: context,
      builder: (context) => CancelDialog(
          selectedOrderID: _selectedOrderIndex!,
          onConfirm: (reason) async {
            print('Cancel reason received: $reason');
            try {
              print('Calling cancelOrder...');
              await OrderServices().cancelOrder(
                orderID: selectedOrderID,
                cancelReason: reason,
              );
              print('Order cancel succeeded');

              // Step 1: Switch to cancelled tab & clear selection
              setState(() {
                statusIndex = 2;
                _selectedOrderIndex = null;
              });

              // Step 2: Load the cancelled list
              await _loadOrderList();

              // Step 3: Restore selection after loading
              final selectedOrder = orderItems.firstWhere(
                (order) => order.orderID == selectedOrderID,
                orElse: () => Order(), // make sure to handle this edge case
              );

              if (selectedOrder.orderID != null) {
                _handleOrderSelection(selectedOrder);
              }

              AlertMessage.showSuccess(context, 'Order cancelled successfully');
              print('Order cancellation and UI update completed');
            } catch (e) {
              print('Failed to cancel order: $e');
              AlertMessage.showError(context, 'Failed to cancel order: $e');
            }
          }),
    );
  }

  void _handleOrderSelection(Order order) {
    setState(() {
      _selectedOrderIndex = order.orderID;
      AppState().setSelectedOrder(_selectedOrderIndex);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _orderListKey.currentState?.scrollToSelected();
    });
  }

  Future<void> _initializeStatusAndLoadOrders() async {
    if (_selectedOrderIndex != null) {
      try {
        final selectedOrder = await OrderServices().fetchSelectedOrder(orderId: _selectedOrderIndex!);
        if (selectedOrder.isNotEmpty) {
          final status = selectedOrder.first.orderStatus?.toLowerCase();

          // Map order status to statusIndex
          int? newIndex;
          if (status == 'pending')
            newIndex = 0;
          else if (status == 'completed')
            newIndex = 1;
          else if (status == 'cancelled') newIndex = 2;

          if (newIndex != null) {
            setState(() {
              statusIndex = newIndex!;
            });
          }
        }
      } catch (e) {
        print('Error fetching selected order: $e');
      }
    }

    _loadOrderList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 15,
            child: OrderDetailScreen(
              selectedOrderIndex: _selectedOrderIndex,
              onEditOrder: onEditOrder,
              onCancelOrder: () => showCancelOrderDialog(context, _selectedOrderIndex!),
            ),
          ),
          Expanded(
            flex: 6,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.teal,
                    AppColors.blue.withOpacity(0.5),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withOpacity(0.5),
                    blurRadius: 30,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 10.0),
                    child: _topTitle(
                      context,
                      title: 'Order History',
                      action: _search(),
                    ),
                  ),
                  Expanded(
                    child: OrderListTabs(
                      key: _orderListKey,
                      futureOrderList: futureOrderList!,
                      isLoading: isLoading,
                      selectedOrderID: _selectedOrderIndex?.toString(),
                      onOrderSelected: (order) {
                        if (order.orderID != null) {
                          setState(() {
                            _selectedOrderIndex = order.orderID;
                            AppState().setSelectedOrder(_selectedOrderIndex);
                            print('Order selected: selectedOrderIndex = $_selectedOrderIndex'); // Log selection
                            isLoading = false;
                          });
                        }
                      },
                    ),
                  ),
                  /* SizedBox(height: 10),
                  _orderList(
                    orderTicket: 'Q011',
                    totalAmount: 42.60,
                    time: '3:30PM',
                    date: '13 Dec, 24',
                  ) */
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _topTitle(
    BuildContext context, {
    required String title,
    required Widget action,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: CustomFont.daysone32.copyWith(
                    fontSize: 30,
                    color: AppColors.white,
                  ),
                ),
                SegmentedToggle(
                  labels: const [
                    'Pending',
                    'Completed',
                    'Cancelled',
                  ],
                  initialIndex: statusIndex,
                  onSelected: (newIndex) {
                    setState(() {
                      statusIndex = newIndex;
                      AppState().setStatusIndex(newIndex); // Save status index here
                      AppState().setSelectedOrder(_selectedOrderIndex); // also persist selected order if needed
                    });
                    _loadOrderList();
                    print('Selected tab index: $newIndex');
                  },
                ),
                const SizedBox(height: 5),
                Row(children: [
                  Expanded(child: action),
                  const IconButton(
                    onPressed: null,
                    icon: Icon(
                      Icons.close,
                      color: AppColors.white,
                    ),
                  )
                ]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  final TextEditingController _searchController = TextEditingController();

  Widget _search() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      width: double.infinity,
      height: 35,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            const Color(0xFFD2D2D2).withOpacity(0.5),
            const Color(0xFFCFEAEB).withOpacity(0.5),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
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
                hintText: 'Search order ticket...',
                border: InputBorder.none,
                isDense: true,
              ),
              onChanged: (value) {
                // Add your search/filter logic here
                print("Searching order ticket: $value");
              },
            ),
          ),
        ],
      ),
    );
  }
}
