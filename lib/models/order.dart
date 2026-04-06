import 'cart_item.dart';

enum OrderStatus { processing, delivered }

class Order {
  final String id;
  final String userId;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final DateTime createdAt;
  final double subtotal;
  final double discountPercent;
  final double total;
  final List<CartItem> items;
  OrderStatus status;

  Order({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.createdAt,
    required this.subtotal,
    required this.discountPercent,
    required this.total,
    required this.items,
    this.status = OrderStatus.processing,
  });
}
