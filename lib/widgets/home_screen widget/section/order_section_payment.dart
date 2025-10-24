import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:quicserve_flutter/constants/theme.dart';
import 'package:quicserve_flutter/models/order_item.dart';

class OrderSection extends StatelessWidget {
  final List<OrderItem> orderItems;
  final String? currentOrderId;
  final double subTotal;
  final double total;

  const OrderSection({
    super.key,
    required this.orderItems,
    required this.currentOrderId,
    required this.subTotal,
    required this.total,
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
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _itemOrder(
                                image: item.item?.imageUrl ?? '',
                                title: item.item?.itemName ?? '',
                                qty: item.itemQuantity.toString(),
                                price: 'RM${(item.item?.price ?? 0.0).toStringAsFixed(2)}',
                              ),
                            ),
                          );
                        },
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
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
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
