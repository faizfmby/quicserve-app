import 'package:flutter/material.dart';
import 'package:quicserve_flutter/constants/theme.dart';
import 'package:quicserve_flutter/models/order.dart';
import 'package:quicserve_flutter/models/order_item.dart';
import 'package:quicserve_flutter/screen/orders/payment_screen.dart';
import 'package:quicserve_flutter/services/api/order_services.dart';
import 'package:quicserve_flutter/util/app_state.dart';
import 'package:quicserve_flutter/util/debounce.dart';

class OrderDetailScreen extends StatefulWidget {
  final String? selectedOrderIndex;
  final VoidCallback onEditOrder;
  final VoidCallback onCancelOrder;

  const OrderDetailScreen({
    super.key,
    required this.selectedOrderIndex,
    required this.onEditOrder,
    required this.onCancelOrder,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool isLoading = false;
  String? _selectedOrderIndex;
  Future<List<Order>>? futureOrderDetails;
  List<Order> orderDetails = [];

  @override
  void initState() {
    super.initState();
    try {
      // Get the last persisted selectedOrderIndex
      String? persistedIndex = AppState().getSelectedOrder();
      // Use widget.selectedOrderIndex if provided, otherwise fall back to persisted or null
      _selectedOrderIndex = widget.selectedOrderIndex ?? persistedIndex;
      print('Initial selectedOrderIndex: $_selectedOrderIndex (from widget: ${widget.selectedOrderIndex}, persisted: $persistedIndex)');

      // If no valid index, try to use the last valid persisted index or set to null explicitly
      if (_selectedOrderIndex == null && persistedIndex != null) {
        _selectedOrderIndex = persistedIndex;
        print('Falling back to last persisted index: $_selectedOrderIndex');
      } else if (_selectedOrderIndex != null) {
        AppState().setSelectedOrder(_selectedOrderIndex); // Persist the new index
        print('Persisted new selectedOrderIndex: $_selectedOrderIndex');
      } else {
        print('No valid selectedOrderIndex, using null');
      }

      _loadOrderDetails();
      if (futureOrderDetails == null) {
        futureOrderDetails = Future.value([]);
        print('Initialized futureOrderDetails with empty list');
      }
    } catch (e) {
      print('Error in initState: $e');
    }
  }

  @override
  void didUpdateWidget(covariant OrderDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedOrderIndex != oldWidget.selectedOrderIndex) {
      _selectedOrderIndex = widget.selectedOrderIndex ?? AppState().getSelectedOrder();
      if (_selectedOrderIndex != null) {
        AppState().setSelectedOrder(_selectedOrderIndex);
        print('selectedOrderIndex changed to: $_selectedOrderIndex');
        _loadOrderDetails();
      } else {
        print('No new selectedOrderIndex, retaining current: $_selectedOrderIndex');
      }
    }
  }

  void _loadOrderDetails() async {
    print('Loading order details for $_selectedOrderIndex');
    setState(() => isLoading = true);
    try {
      final orderID = _selectedOrderIndex;
      if (orderID != null) {
        print('Fetching order with orderID: $orderID');
        futureOrderDetails = OrderServices().fetchSelectedOrder(orderId: orderID);
        final selectedOrders = await futureOrderDetails!;
        print('Raw API response orders: $selectedOrders');
        final validSelectedOrders = selectedOrders.where((o) => o.orderID != null && o.orderTicket != null && o.orderStatus != null && o.totalAmount != null && o.date != null && o.time != null && (o.staff?.name != null || o.staff == null) && o.orderItem?.isNotEmpty == true && o.orderItem!.any((item) => (item.item?.imageUrl != null || item.item == null) && item.item?.itemID != null && item.item?.itemName != null && item.itemQuantity != null && (item.item?.price != null))).toList();
        print('Valid orders after filtering: $validSelectedOrders');
        setState(() {
          orderDetails = validSelectedOrders;
          if (validSelectedOrders.isEmpty && selectedOrders.isNotEmpty) {
            // Keep the last selected index if the order exists but fails filtering
            print('Order exists but failed filtering, retaining selectedOrderIndex: $_selectedOrderIndex');
          } else if (validSelectedOrders.isNotEmpty) {
            AppState().setSelectedOrder(_selectedOrderIndex);
            print('Persisted selectedOrderIndex: $_selectedOrderIndex');
          } else {
            AppState().setSelectedOrder(null);
            print('No valid orders, cleared selectedOrderIndex');
          }
          isLoading = false;
        });
      } else {
        setState(() {
          orderDetails = [];
          AppState().setSelectedOrder(null);
          print('No orderID, cleared selectedOrderIndex');
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading order list: $e');
      setState(() {
        orderDetails = [];
        AppState().setSelectedOrder(null);
        print('Error occurred, cleared selectedOrderIndex');
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<Order>>(
              future: futureOrderDetails,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Opacity(
                      opacity: 0.25,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline_outlined,
                            size: 80,
                            color: AppColors.black,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No selected order',
                            style: CustomFont.calibribold18.copyWith(color: AppColors.black),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final order = snapshot.data!.firstWhere(
                  (o) => o.orderID == _selectedOrderIndex,
                  orElse: () => snapshot.data!.isNotEmpty
                      ? snapshot.data![0]
                      : Order(
                          orderID: 'N/A',
                          orderTicket: 'N/A',
                          date: DateTime.now().toString().split(' ')[0],
                          time: DateTime.now().toString().split(' ')[1].split('.')[0],
                          orderStatus: 'N/A',
                          totalAmount: 0.0,
                          staff: null,
                          paymentMethod: null,
                          orderItem: [],
                          cancelReason: 'N/A',
                        ),
                );

                return Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 14,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.yellow2,
                                  AppColors.orange2,
                                ],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Order Ticket [${order.orderTicket ?? 'N/A'}]',
                                style: CustomFont.daysone14.copyWith(fontSize: 16),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 30,
                            child: CustomScrollView(
                              slivers: [
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                                    child: _orderInformation(
                                      title: 'ORDER INFORMATION',
                                      total: order.totalAmount ?? 0.0,
                                      orderId: order.orderID ?? 'N/A',
                                      date: order.date ?? 'N/A',
                                      time: order.time ?? 'N/A',
                                      cashier: order.staff?.name ?? 'N/A',
                                      orderTicket: order.orderTicket ?? 'N/A',
                                      orderStatus: order.orderStatus ?? '',
                                      onEditOrder: widget.onEditOrder,
                                      onCancelOrder: widget.onCancelOrder,
                                    ),
                                  ),
                                ),
                                SliverToBoxAdapter(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                                    child: _orderItems(
                                      title: 'ORDER ITEMS',
                                      orderItems: order.orderItem ?? [],
                                      paymentMethod: order.paymentMethod?.paymentType ?? 'N/A',
                                      subTotal: order.totalAmount ?? 0.0,
                                      total: order.totalAmount ?? 0.0,
                                      orderStatus: order.orderStatus ?? '',
                                      cancelReason: order.cancelReason ?? '',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (order.orderStatus == 'pending')
                            Expanded(
                              flex: 3,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) => PaymentScreen2(
                                        orderItems: order.orderItem ?? [],
                                        currentOrderId: _selectedOrderIndex,
                                        subTotal: order.totalAmount ?? 0.0,
                                        total: order.totalAmount ?? 0.0,
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
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  backgroundColor: AppColors.orange1,
                                  foregroundColor: Colors.black,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(),
                                ),
                                child: Ink(
                                  width: double.infinity,
                                  decoration: BoxDecoration(gradient: AppColors.gradient2),
                                  child: const Center(
                                    child: Text(
                                      'Proceed Payment',
                                      style: CustomFont.calibri16,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}

Widget _orderInformation({
  required String title,
  required double total,
  required String orderId,
  required String date,
  required String time,
  required String cashier,
  required String orderTicket,
  required String orderStatus,
  required VoidCallback onEditOrder,
  required VoidCallback onCancelOrder,
}) {
  final String status = orderStatus;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Text(title, style: CustomFont.calibri16.copyWith(color: AppColors.lightgrey3)),
          Spacer(),
          //TextButton(onPressed: () {}, child: Text('Reprint', style: CustomFont.calibri16.copyWith(color: AppColors.lightgrey3)))
        ],
      ),
      const Divider(color: AppColors.lightgrey3),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
            child: Container(
              height: 120,
              decoration: BoxDecoration(color: status == 'pending' ? Colors.red : (status == 'completed' ? Colors.green : AppColors.lightgrey5), borderRadius: BorderRadius.circular(20)),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(status == 'pending' ? 'Unpaid' : (status == 'completed' ? 'Paid' : 'Cancelled'), style: CustomFont.calibri16.copyWith(fontSize: 16, color: AppColors.white)),
                  Text('RM${total.toStringAsFixed(2)}', style: CustomFont.calibribold22.copyWith(fontSize: 40, color: AppColors.white)),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: status == 'pending' ? () => debounceAsync(action: onEditOrder) : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(57),
                    backgroundColor: AppColors.lightgrey5,
                    foregroundColor: AppColors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Edit Order'),
                ),
                const SizedBox(height: 5),
                ElevatedButton(
                  onPressed: status == 'pending' ? () => debounceAsync(action: onCancelOrder) : null,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size.fromHeight(57),
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.black,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Cancel Order'),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: 10),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(orderId, style: CustomFont.calibri16.copyWith(fontSize: 18)),
          Text('Rumah Popia', style: CustomFont.calibri16.copyWith(fontSize: 18)),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('$date at $time', style: CustomFont.calibri16.copyWith(color: AppColors.lightgrey3, fontSize: 14.5)),
          Text('Cashier: $cashier', style: CustomFont.calibri16.copyWith(color: AppColors.lightgrey3, fontSize: 14.5)),
        ],
      ),
      const SizedBox(height: 10),
      Container(
        width: double.infinity,
        decoration: BoxDecoration(color: AppColors.darkgrey4, borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.only(top: 8, bottom: 8, left: 15),
        child: Text(orderTicket, style: CustomFont.calibribold18.copyWith(color: AppColors.white)),
      ),
    ],
  );
}

Widget _orderItems({
  required String title,
  required List<OrderItem>? orderItems,
  required String? paymentMethod,
  required double subTotal,
  required double total,
  required String orderStatus,
  required String cancelReason,
}) {
  final String status = orderStatus;

  return Column(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: CustomFont.calibri16.copyWith(
          color: AppColors.lightgrey3,
        ),
      ),
      const Divider(
        color: AppColors.lightgrey3,
      ),
      ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: orderItems?.length,
        itemBuilder: (context, index) {
          final orderItem = orderItems?[index];
          if (orderItem == null) return const SizedBox.shrink();
          final item = orderItem.item;
          return Column(
            children: [
              Row(
                children: [
                  Image.network(
                    item!.imageUrl ?? '',
                    scale: 12,
                    errorBuilder: (context, error, stackTrace) => Icon(Icons.error, color: AppColors.lightgrey3),
                  ),
                  SizedBox(width: 10),
                  Text('${orderItem.item?.itemID ?? ''} ${orderItem.item?.itemName ?? 'N/A'}'),
                  Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('x${orderItem.itemQuantity.toString()}'),
                      Text('RM${orderItem.subTotal!.toStringAsFixed(2)}'),
                    ],
                  ),
                ],
              ),
              if ((orderItems?.length ?? 0) > 1 && index < (orderItems?.length ?? 0) - 1) const Divider(color: AppColors.lightgrey3),
            ],
          );
        },
      ),
      const Divider(
        color: AppColors.lightgrey3,
      ),
      if (status == 'completed')
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Payment Type'),
            Text(paymentMethod!),
          ],
        ),
      if (status == 'cancelled')
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Cancel reason',
            ),
            Text(
              cancelReason,
              style: TextStyle(color: Colors.red),
            ),
          ],
        ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Sub-total'),
          Text('RM${subTotal.toStringAsFixed(2)}'),
        ],
      ),
      const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Tax'),
          Text('RM0.00'),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total',
            style: CustomFont.calibribold28,
          ),
          Text(
            'RM${subTotal.toStringAsFixed(2)}',
            style: CustomFont.calibribold28,
          ),
        ],
      ),
      const Divider(
        color: AppColors.lightgrey3,
      ),
    ],
  );
}
