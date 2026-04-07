import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../auth/login_screen.dart';
import 'coupon_management_tab.dart';
import 'dashboard_overview_tab.dart';
import 'order_management_tab.dart';
import 'product_management_tab.dart';
import 'report_tab.dart';
import 'account_management_tab.dart';

class AdminDashboardScreen extends StatelessWidget {
  static const routeName = '/admin';

  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Admin Dashboard'),
          actions: [
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
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Dashboard'),
              Tab(text: 'Sản phẩm'),
              Tab(text: 'Đơn hàng'),
              Tab(text: 'Coupon'),
              Tab(text: 'Báo cáo'),
              Tab(text: 'Tài khoản'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            DashboardOverviewTab(),
            ProductManagementTab(),
            OrderManagementTab(),
            CouponManagementTab(),
            ReportTab(),
            AccountManagementTab(),
          ],
        ),
      ),
    );
  }
}
