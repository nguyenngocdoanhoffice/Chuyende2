import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order.dart';
import '../../providers/order_provider.dart';

class OrderManagementTab extends StatelessWidget {
  const OrderManagementTab({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderProvider>().orders;

    if (orders.isEmpty) {
      return const Center(child: Text('Chưa có đơn hàng nào'));
    }

    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (_, i) {
        final order = orders[i];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            title: Text(
              'Đơn #${order.id.substring(0, 6)} - ${order.customerName}',
            ),
            subtitle: Text(
              'Tổng: ${order.total.toStringAsFixed(0)} USD\nĐịa chỉ: ${order.customerAddress}',
            ),
            trailing: DropdownButton<OrderStatus>(
              value: order.status,
              items: const [
                DropdownMenuItem(
                  value: OrderStatus.processing,
                  child: Text('Đang xử lý'),
                ),
                DropdownMenuItem(
                  value: OrderStatus.delivered,
                  child: Text('Đã giao'),
                ),
              ],
              onChanged: (v) async {
                if (v == null) return;
                await context.read<OrderProvider>().updateStatus(order.id, v);
              },
            ),
          ),
        );
      },
    );
  }
}
