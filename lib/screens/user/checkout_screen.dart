import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';

class UserCheckoutScreen extends StatefulWidget {
  static const routeName = '/user/checkout';

  const UserCheckoutScreen({super.key});

  @override
  State<UserCheckoutScreen> createState() => _UserCheckoutScreenState();
}

class _UserCheckoutScreenState extends State<UserCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    nameCtrl.text = user?.name ?? '';
    phoneCtrl.text = user?.phone ?? '';
    addressCtrl.text = user?.address ?? '';
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Tên người nhận',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Nhập tên' : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: phoneCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Số điện thoại',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (v) => v == null || v.isEmpty
                            ? 'Nhập số điện thoại'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: addressCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Địa chỉ giao hàng',
                          prefixIcon: Icon(Icons.location_on_outlined),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? 'Nhập địa chỉ' : null,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tổng thanh toán'),
                      Text(
                        '${cart.total.toStringAsFixed(0)} USD',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  final user = auth.currentUser;
                  if (user == null) return;

                  await context.read<OrderProvider>().placeOrder(
                    userId: user.id,
                    customerName: nameCtrl.text,
                    customerPhone: phoneCtrl.text,
                    customerAddress: addressCtrl.text,
                    subtotal: cart.subtotal,
                    discountPercent: cart.discountPercent,
                    total: cart.total,
                    cartItems: cart.items,
                  );

                  if (!context.mounted) return;
                  context.read<CartProvider>().clear();
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Đặt hàng thành công'),
                      content: const Text('Cảm ơn bạn đã mua hàng!'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Đặt hàng'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
