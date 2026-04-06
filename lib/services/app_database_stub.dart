import '../models/coupon.dart';
import '../models/order.dart';
import '../models/product.dart';
import '../models/user.dart';

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  final List<AppUser> _users = [];
  final List<Product> _products = [];
  final List<Coupon> _coupons = [];
  final List<Order> _orders = [];
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    _users.addAll([
      AppUser(
        id: 'admin-1',
        name: 'Administrator',
        email: 'admin@gmail.com',
        password: '123456',
        role: UserRole.admin,
      ),
    ]);

    _products.addAll([
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
        description: 'Laptop hiệu năng cao, phù hợp học tập và công việc.',
        price: 1499.0,
        imageUrl:
            'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=800',
      ),
      Product(
        id: 'p3',
        name: 'Wireless Headphones',
        category: 'Phụ kiện',
        description: 'Tai nghe không dây chống ồn, chất âm tốt.',
        price: 199.0,
        imageUrl:
            'https://images.unsplash.com/photo-1518444020327-9c4c409e6d4f?w=800',
      ),
      Product(
        id: 'p4',
        name: 'Phone B2',
        category: 'Điện thoại',
        description: 'Điện thoại tầm trung, camera đẹp.',
        price: 599.0,
        imageUrl:
            'https://images.unsplash.com/photo-1512496015851-a90fb38ba796?w=800',
      ),
      Product(
        id: 'p5',
        name: 'Gaming Laptop X',
        category: 'Laptop',
        description: 'Máy chơi game với GPU mạnh mẽ.',
        price: 1899.0,
        imageUrl:
            'https://images.unsplash.com/photo-1511512578047-dfb367046420?w=800',
        onSale: true,
      ),
    ]);

    _coupons.addAll([Coupon(id: 'cp-1', code: 'SALE10', percent: 10)]);

    _initialized = true;
  }

  Future<List<AppUser>> getUsers() async {
    await init();
    return List.unmodifiable(_users);
  }

  Future<void> insertUser(AppUser user) async {
    await init();
    _users.add(user);
  }

  Future<List<Product>> getProducts() async {
    await init();
    return List.unmodifiable(_products);
  }

  Future<void> insertProduct(Product product) async {
    await init();
    _products.add(product);
  }

  Future<void> updateProduct(Product product) async {
    await init();
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index >= 0) {
      _products[index] = product;
    }
  }

  Future<void> deleteProduct(String id) async {
    await init();
    _products.removeWhere((product) => product.id == id);
  }

  Future<List<Coupon>> getCoupons() async {
    await init();
    return List.unmodifiable(_coupons);
  }

  Future<void> upsertCoupon(Coupon coupon) async {
    await init();
    final index = _coupons.indexWhere((c) => c.id == coupon.id);
    if (index >= 0) {
      _coupons[index] = coupon;
    } else {
      final codeIndex = _coupons.indexWhere(
        (c) => c.code.toUpperCase() == coupon.code.toUpperCase(),
      );
      if (codeIndex >= 0) {
        _coupons[codeIndex] = coupon;
      } else {
        _coupons.add(coupon);
      }
    }
  }

  Future<void> deleteCoupon(String id) async {
    await init();
    _coupons.removeWhere((coupon) => coupon.id == id);
  }

  Future<List<Order>> getOrders() async {
    await init();
    return List.unmodifiable(_orders);
  }

  Future<void> insertOrder(Order order) async {
    await init();
    _orders.insert(0, order);
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await init();
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index >= 0) {
      _orders[index].status = status;
    }
  }
}
