import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/product_image_view.dart';

class UserDetailScreen extends StatefulWidget {
  static const routeName = '/user/detail';

  const UserDetailScreen({super.key});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  String selectedRam = '4GB';
  String selectedStorage = '64GB';
  int qty = 1;

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)!.settings.arguments as Product;

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết sản phẩm')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: ProductImageView(
                  source: product.imageUrl,
                  height: 270,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${product.price.toStringAsFixed(0)} USD',
                style: const TextStyle(
                  fontSize: 22,
                  color: Color(0xFF0B6E99),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              Text(product.description),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedRam,
                          decoration: const InputDecoration(labelText: 'RAM'),
                          items: ['4GB', '8GB', '16GB']
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => selectedRam = v ?? selectedRam),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedStorage,
                          decoration: const InputDecoration(
                            labelText: 'Bộ nhớ',
                          ),
                          items: ['64GB', '128GB', '256GB']
                              .map(
                                (e) =>
                                    DropdownMenuItem(value: e, child: Text(e)),
                              )
                              .toList(),
                          onChanged: (v) => setState(
                            () => selectedStorage = v ?? selectedStorage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Card(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: () =>
                            setState(() => qty = (qty - 1).clamp(1, 99)),
                        icon: const Icon(Icons.remove),
                      ),
                      const SizedBox(width: 12),
                      Text('$qty', style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: 12),
                      IconButton.filledTonal(
                        onPressed: () =>
                            setState(() => qty = (qty + 1).clamp(1, 99)),
                        icon: const Icon(Icons.add),
                      ),
                      const Spacer(),
                      FilledButton.icon(
                        onPressed: () {
                          context.read<CartProvider>().addItem(
                            product,
                            ram: selectedRam,
                            storage: selectedStorage,
                            quantity: qty,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Đã thêm vào giỏ hàng'),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Thêm vào giỏ'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
