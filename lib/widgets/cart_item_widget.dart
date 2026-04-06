import 'package:flutter/material.dart';
import '../models/cart_item.dart';

typedef OnQuantityChanged = void Function(String id, int qty);

class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final OnQuantityChanged onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 78,
                height: 78,
                child: Image.network(item.product.imageUrl, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'RAM: ${item.ram} • ROM: ${item.storage}',
                    style: const TextStyle(
                      color: Color(0xFF5E7386),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${item.product.price.toStringAsFixed(0)} USD',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () =>
                          onQuantityChanged(item.id, item.quantity - 1),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                    Text('${item.quantity}'),
                    IconButton(
                      onPressed: () =>
                          onQuantityChanged(item.id, item.quantity + 1),
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: onRemove,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFCC4B4B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
