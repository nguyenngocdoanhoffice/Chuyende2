import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../admin/admin_dashboard_screen.dart';
import '../user/home_screen.dart';
import 'login_screen.dart';

/// Chooses start screen based on login state and role.
class AuthGateScreen extends StatelessWidget {
  static const routeName = '/';

  const AuthGateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!auth.isLoggedIn) {
      return const LoginScreen();
    }

    if (auth.isAdmin) {
      return const AdminDashboardScreen();
    }

    return const UserHomeScreen();
  }
}
