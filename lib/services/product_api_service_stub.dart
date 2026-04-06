import '../models/product.dart';
import 'fake_api.dart';

class ProductApiService {
  ProductApiService._();

  static final List<Product> _items = [];
  static bool _initialized = false;

  static Future<void> _ensureSeeded() async {
    if (_initialized) return;
    _items.addAll(await FakeApi.fetchProducts());
    _initialized = true;
  }

  static Future<List<Product>> fetchProducts() async {
    await _ensureSeeded();
    return List<Product>.unmodifiable(_items);
  }

  static Future<Product> createProduct(Product product) async {
    await _ensureSeeded();
    _items.add(product);
    return product;
  }

  static Future<void> updateProduct(Product product) async {
    await _ensureSeeded();
    final index = _items.indexWhere((item) => item.id == product.id);
    if (index >= 0) {
      _items[index] = product;
    }
  }

  static Future<void> deleteProduct(String id) async {
    await _ensureSeeded();
    _items.removeWhere((item) => item.id == id);
  }
}
