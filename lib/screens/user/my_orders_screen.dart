import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/order.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';

class MyOrdersScreen extends StatelessWidget {
  static const routeName = '/user/orders';

  const MyOrdersScreen({super.key});

  String _statusText(OrderStatus status) {
    return status == OrderStatus.processing ? 'Đang xử lý' : 'Đã giao';
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final orders = user == null
        ? <Order>[]
        : context.watch<OrderProvider>().ordersByUser(user.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Đơn hàng của tôi')),
      body: orders.isEmpty
          ? const Center(child: Text('Bạn chưa có đơn hàng nào'))
          : ListView.builder(
              itemCount: orders.length,
              itemBuilder: (_, i) {
                final order = orders[i];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    title: Text('Đơn #${order.id.substring(0, 6)}'),
                    subtitle: Text(
                      'Ngày: ${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year}\nTrạng thái: ${_statusText(order.status)}',
                    ),
                    trailing: Text('${order.total.toStringAsFixed(0)} USD'),
                  ),
                );
              },
            ),
    );
  }
}
