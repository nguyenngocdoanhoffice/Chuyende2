import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/product_provider.dart';
import 'product_edit_screen.dart';

class ProductManagementTab extends StatelessWidget {
  const ProductManagementTab({super.key});

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>().items;

    return Scaffold(
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (_, i) {
          final product = products[i];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: ListTile(
              title: Text(product.name),
              subtitle: Text(
                '${product.price.toStringAsFixed(0)} USD - ${product.category}',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProductEditScreen(product: product),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      try {
                        await context.read<ProductProvider>().deleteProduct(
                          product.id,
                        );
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Xóa thất bại: $e')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProductEditScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}
