import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/cart_item.dart';
import '../models/product.dart';

/// Manages cart items and coupon logic.
class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  double _discountPercent = 0.0;

  List<CartItem> get items => _items.values.toList();

  int get count => _items.length;

  double get subtotal =>
      _items.values.fold(0.0, (sum, item) => sum + item.total);

  double get total => subtotal * (1 - _discountPercent / 100);

  double get discountPercent => _discountPercent;

  void addItem(
    Product product, {
    String ram = '4GB',
    String storage = '64GB',
    int quantity = 1,
  }) {
    // create unique cart item id to allow multiple variants of same product
    final id = const Uuid().v4();
    _items[id] = CartItem(
      id: id,
      product: product,
      ram: ram,
      storage: storage,
      quantity: quantity,
    );
    notifyListeners();
  }

  void updateQuantity(String cartItemId, int qty) {
    if (!_items.containsKey(cartItemId)) return;
    _items[cartItemId]!.quantity = qty;
    if (qty <= 0) _items.remove(cartItemId);
    notifyListeners();
  }

  void remove(String cartItemId) {
    _items.remove(cartItemId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _discountPercent = 0.0;
    notifyListeners();
  }

  /// This is used by coupon management screens to apply a global discount.
  void setDiscountPercent(double value) {
    _discountPercent = value.clamp(0, 100).toDouble();
    notifyListeners();
  }

  /// Apply coupon like "SALE10" -> 10%
  bool applyCoupon(String code) {
    final map = {'SALE10': 10.0, 'STUDENT15': 15.0};
    final percent = map[code.toUpperCase()];
    if (percent != null) {
      setDiscountPercent(percent);
      return true;
    }
    return false;
  }
}
