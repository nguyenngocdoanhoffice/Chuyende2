import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../providers/product_provider.dart';
import '../../services/product_image_service.dart';
import '../../widgets/product_image_view.dart';

class ProductEditScreen extends StatefulWidget {
  final Product? product;

  const ProductEditScreen({super.key, this.product});

  @override
  State<ProductEditScreen> createState() => _ProductEditScreenState();
}

class _ProductEditScreenState extends State<ProductEditScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _priceCtrl;
  String _category = 'Điện thoại';
  String _imagePath = '';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameCtrl = TextEditingController(text: product?.name ?? '');
    _descCtrl = TextEditingController(text: product?.description ?? '');
    _priceCtrl = TextEditingController(
      text: product == null ? '' : product.price.toStringAsFixed(0),
    );
    _category = product?.category ?? 'Điện thoại';
    _imagePath = product?.imageUrl ?? '';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final selectedImage = await ProductImageService.pickAndStoreImage();
    if (selectedImage == null) return;
    setState(() => _imagePath = selectedImage);
  }

  Future<void> _save() async {
    final price = double.tryParse(_priceCtrl.text) ?? 0;
    if (_nameCtrl.text.trim().isEmpty || price <= 0 || _imagePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ thông tin')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final provider = context.read<ProductProvider>();
      final old = widget.product;
      if (old == null) {
        await provider.addProduct(
          name: _nameCtrl.text.trim(),
          category: _category,
          description: _descCtrl.text.trim(),
          price: price,
          imageUrl: _imagePath,
        );
      } else {
        await provider.updateProduct(
          old.id,
          old.copyWith(
            name: _nameCtrl.text.trim(),
            category: _category,
            description: _descCtrl.text.trim(),
            price: price,
            imageUrl: _imagePath,
          ),
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lưu thất bại: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.product != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Sửa sản phẩm' : 'Thêm sản phẩm')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Tên'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _descCtrl,
            decoration: const InputDecoration(labelText: 'Mô tả'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _priceCtrl,
            decoration: const InputDecoration(labelText: 'Giá'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _category,
            decoration: const InputDecoration(labelText: 'Danh mục'),
            items: const [
              'Điện thoại',
              'Laptop',
              'Phụ kiện',
            ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _category = v ?? _category),
          ),
          const SizedBox(height: 12),
          if (_imagePath.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: ProductImageView(
                source: _imagePath,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Chọn ảnh từ thiết bị'),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined),
            label: Text(_saving ? 'Đang lưu...' : 'Lưu'),
          ),
        ],
      ),
    );
  }
}
