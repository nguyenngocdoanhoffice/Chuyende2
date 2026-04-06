import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/order_provider.dart';

class CouponManagementTab extends StatefulWidget {
  const CouponManagementTab({super.key});

  @override
  State<CouponManagementTab> createState() => _CouponManagementTabState();
}

class _CouponManagementTabState extends State<CouponManagementTab> {
  final codeCtrl = TextEditingController();
  final percentCtrl = TextEditingController();

  @override
  void dispose() {
    codeCtrl.dispose();
    percentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final coupons = context.watch<OrderProvider>().coupons;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: codeCtrl,
                  decoration: const InputDecoration(labelText: 'Mã giảm giá'),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 110,
                child: TextField(
                  controller: percentCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: '% giảm'),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  final percent = double.tryParse(percentCtrl.text) ?? 0;
                  if (codeCtrl.text.trim().isEmpty ||
                      percent <= 0 ||
                      percent > 100) {
                    return;
                  }
                  await context.read<OrderProvider>().addCoupon(
                    code: codeCtrl.text,
                    percent: percent,
                  );
                  codeCtrl.clear();
                  percentCtrl.clear();
                },
                child: const Text('Tạo'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: coupons.length,
              itemBuilder: (_, i) {
                final coupon = coupons[i];
                return ListTile(
                  title: Text(coupon.code),
                  subtitle: Text(
                    'Giảm ${coupon.percent.toStringAsFixed(0)}% toàn bộ giỏ hàng',
                  ),
                  trailing: IconButton(
                    onPressed: () async {
                      await context.read<OrderProvider>().deleteCoupon(
                        coupon.id,
                      );
                    },
                    icon: const Icon(Icons.delete, color: Colors.red),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
