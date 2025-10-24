import 'package:flutter/material.dart';
import 'package:quicserve_flutter/constants/theme.dart';
import 'package:quicserve_flutter/models/order_item.dart';

class OrderItemCard extends StatelessWidget {
  final Future<List<OrderItem>> futureOrderItems;
  final Widget Function(OrderItem item) itemBuilder;

  const OrderItemCard({
    super.key,
    required this.futureOrderItems,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OrderItem>>(
        future: futureOrderItems,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: snapshot.data!.isEmpty
                  ? const Opacity(opacity: 1)
                  : Opacity(
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
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              return itemBuilder(item);
            },
          );
        });
  }
}
