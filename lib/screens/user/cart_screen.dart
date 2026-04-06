import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../widgets/cart_item_widget.dart';
import 'checkout_screen.dart';

class UserCartScreen extends StatefulWidget {
  static const routeName = '/user/cart';

  const UserCartScreen({super.key});

  @override
  State<UserCartScreen> createState() => _UserCartScreenState();
}

class _UserCartScreenState extends State<UserCartScreen> {
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
            child: cart.items.isEmpty
                ? const Center(
                    child: Text(
                      'Giỏ hàng đang trống, hãy thêm sản phẩm bạn thích.',
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    children: cart.items
                        .map(
                          (i) => CartItemWidget(
                            item: i,
                            onQuantityChanged: (id, qty) => context
                                .read<CartProvider>()
                                .updateQuantity(id, qty),
                            onRemove: () =>
                                context.read<CartProvider>().remove(i.id),
                          ),
                        )
                        .toList(),
                  ),
          ),
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
                    final coupon = context.read<OrderProvider>().findCoupon(
                      couponController.text,
                    );
                    if (coupon == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Mã không hợp lệ')),
                      );
                      return;
                    }

                    context.read<CartProvider>().setDiscountPercent(
                      coupon.percent,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Áp dụng ${coupon.percent.toStringAsFixed(0)}%',
                        ),
                      ),
                    );
                  },
                  child: const Text('Áp dụng'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
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
                        Text(
                          'Giảm: ${cart.discountPercent.toStringAsFixed(0)}%',
                        ),
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
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: cart.items.isEmpty
                            ? null
                            : () => Navigator.pushNamed(
                                context,
                                UserCheckoutScreen.routeName,
                              ),
                        child: const Text('Tiến hành thanh toán'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
