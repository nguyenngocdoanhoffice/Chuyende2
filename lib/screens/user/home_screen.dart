import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/category_item.dart';
import '../../widgets/product_card.dart';
import '../auth/login_screen.dart';
import 'cart_screen.dart';
import 'my_orders_screen.dart';

class UserHomeScreen extends StatefulWidget {
  static const routeName = '/user/home';

  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
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
    context.read<ProductProvider>().load();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final productProvider = context.watch<ProductProvider>();
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Xin chào'),
            Text(
              auth.currentUser?.name ?? 'User',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, MyOrdersScreen.routeName),
            icon: const Icon(Icons.receipt_long),
            tooltip: 'Đơn của tôi',
          ),
          IconButton(
            onPressed: () =>
                Navigator.pushNamed(context, UserCartScreen.routeName),
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
          IconButton(
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                LoginScreen.routeName,
                (route) => false,
              );
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => productProvider.load(),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0B6E99), Color(0xFF26A69A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.local_shipping_outlined,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Giao nhanh 2h cho khu vực nội thành',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Tìm kiếm sản phẩm...',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: productProvider.setQuery,
              ),
              const SizedBox(height: 12),
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
              Expanded(
                child: productProvider.loading
                    ? const Center(child: CircularProgressIndicator())
                    : GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.69,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                            ),
                        itemCount: productProvider.items.length,
                        itemBuilder: (_, i) =>
                            ProductCard(product: productProvider.items[i]),
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, UserCartScreen.routeName),
        icon: const Icon(Icons.shopping_cart),
        label: const Text('Giỏ hàng'),
      ),
    );
  }
}
