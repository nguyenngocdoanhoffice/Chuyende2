import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/cart_provider.dart';

class DetailScreen extends StatefulWidget {
  static const routeName = '/detail';
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
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
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  product.imageUrl,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${product.price.toStringAsFixed(0)} USD',
                style: const TextStyle(fontSize: 18, color: Colors.green),
              ),
              const SizedBox(height: 12),
              Text(product.description),
              const SizedBox(height: 12),

              // Options
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: selectedRam,
                      decoration: const InputDecoration(labelText: 'RAM'),
                      items: ['4GB', '8GB', '16GB']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
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
                      decoration: const InputDecoration(labelText: 'Bộ nhớ'),
                      items: ['64GB', '128GB', '256GB']
                          .map(
                            (e) => DropdownMenuItem(value: e, child: Text(e)),
                          )
                          .toList(),
                      onChanged: (v) => setState(
                        () => selectedStorage = v ?? selectedStorage,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Quantity & Add
              Row(
                children: [
                  IconButton(
                    onPressed: () =>
                        setState(() => qty = (qty - 1).clamp(1, 99)),
                    icon: const Icon(Icons.remove),
                  ),
                  Text('$qty', style: const TextStyle(fontSize: 16)),
                  IconButton(
                    onPressed: () =>
                        setState(() => qty = (qty + 1).clamp(1, 99)),
                    icon: const Icon(Icons.add),
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<CartProvider>().addItem(
                        product,
                        ram: selectedRam,
                        storage: selectedStorage,
                        quantity: qty,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Đã thêm vào giỏ hàng')),
                      );
                    },
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Thêm vào giỏ hàng'),
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
