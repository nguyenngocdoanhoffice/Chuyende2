import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../services/product_image_service.dart';
import '../../widgets/product_image_view.dart';

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
                    onPressed: () => _showProductDialog(context, old: product),
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
        onPressed: () => _showProductDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showProductDialog(BuildContext context, {Product? old}) {
    final nameCtrl = TextEditingController(text: old?.name ?? '');
    final descCtrl = TextEditingController(text: old?.description ?? '');
    final priceCtrl = TextEditingController(
      text: old == null ? '' : old.price.toStringAsFixed(0),
    );
    String category = old?.category ?? 'Điện thoại';
    String imagePath = old?.imageUrl ?? '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(old == null ? 'Thêm sản phẩm' : 'Sửa sản phẩm'),
        content: StatefulBuilder(
          builder: (context, setLocalState) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Tên'),
                  ),
                  TextField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Mô tả'),
                  ),
                  TextField(
                    controller: priceCtrl,
                    decoration: const InputDecoration(labelText: 'Giá'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 8),
                  if (imagePath.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: ProductImageView(
                        source: imagePath,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () async {
                      final selectedImage =
                          await ProductImageService.pickAndStoreImage();
                      if (selectedImage == null) return;
                      setLocalState(() => imagePath = selectedImage);
                    },
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Chọn ảnh từ thiết bị'),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Danh mục'),
                    items: const ['Điện thoại', 'Laptop', 'Phụ kiện']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (v) =>
                        setLocalState(() => category = v ?? category),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final price = double.tryParse(priceCtrl.text) ?? 0;
              if (nameCtrl.text.trim().isEmpty ||
                  price <= 0 ||
                  imagePath.isEmpty) {
                return;
              }

              try {
                final provider = context.read<ProductProvider>();
                if (old == null) {
                  await provider.addProduct(
                    name: nameCtrl.text,
                    category: category,
                    description: descCtrl.text,
                    price: price,
                    imageUrl: imagePath,
                  );
                } else {
                  await provider.updateProduct(
                    old.id,
                    old.copyWith(
                      name: nameCtrl.text,
                      category: category,
                      description: descCtrl.text,
                      price: price,
                      imageUrl: imagePath,
                    ),
                  );
                }

                if (!context.mounted) return;
                Navigator.pop(context);
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Lưu thất bại: $e')));
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }
}
