import 'product.dart';

/// Represents an item in the cart including selected options.
class CartItem {
  final String id; // unique cart item id
  final Product product;
  String ram;
  String storage;
  int quantity;

  CartItem({
    required this.id,
    required this.product,
    this.ram = '4GB',
    this.storage = '64GB',
    this.quantity = 1,
  });

  double get total => product.price * quantity;
}
