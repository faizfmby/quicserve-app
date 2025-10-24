import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:quicserve_flutter/constants/theme.dart';
import 'package:quicserve_flutter/models/order_item.dart';

class OrderEditSection extends StatelessWidget {
  final List<OrderItem> orderItems;
  final String? currentOrderId;
  final double subTotal;
  final double total;
  final Function(String) onDeleteOrderItem;
  final Function(OrderItem) onEditOrderItem;
  final VoidCallback onSaveOrder;
  final VoidCallback onPlaceOrder;

  const OrderEditSection({
    super.key,
    required this.orderItems,
    required this.currentOrderId,
    required this.subTotal,
    required this.total,
    required this.onDeleteOrderItem,
    required this.onEditOrderItem,
    required this.onSaveOrder,
    required this.onPlaceOrder,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
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
              _topOrder(
                context,
                title: 'Order',
                orderId: currentOrderId,
              ),
              Expanded(
                child: orderItems.isEmpty
                    ? Center(
                        child: Opacity(
                          opacity: 0.25,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.shopping_bag_outlined,
                                size: 80,
                                color: AppColors.white,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No item',
                                style: CustomFont.calibribold18.copyWith(color: AppColors.white),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: orderItems.length,
                        itemBuilder: (context, index) {
                          final item = orderItems[index];
                          return ClipRRect(
                            child: Dismissible(
                              key: Key(item.orderItemID!),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.horizontal(right: Radius.circular(20)),
                                ),
                                child: const Icon(Icons.delete, color: Colors.white),
                              ),
                              onDismissed: (_) {
                                onDeleteOrderItem(item.orderItemID!);
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: GestureDetector(
                                  onLongPress: () {
                                    onEditOrderItem(item);
                                  },
                                  child: _itemOrder(
                                    image: item.item?.imageUrl ?? '',
                                    title: '${item.item?.itemID} ${item.item?.itemName}',
                                    qty: item.itemQuantity.toString(),
                                    price: 'RM${(item.item?.price ?? 0.0).toStringAsFixed(2)}',
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.darkgrey1.withOpacity(0.9),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Sub Total', style: CustomFont.calibribold18.copyWith(fontSize: 15, color: AppColors.white)),
                        Text(orderItems.isEmpty ? 'RM0.00' : 'RM${subTotal.toStringAsFixed(2)}', style: CustomFont.calibribold18.copyWith(fontSize: 15, color: AppColors.white)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Tax', style: CustomFont.calibribold18.copyWith(fontSize: 15, color: AppColors.white)),
                        Text('RM0.00', style: CustomFont.calibribold18.copyWith(fontSize: 15, color: AppColors.white)),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 5),
                      height: 1,
                      width: double.infinity,
                      color: Colors.white,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total', style: CustomFont.calibribold18.copyWith(fontSize: 20, color: AppColors.white)),
                        Text(orderItems.isEmpty ? 'RM0.00' : 'RM${total.toStringAsFixed(2)}', style: CustomFont.calibribold18.copyWith(fontSize: 20, color: AppColors.white)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: AppColors.black,
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundBuilder: (context, states, child) {
                          return Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.white,
                                  AppColors.lightgrey1,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            ),
                            child: child,
                          );
                        },
                      ),
                      onPressed: currentOrderId == null || orderItems.isEmpty ? null : onSaveOrder,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Save Order',
                            style: CustomFont.calibri16,
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: AppColors.black,
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundBuilder: (context, states, child) {
                          return Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.yellow1,
                                  AppColors.orange1,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            ),
                            child: child,
                          );
                        },
                      ),
                      onPressed: currentOrderId == null || orderItems.isEmpty ? null : onPlaceOrder,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Place Order',
                            style: CustomFont.calibri16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _topOrder(BuildContext context, {required String title, required String? orderId}) {
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
            if (orderId != null)
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
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'x $qty',
              style: CustomFont.calibribold12.copyWith(
                fontSize: 17,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
