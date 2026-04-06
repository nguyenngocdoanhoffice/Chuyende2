import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/app_database.dart';

/// Manages cart items and coupon logic.
class CartProvider with ChangeNotifier {
  final Map<String, CartItem> _items = {};
  double _discountPercent = 0.0;
  String? _currentUserId;
  int _bindToken = 0;

  List<CartItem> get items => _items.values.toList();

  int get count => _items.length;

  double get subtotal =>
      _items.values.fold(0.0, (sum, item) => sum + item.total);

  double get total => subtotal * (1 - _discountPercent / 100);

  double get discountPercent => _discountPercent;

  Future<void> bindUser(String? userId) async {
    final token = ++_bindToken;
    _currentUserId = userId;

    _items.clear();
    _discountPercent = 0.0;
    notifyListeners();

    if (userId == null || userId.isEmpty) return;

    final persisted = await AppDatabase.instance.getCartByUser(userId);
    if (token != _bindToken) return;

    _items
      ..clear()
      ..addEntries(persisted.items.map((item) => MapEntry(item.id, item)));
    _discountPercent = persisted.discountPercent.clamp(0, 100).toDouble();
    notifyListeners();
  }

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
    _persistCurrentCart();
    notifyListeners();
  }

  void updateQuantity(String cartItemId, int qty) {
    if (!_items.containsKey(cartItemId)) return;
    _items[cartItemId]!.quantity = qty;
    if (qty <= 0) _items.remove(cartItemId);
    _persistCurrentCart();
    notifyListeners();
  }

  void remove(String cartItemId) {
    _items.remove(cartItemId);
    _persistCurrentCart();
    notifyListeners();
  }

  void clear() {
    _items.clear();
    _discountPercent = 0.0;
    _persistCurrentCart();
    notifyListeners();
  }

  /// This is used by coupon management screens to apply a global discount.
  void setDiscountPercent(double value) {
    _discountPercent = value.clamp(0, 100).toDouble();
    _persistCurrentCart();
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

  void _persistCurrentCart() {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) return;

    final snapshot = _items.values
        .map(
          (item) => CartItem(
            id: item.id,
            product: item.product,
            ram: item.ram,
            storage: item.storage,
            quantity: item.quantity,
          ),
        )
        .toList();

    unawaited(
      AppDatabase.instance.saveCartByUser(
        userId: userId,
        items: snapshot,
        discountPercent: _discountPercent,
      ),
    );
  }
}
