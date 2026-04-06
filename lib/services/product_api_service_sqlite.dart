import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/product.dart';

class ProductApiService {
  ProductApiService._();

  static Database? _database;
  static bool _initialized = false;

  static Future<Database> _db() async {
    if (_database != null) return _database!;

    sqfliteFfiInit();
    final factory = databaseFactoryFfi;
    final dbPath = await factory.getDatabasesPath();
    final path = join(dbPath, 'my_app.db');

    _database = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _onCreate,
        onOpen: (db) async {
          await _seedIfNeeded(db);
        },
      ),
    );

    return _database!;
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        price REAL NOT NULL,
        image_url TEXT NOT NULL,
        on_sale INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await _seedIfNeeded(db);
  }

  static Future<void> _seedIfNeeded(Database db) async {
    if (_initialized) return;

    final existing = await db.query('products', limit: 1);
    if (existing.isNotEmpty) {
      _initialized = true;
      return;
    }

    final seedProducts = <Product>[
      Product(
        id: 'p1',
        name: 'Phone A1',
        category: 'Điện thoại',
        description: 'Smartphone nhẹ, pin tốt, màn hình sắc nét.',
        price: 799,
        imageUrl:
            'https://images.unsplash.com/photo-1510557880182-3b5f8a5a6b6f?w=800',
        onSale: true,
      ),
      Product(
        id: 'p2',
        name: 'Laptop Pro 14',
        category: 'Laptop',
        description: 'Laptop hiệu năng cao, phù hợp học tập và công việc.',
        price: 1499,
        imageUrl:
            'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800',
      ),
      Product(
        id: 'p3',
        name: 'Wireless Headphones',
        category: 'Phụ kiện',
        description: 'Tai nghe không dây chống ồn, chất âm tốt.',
        price: 199,
        imageUrl:
            'https://images.unsplash.com/photo-1518444020327-9c4c409e6d4f?w=800',
      ),
      Product(
        id: 'p4',
        name: 'Phone B2',
        category: 'Điện thoại',
        description: 'Điện thoại tầm trung, camera đẹp.',
        price: 599,
        imageUrl:
            'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=800',
      ),
      Product(
        id: 'p5',
        name: 'Gaming Laptop X',
        category: 'Laptop',
        description: 'Máy chơi game với GPU mạnh mẽ.',
        price: 1899,
        imageUrl:
            'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=800',
        onSale: true,
      ),
    ];

    final batch = db.batch();
    for (final product in seedProducts) {
      batch.insert('products', _row(product));
    }
    await batch.commit(noResult: true);
    _initialized = true;
  }

  static Map<String, Object?> _row(Product product) {
    return {
      'id': product.id,
      'name': product.name,
      'category': product.category,
      'description': product.description,
      'price': product.price,
      'image_url': product.imageUrl,
      'on_sale': product.onSale ? 1 : 0,
    };
  }

  static Future<List<Product>> fetchProducts() async {
    final db = await _db();
    final rows = await db.query('products', orderBy: 'id DESC');
    return rows
        .map((row) => Product.fromJson(Map<String, dynamic>.from(row)))
        .toList();
  }

  static Future<Product> createProduct(Product product) async {
    final db = await _db();
    final id = product.id.isEmpty
        ? DateTime.now().millisecondsSinceEpoch.toString()
        : product.id;
    final stored = product.copyWith(id: id);
    await db.insert(
      'products',
      _row(stored),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return stored;
  }

  static Future<void> updateProduct(Product product) async {
    final db = await _db();
    await db.update(
      'products',
      _row(product),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  static Future<void> deleteProduct(String id) async {
    final db = await _db();
    await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }
}
