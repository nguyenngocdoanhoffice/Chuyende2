import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';

class DashboardOverviewTab extends StatelessWidget {
  const DashboardOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final productProvider = context.watch<ProductProvider>();

    final totalOrders = orderProvider.orders.length;
    final totalRevenue = orderProvider.totalRevenue;
    final totalProducts = productProvider.items.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _StatCard(title: 'Tổng số đơn hàng', value: '$totalOrders'),
        _StatCard(
          title: 'Tổng doanh thu',
          value: '${totalRevenue.toStringAsFixed(0)} USD',
        ),
        _StatCard(title: 'Số sản phẩm', value: '$totalProducts'),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;

  const _StatCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }
}
