// ignore_for_file: unnecessary_null_comparison

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:quicserve_flutter/constants/theme.dart';
import 'package:quicserve_flutter/models/order.dart';

class OrderListTabs extends StatefulWidget {
  final Future<List<Order>> futureOrderList;
  final bool isLoading;
  final String? selectedOrderID;
  final Function(Order) onOrderSelected;

  const OrderListTabs({
    super.key,
    required this.futureOrderList,
    required this.isLoading,
    required this.selectedOrderID,
    required this.onOrderSelected,
  });

  @override
  State<OrderListTabs> createState() => OrderListTabsState();
}

class OrderListTabsState extends State<OrderListTabs> {
  List<Order> _orders = [];
  Map<String, GlobalKey> _itemKeys = {};

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedOrder();
    });
  }

  @override
  void didUpdateWidget(covariant OrderListTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedOrderID != oldWidget.selectedOrderID) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToSelectedOrder();
      });
    }
  }

  void _scrollToSelectedOrder({int attempt = 1}) {
    final key = _itemKeys[widget.selectedOrderID];
    if (key != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(milliseconds: 400), () {
          if (key.currentContext != null) {
            Scrollable.ensureVisible(
              key.currentContext!,
              duration: const Duration(milliseconds: 400),
              alignment: 0.0, // scroll to top
              curve: Curves.easeInOut,
            );
          } else if (attempt < 3) {
            // Retry after delay
            _scrollToSelectedOrder(attempt: attempt + 1);
          }
        });
      });
    }
  }

  void scrollToSelected() {
    _scrollToSelectedOrder();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Order>>(
      future: widget.futureOrderList,
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
                  Icon(
                    Icons.layers_clear,
                    size: 80,
                    color: AppColors.white.withOpacity(0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No orders found',
                    style: CustomFont.calibribold18.copyWith(color: AppColors.white.withOpacity(0.5)),
                  ),
                ],
              ),
            ),
          );
        }

        _orders = snapshot.data!.where((order) => order.orderID != null && order.orderTicket != null && order.time != null && order.date != null && order.orderStatus != null).toList();
        if (_orders.isEmpty) {
          return const Center(child: Text('No valid orders found.'));
        }

        return Container(
          child: widget.isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.vertical,
                  itemCount: _orders.length,
                  itemBuilder: (context, index) {
                    final order = _orders[index];
                    final key = _itemKeys.putIfAbsent(order.orderID!, () => GlobalKey());

                    return GestureDetector(
                      key: key,
                      onTap: () => widget.onOrderSelected(order),
                      child: _orderList(
                        orderID: order.orderID!,
                        orderTicket: order.orderTicket!,
                        totalAmount: order.totalAmount!,
                        time: order.time.toString(),
                        date: order.date.toString(),
                        selectedOrderID: widget.selectedOrderID,
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _orderList({
    required String orderID,
    required String orderTicket,
    required double totalAmount,
    required String time,
    required String date,
    required String? selectedOrderID,
  }) {
    final bool isActive = selectedOrderID != null && orderID == selectedOrderID;
    // Format time to 12-hour mode (e.g., "3:30 PM")
    final formattedTime = time.isNotEmpty ? DateFormat('h:mm a').format(DateTime.parse('1970-01-01 $time')) : '';
    // Format date to "DD MMM, YY" (e.g., "13 Dec, 24")
    final formattedDate = date.isNotEmpty ? DateFormat('dd MMM, yy').format(DateTime.parse(date)) : '';

    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedContainer(
          //transform: isActive ? Matrix4.translationValues(0.0, -3.0, 0.0) : Matrix4.translationValues(0.0, 0.0, 0.0),
          duration: const Duration(milliseconds: 200), // Smooth transition
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0, right: 15.0),
          decoration: isActive
              ? BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(45), border: Border.all(width: 1, color: Colors.white24), boxShadow: [
                  BoxShadow(offset: const Offset(1, 5), blurRadius: 10, color: AppColors.black.withOpacity(0.2))
                ])
              : null,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                margin: const EdgeInsets.only(right: 13),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.gradient2,
                    boxShadow: [
                      BoxShadow(offset: const Offset(4, 0), blurRadius: 10, color: isActive ? AppColors.white.withOpacity(0.4) : AppColors.black.withOpacity(0.5))
                    ],
                  ),
                  child: Text(
                    orderTicket,
                    style: CustomFont.daysone10.copyWith(fontSize: 14, color: isActive ? AppColors.black : AppColors.black.withOpacity(0.5)),
                  ),
                ),
              ),
              Text(
                'RM${totalAmount.toStringAsFixed(2)}',
                style: CustomFont.calibribold22.copyWith(
                  color: isActive ? AppColors.white : AppColors.lightgrey3.withOpacity(0.5),
                ),
              ),
              const Spacer(),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formattedTime,
                    style: CustomFont.calibribold12.copyWith(color: isActive ? AppColors.white : AppColors.lightgrey3.withOpacity(0.5)),
                  ),
                  Text(
                    formattedDate,
                    style: CustomFont.calibribold12.copyWith(color: isActive ? AppColors.white : AppColors.lightgrey3.withOpacity(0.5)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
