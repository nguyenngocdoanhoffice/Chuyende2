import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/cart_item.dart';
import '../models/coupon.dart';
import '../models/order.dart';
import '../models/persisted_cart.dart';
import '../models/product.dart';
import '../models/user.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  static Database? _database;
  static bool _seeded = false;

  static bool get _useMobileSqflite =>
      Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

  Future<void> init() async {
    await _db();
  }

  static Future<Database> _db() async {
    if (_database != null) return _database!;

    if (_useMobileSqflite) {
      final dbPath = await sqflite.getDatabasesPath();
      final path = join(dbPath, 'my_app.db');
      _database = await sqflite.openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await _createTables(db);
        },
        onOpen: (db) async {
          await _createTables(db);
          await _seedIfNeeded(db);
        },
      );
    } else {
      sqfliteFfiInit();
      final factory = databaseFactoryFfi;
      final dbPath = await factory.getDatabasesPath();
      final path = join(dbPath, 'my_app.db');
      _database = await factory.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 1,
          onCreate: (db, version) async {
            await _createTables(db);
          },
          onOpen: (db) async {
            await _createTables(db);
            await _seedIfNeeded(db);
          },
        ),
      );
    }

    return _database!;
  }

  static Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        phone TEXT NOT NULL DEFAULT '',
        address TEXT NOT NULL DEFAULT ''
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS coupons (
        id TEXT PRIMARY KEY,
        code TEXT NOT NULL UNIQUE,
        percent REAL NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS orders (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        customer_name TEXT NOT NULL,
        customer_phone TEXT NOT NULL,
        customer_address TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        subtotal REAL NOT NULL,
        discount_percent REAL NOT NULL,
        total REAL NOT NULL,
        status TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id TEXT NOT NULL,
        cart_item_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        product_category TEXT NOT NULL,
        product_description TEXT NOT NULL,
        product_price REAL NOT NULL,
        product_image_url TEXT NOT NULL,
        product_on_sale INTEGER NOT NULL DEFAULT 0,
        ram TEXT NOT NULL,
        storage TEXT NOT NULL,
        quantity INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_state (
        key TEXT PRIMARY KEY,
        value TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS cart_items (
        user_id TEXT NOT NULL,
        cart_item_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        product_category TEXT NOT NULL,
        product_description TEXT NOT NULL,
        product_price REAL NOT NULL,
        product_image_url TEXT NOT NULL,
        product_on_sale INTEGER NOT NULL DEFAULT 0,
        ram TEXT NOT NULL,
        storage TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        PRIMARY KEY(user_id, cart_item_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS cart_meta (
        user_id TEXT PRIMARY KEY,
        discount_percent REAL NOT NULL DEFAULT 0
      )
    ''');
  }

  static Future<void> _seedIfNeeded(Database db) async {
    if (_seeded) return;

    final existingUsers = await db.query('users', limit: 1);
    if (existingUsers.isEmpty) {
      await db.insert('users', {
        'id': 'admin-1',
        'name': 'Administrator',
        'email': 'admin@gmail.com',
        'password': '123456',
        'role': UserRole.admin.name,
        'phone': '',
        'address': '',
      });
    }

    final existingCoupons = await db.query('coupons', limit: 1);
    if (existingCoupons.isEmpty) {
      await db.insert('coupons', {
        'id': 'cp-1',
        'code': 'SALE10',
        'percent': 10.0,
      });
    }

    _seeded = true;
  }

  Future<List<AppUser>> getUsers() async {
    final db = await _db();
    final rows = await db.query('users', orderBy: 'name ASC');
    return rows.map(_userFromRow).toList();
  }

  Future<void> insertUser(AppUser user) async {
    final db = await _db();
    await db.insert(
      'users',
      _userToRow(user),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> updateUser(AppUser user) async {
    final db = await _db();
    await db.update(
      'users',
      _userToRow(user),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<List<Coupon>> getCoupons() async {
    final db = await _db();
    final rows = await db.query('coupons', orderBy: 'code ASC');
    return rows
        .map(
          (row) => Coupon(
            id: row['id'].toString(),
            code: row['code'].toString(),
            percent: (row['percent'] as num).toDouble(),
          ),
        )
        .toList();
  }

  Future<void> upsertCoupon(Coupon coupon) async {
    final db = await _db();

    await db.transaction((tx) async {
      final codeRows = await tx.query(
        'coupons',
        columns: ['id'],
        where: 'UPPER(code) = UPPER(?)',
        whereArgs: [coupon.code],
      );

      if (codeRows.isNotEmpty) {
        await tx.update(
          'coupons',
          {'id': coupon.id, 'code': coupon.code, 'percent': coupon.percent},
          where: 'id = ?',
          whereArgs: [codeRows.first['id']],
        );
        return;
      }

      await tx.insert('coupons', {
        'id': coupon.id,
        'code': coupon.code,
        'percent': coupon.percent,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<void> deleteCoupon(String id) async {
    final db = await _db();
    await db.delete('coupons', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Order>> getOrders() async {
    final db = await _db();
    final rows = await db.query('orders', orderBy: 'created_at DESC');

    final orders = <Order>[];
    for (final row in rows) {
      final orderId = row['id'].toString();
      final itemRows = await db.query(
        'order_items',
        where: 'order_id = ?',
        whereArgs: [orderId],
      );

      final items = itemRows.map(_orderItemFromRow).toList();
      orders.add(
        Order(
          id: orderId,
          userId: row['user_id'].toString(),
          customerName: row['customer_name'].toString(),
          customerPhone: row['customer_phone'].toString(),
          customerAddress: row['customer_address'].toString(),
          createdAt: DateTime.fromMillisecondsSinceEpoch(
            (row['created_at'] as num).toInt(),
          ),
          subtotal: (row['subtotal'] as num).toDouble(),
          discountPercent: (row['discount_percent'] as num).toDouble(),
          total: (row['total'] as num).toDouble(),
          items: items,
          status: _statusFromString(row['status'].toString()),
        ),
      );
    }

    return orders;
  }

  Future<void> insertOrder(Order order) async {
    final db = await _db();

    await db.transaction((tx) async {
      await tx.insert('orders', {
        'id': order.id,
        'user_id': order.userId,
        'customer_name': order.customerName,
        'customer_phone': order.customerPhone,
        'customer_address': order.customerAddress,
        'created_at': order.createdAt.millisecondsSinceEpoch,
        'subtotal': order.subtotal,
        'discount_percent': order.discountPercent,
        'total': order.total,
        'status': order.status.name,
      });

      for (final item in order.items) {
        await tx.insert('order_items', _orderItemToRow(order.id, item));
      }
    });
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final db = await _db();
    await db.update(
      'orders',
      {'status': status.name},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  Future<String?> getCurrentUserId() async {
    final db = await _db();
    final rows = await db.query(
      'app_state',
      columns: ['value'],
      where: 'key = ?',
      whereArgs: ['current_user_id'],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    final value = rows.first['value']?.toString();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  Future<void> setCurrentUserId(String? userId) async {
    final db = await _db();
    if (userId == null || userId.isEmpty) {
      await db.delete(
        'app_state',
        where: 'key = ?',
        whereArgs: ['current_user_id'],
      );
      return;
    }

    await db.insert('app_state', {
      'key': 'current_user_id',
      'value': userId,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<PersistedCart> getCartByUser(String userId) async {
    final db = await _db();
    final itemRows = await db.query(
      'cart_items',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    final metaRows = await db.query(
      'cart_meta',
      columns: ['discount_percent'],
      where: 'user_id = ?',
      whereArgs: [userId],
      limit: 1,
    );

    final items = itemRows.map(_cartItemFromRow).toList();
    final discountPercent = metaRows.isEmpty
        ? 0.0
        : (metaRows.first['discount_percent'] as num).toDouble();

    return PersistedCart(items: items, discountPercent: discountPercent);
  }

  Future<void> saveCartByUser({
    required String userId,
    required List<CartItem> items,
    required double discountPercent,
  }) async {
    final db = await _db();

    await db.transaction((tx) async {
      await tx.delete('cart_items', where: 'user_id = ?', whereArgs: [userId]);

      for (final item in items) {
        await tx.insert('cart_items', _cartItemToRow(userId, item));
      }

      await tx.insert('cart_meta', {
        'user_id': userId,
        'discount_percent': discountPercent,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<void> clearCartByUser(String userId) async {
    final db = await _db();
    await db.transaction((tx) async {
      await tx.delete('cart_items', where: 'user_id = ?', whereArgs: [userId]);
      await tx.delete('cart_meta', where: 'user_id = ?', whereArgs: [userId]);
    });
  }

  static Map<String, Object?> _userToRow(AppUser user) {
    return {
      'id': user.id,
      'name': user.name,
      'email': user.email,
      'password': user.password,
      'role': user.role.name,
      'phone': user.phone,
      'address': user.address,
    };
  }

  static AppUser _userFromRow(Map<String, Object?> row) {
    return AppUser(
      id: row['id'].toString(),
      name: row['name'].toString(),
      email: row['email'].toString(),
      password: row['password'].toString(),
      role: row['role'].toString() == UserRole.admin.name
          ? UserRole.admin
          : UserRole.user,
      phone: row['phone']?.toString() ?? '',
      address: row['address']?.toString() ?? '',
    );
  }

  static Map<String, Object?> _orderItemToRow(String orderId, CartItem item) {
    return {
      'order_id': orderId,
      'cart_item_id': item.id,
      'product_id': item.product.id,
      'product_name': item.product.name,
      'product_category': item.product.category,
      'product_description': item.product.description,
      'product_price': item.product.price,
      'product_image_url': item.product.imageUrl,
      'product_on_sale': item.product.onSale ? 1 : 0,
      'ram': item.ram,
      'storage': item.storage,
      'quantity': item.quantity,
    };
  }

  static CartItem _orderItemFromRow(Map<String, Object?> row) {
    final product = Product(
      id: row['product_id'].toString(),
      name: row['product_name'].toString(),
      category: row['product_category'].toString(),
      description: row['product_description'].toString(),
      price: (row['product_price'] as num).toDouble(),
      imageUrl: row['product_image_url'].toString(),
      onSale: (row['product_on_sale'] as num).toInt() == 1,
    );

    return CartItem(
      id: row['cart_item_id'].toString(),
      product: product,
      ram: row['ram'].toString(),
      storage: row['storage'].toString(),
      quantity: (row['quantity'] as num).toInt(),
    );
  }

  static Map<String, Object?> _cartItemToRow(String userId, CartItem item) {
    return {
      'user_id': userId,
      'cart_item_id': item.id,
      'product_id': item.product.id,
      'product_name': item.product.name,
      'product_category': item.product.category,
      'product_description': item.product.description,
      'product_price': item.product.price,
      'product_image_url': item.product.imageUrl,
      'product_on_sale': item.product.onSale ? 1 : 0,
      'ram': item.ram,
      'storage': item.storage,
      'quantity': item.quantity,
    };
  }

  static CartItem _cartItemFromRow(Map<String, Object?> row) {
    final product = Product(
      id: row['product_id'].toString(),
      name: row['product_name'].toString(),
      category: row['product_category'].toString(),
      description: row['product_description'].toString(),
      price: (row['product_price'] as num).toDouble(),
      imageUrl: row['product_image_url'].toString(),
      onSale: (row['product_on_sale'] as num).toInt() == 1,
    );

    return CartItem(
      id: row['cart_item_id'].toString(),
      product: product,
      ram: row['ram'].toString(),
      storage: row['storage'].toString(),
      quantity: (row['quantity'] as num).toInt(),
    );
  }

  static OrderStatus _statusFromString(String value) {
    return value == OrderStatus.delivered.name
        ? OrderStatus.delivered
        : OrderStatus.processing;
  }
}
