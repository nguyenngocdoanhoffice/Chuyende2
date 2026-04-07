import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import 'auth/login_screen.dart';
import 'user/change_password_screen.dart';
import 'user/account_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import '../widgets/product_card.dart';
import '../widgets/category_item.dart';

/// Home screen with search, banner, categories, and product grid.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final categories = [
    'Tất cả',
    'Điện thoại',
    'Laptop',
    'Phụ kiện',
    'Hàng giảm giá',
  ];

  @override
  void initState() {
    super.initState();
    // load products once
    context.read<ProductProvider>().load();
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop Demo'),
        actions: [
          IconButton(
            onPressed: () => Navigator.pushNamed(context, '/cart'),
            icon: Stack(
              children: [
                const Icon(Icons.shopping_cart_outlined),
                if (cart.count > 0)
                  Positioned(
                    right: 0,
                    child: CircleAvatar(
                      radius: 8,
                      backgroundColor: Colors.red,
                      child: Text(
                        '${cart.count}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.person_outline),
            onSelected: (v) {
              final auth = context.read<AuthProvider>();
              if (v == 'account') {
                Navigator.pushNamed(context, UserAccountScreen.routeName);
                return;
              }
              if (v == 'change') {
                Navigator.pushNamed(context, ChangePasswordScreen.routeName);
                return;
              }
              if (v == 'admin') {
                Navigator.pushNamed(context, AdminDashboardScreen.routeName);
                return;
              }
              if (v == 'logout') {
                auth.logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  LoginScreen.routeName,
                  (r) => false,
                );
                return;
              }
              if (v == 'login') {
                Navigator.pushNamed(context, LoginScreen.routeName);
                return;
              }
            },
            itemBuilder: (ctx) {
              final auth = context.read<AuthProvider>();
              if (auth.isLoggedIn) {
                return [
                  const PopupMenuItem(
                    value: 'account',
                    child: Text('Tài khoản'),
                  ),
                  const PopupMenuItem(
                    value: 'change',
                    child: Text('Đổi mật khẩu'),
                  ),
                  if (auth.isAdmin)
                    const PopupMenuItem(
                      value: 'admin',
                      child: Text('Quản trị'),
                    ),
                  const PopupMenuItem(
                    value: 'logout',
                    child: Text('Đăng xuất'),
                  ),
                ];
              }
              return [
                const PopupMenuItem(value: 'login', child: Text('Đăng nhập')),
              ];
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => productProvider.load(),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              // Banner
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  'https://images.unsplash.com/photo-1521791136064-7986c2920216?w=1200',
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),

              // Search
              TextField(
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm sản phẩm...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (v) => productProvider.setQuery(v),
              ),
              const SizedBox(height: 12),

              // Categories
              SizedBox(
                height: 42,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: categories.length,
                  itemBuilder: (_, i) {
                    final c = categories[i];
                    return CategoryItem(
                      label: c,
                      selected: productProvider.filter == c,
                      onTap: () => productProvider.setFilter(c),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),

              // Content
              Expanded(
                child: Builder(
                  builder: (_) {
                    if (productProvider.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final items = productProvider.items;
                    if (items.isEmpty) {
                      return Center(
                        child: Text('Không có sản phẩm nào'),
                      ); // empty state
                    }

                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: items.length,
                      itemBuilder: (_, i) => ProductCard(product: items[i]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/cart'),
        icon: const Icon(Icons.shopping_cart),
        label: const Text('Giỏ hàng'),
      ),
    );
  }
}
