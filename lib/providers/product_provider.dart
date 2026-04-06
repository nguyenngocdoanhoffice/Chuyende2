import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/product.dart';
import '../services/product_api_service.dart';

/// ProductProvider loads products and supports search & filter.
class ProductProvider with ChangeNotifier {
  List<Product> _items = [];
  bool _loading = false;

  String _query = '';
  String _filter = 'Tất cả';

  List<Product> get items {
    var list = _items;
    if (_query.isNotEmpty) {
      list = list
          .where((p) => p.name.toLowerCase().contains(_query.toLowerCase()))
          .toList();
    }
    if (_filter == 'Hàng giảm giá') {
      list = list.where((p) => p.onSale).toList();
    } else if (_filter != 'Tất cả') {
      list = list.where((p) => p.category == _filter).toList();
    }
    return list;
  }

  bool get loading => _loading;
  String get filter => _filter;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    try {
      _items = await ProductApiService.fetchProducts();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void setQuery(String q) {
    _query = q;
    notifyListeners();
  }

  void setFilter(String f) {
    _filter = f;
    notifyListeners();
  }

  Product? getById(String id) {
    for (final product in _items) {
      if (product.id == id) return product;
    }
    return null;
  }

  Future<void> addProduct({
    required String name,
    required String category,
    required String description,
    required double price,
    required String imageUrl,
    bool onSale = false,
  }) async {
    final product = Product(
      id: const Uuid().v4(),
      name: name,
      category: category,
      description: description,
      price: price,
      imageUrl: imageUrl,
      onSale: onSale,
    );
    final createdProduct = await ProductApiService.createProduct(product);
    _items.add(createdProduct);
    notifyListeners();
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final index = _items.indexWhere((p) => p.id == id);
    if (index == -1) return;
    await ProductApiService.updateProduct(newProduct);
    _items[index] = newProduct;
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    await ProductApiService.deleteProduct(id);
    _items.removeWhere((p) => p.id == id);
    notifyListeners();
  }
}
