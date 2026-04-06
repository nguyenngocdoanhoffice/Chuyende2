import 'cart_item.dart';

class PersistedCart {
  final List<CartItem> items;
  final double discountPercent;

  const PersistedCart({required this.items, required this.discountPercent});
}
