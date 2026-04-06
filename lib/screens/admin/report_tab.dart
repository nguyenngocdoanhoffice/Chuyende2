import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/order_provider.dart';

class ReportTab extends StatelessWidget {
  const ReportTab({super.key});

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final byDay = orderProvider.orderCountByDay.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          child: ListTile(
            title: const Text('Tổng doanh thu'),
            subtitle: Text(
              '${orderProvider.totalRevenue.toStringAsFixed(0)} USD',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Số đơn theo ngày',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (byDay.isEmpty) const Text('Chưa có dữ liệu'),
        ...byDay.map(
          (e) => Card(
            child: ListTile(
              title: Text(e.key),
              trailing: Text('${e.value} đơn'),
            ),
          ),
        ),
      ],
    );
  }
}
