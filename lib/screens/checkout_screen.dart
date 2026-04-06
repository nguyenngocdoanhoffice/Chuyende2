import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';

class CheckoutScreen extends StatefulWidget {
  static const routeName = '/checkout';
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  String payment = 'Tiền mặt';

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Tên người nhận'),
                validator: (v) => v == null || v.isEmpty ? 'Nhập tên' : null,
              ),
              TextFormField(
                controller: phoneCtrl,
                decoration: const InputDecoration(labelText: 'Số điện thoại'),
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nhập số điện thoại' : null,
              ),
              TextFormField(
                controller: addressCtrl,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ giao hàng',
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Nhập địa chỉ' : null,
              ),
              const SizedBox(height: 12),
              const Text(
                'Phương thức thanh toán',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              DropdownButtonFormField<String>(
                initialValue: payment,
                items: const [
                  DropdownMenuItem(value: 'Tiền mặt', child: Text('Tiền mặt')),
                  DropdownMenuItem(
                    value: 'Chuyển khoản',
                    child: Text('Chuyển khoản'),
                  ),
                ],
                onChanged: (v) => setState(() => payment = v ?? payment),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // For demo, simply show confirmation and clear cart
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Đặt hàng thành công'),
                              content: Text(
                                'Tổng: ${cart.total.toStringAsFixed(0)} USD',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    context.read<CartProvider>().clear();
                                    Navigator.of(
                                      context,
                                    ).popUntil((route) => route.isFirst);
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      child: const Text('Đặt hàng'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
