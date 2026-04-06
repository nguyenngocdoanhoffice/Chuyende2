import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/cart_item.dart';
import '../models/coupon.dart';
import '../models/order.dart';
import '../services/app_database.dart';

class OrderProvider with ChangeNotifier {
  final List<Order> _orders = [];
  final List<Coupon> _coupons = [];
  bool _ready = false;
  late final Future<void> _bootstrapFuture;

  OrderProvider() {
    _bootstrapFuture = _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    final db = AppDatabase.instance;
    final orders = await db.getOrders();
    final coupons = await db.getCoupons();

    _orders
      ..clear()
      ..addAll(orders);
    _coupons
      ..clear()
      ..addAll(coupons);
    _ready = true;
    notifyListeners();
  }

  Future<void> _ensureReady() async {
    if (_ready) return;
    await _bootstrapFuture;
  }

  List<Order> get orders => List.unmodifiable(_orders);
  List<Coupon> get coupons => List.unmodifiable(_coupons);

  List<Order> ordersByUser(String userId) {
    return _orders.where((o) => o.userId == userId).toList();
  }

  Coupon? findCoupon(String code) {
    for (final coupon in _coupons) {
      if (coupon.code.toUpperCase() == code.trim().toUpperCase()) {
        return coupon;
      }
    }
    return null;
  }

  Future<void> addCoupon({
    required String code,
    required double percent,
  }) async {
    await _ensureReady();
    final normalized = code.trim().toUpperCase();
    if (normalized.isEmpty) return;

    final idx = _coupons.indexWhere((c) => c.code == normalized);
    if (idx >= 0) {
      final updated = Coupon(
        id: _coupons[idx].id,
        code: normalized,
        percent: percent,
      );
      _coupons[idx] = updated;
      await AppDatabase.instance.upsertCoupon(updated);
    } else {
      final created = Coupon(
        id: const Uuid().v4(),
        code: normalized,
        percent: percent,
      );
      _coupons.add(created);
      await AppDatabase.instance.upsertCoupon(created);
    }
    notifyListeners();
  }

  Future<void> deleteCoupon(String id) async {
    await _ensureReady();
    _coupons.removeWhere((c) => c.id == id);
    await AppDatabase.instance.deleteCoupon(id);
    notifyListeners();
  }

  Future<void> placeOrder({
    required String userId,
    required String customerName,
    required String customerPhone,
    required String customerAddress,
    required double subtotal,
    required double discountPercent,
    required double total,
    required List<CartItem> cartItems,
  }) async {
    await _ensureReady();
    // Clone items so order snapshot stays stable after cart changes.
    final snapshot = cartItems
        .map(
          (i) => CartItem(
            id: i.id,
            product: i.product,
            ram: i.ram,
            storage: i.storage,
            quantity: i.quantity,
          ),
        )
        .toList();

    final order = Order(
      id: const Uuid().v4(),
      userId: userId,
      customerName: customerName,
      customerPhone: customerPhone,
      customerAddress: customerAddress,
      createdAt: DateTime.now(),
      subtotal: subtotal,
      discountPercent: discountPercent,
      total: total,
      items: snapshot,
    );
    _orders.insert(0, order);
    await AppDatabase.instance.insertOrder(order);
    notifyListeners();
  }

  Future<void> updateStatus(String orderId, OrderStatus newStatus) async {
    await _ensureReady();
    final index = _orders.indexWhere((o) => o.id == orderId);
    if (index == -1) return;
    _orders[index].status = newStatus;
    await AppDatabase.instance.updateOrderStatus(orderId, newStatus);
    notifyListeners();
  }

  double get totalRevenue =>
      _orders.fold(0.0, (sum, order) => sum + order.total);

  Map<String, int> get orderCountByDay {
    final Map<String, int> result = {};
    for (final order in _orders) {
      final key =
          '${order.createdAt.year}-${order.createdAt.month.toString().padLeft(2, '0')}-${order.createdAt.day.toString().padLeft(2, '0')}';
      result[key] = (result[key] ?? 0) + 1;
    }
    return result;
  }
}
