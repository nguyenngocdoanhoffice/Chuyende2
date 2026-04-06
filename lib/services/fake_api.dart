import 'dart:async';

import '../models/product.dart';

/// Fake API returns mock products after a short delay to simulate network.
class FakeApi {
  static Future<List<Product>> fetchProducts() async {
    await Future.delayed(const Duration(milliseconds: 600));

    return [
      Product(
        id: 'p1',
        name: 'Phone A1',
        category: 'Điện thoại',
        description: 'Smartphone nhẹ, pin tốt, màn hình sắc nét.',
        price: 799.0,
        imageUrl:
            'https://images.unsplash.com/photo-1510557880182-3b5f8a5a6b6f?w=800',
        onSale: true,
      ),
      Product(
        id: 'p2',
        name: 'Laptop Pro 14',
        category: 'Laptop',
        description: 'Laptop hiệu năng cao, phù hợp làm việc và học tập.',
        price: 1499.0,
        imageUrl:
            'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800',
      ),
      Product(
        id: 'p3',
        name: 'Wireless Headphones',
        category: 'Phụ kiện',
        description: 'Tai nghe không dây chống ồn, nghe hay.',
        price: 199.0,
        imageUrl:
            'https://images.unsplash.com/photo-1518444020327-9c4c409e6d4f?w=800',
      ),
      Product(
        id: 'p4',
        name: 'Phone B2',
        category: 'Điện thoại',
        description: 'Điện thoại tầm trung, camera tốt.',
        price: 599.0,
        imageUrl:
            'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=800',
      ),
      Product(
        id: 'p5',
        name: 'Gaming Laptop X',
        category: 'Laptop',
        description: 'Máy chơi game, GPU mạnh mẽ.',
        price: 1899.0,
        imageUrl:
            'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=800',
        onSale: true,
      ),
    ];
  }
}
