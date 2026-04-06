import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../widgets/cart_item_widget.dart';

class CartScreen extends StatefulWidget {
  static const routeName = '/cart';
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final couponController = TextEditingController();

  @override
  void dispose() {
    couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Giỏ hàng')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: cart.items
                  .map(
                    (i) => CartItemWidget(
                      item: i,
                      onQuantityChanged: (id, qty) =>
                          context.read<CartProvider>().updateQuantity(id, qty),
                      onRemove: () => context.read<CartProvider>().remove(i.id),
                    ),
                  )
                  .toList(),
            ),
          ),

          // Coupon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: couponController,
                    decoration: const InputDecoration(
                      hintText: 'Nhập mã giảm giá',
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final ok = context.read<CartProvider>().applyCoupon(
                      couponController.text,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ok ? 'Áp dụng thành công' : 'Mã không hợp lệ',
                        ),
                      ),
                    );
                  },
                  child: const Text('Áp dụng'),
                ),
              ],
            ),
          ),

          // Summary
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tạm tính:'),
                    Text('${cart.subtotal.toStringAsFixed(0)} USD'),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Giảm: ${cart.discountPercent.toStringAsFixed(0)}%'),
                    Text(
                      '${(cart.subtotal - cart.total).toStringAsFixed(0)} USD',
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tổng cộng',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${cart.total.toStringAsFixed(0)} USD',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: cart.items.isEmpty
                            ? null
                            : () => Navigator.pushNamed(context, '/checkout'),
                        child: const Text('Tiến hành thanh toán'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
