import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'providers/auth_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/auth/auth_gate_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
import 'screens/user/home_screen.dart';
import 'screens/user/account_screen.dart';
import 'screens/user/detail_screen.dart';
import 'screens/user/cart_screen.dart';
import 'screens/user/checkout_screen.dart';
import 'screens/user/my_orders_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

/// Root app. Sets up Providers and routes.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProxyProvider<AuthProvider, CartProvider>(
          create: (_) => CartProvider(),
          update: (_, auth, cart) {
            final provider = cart ?? CartProvider();
            provider.bindUser(auth.currentUser?.id);
            return provider;
          },
        ),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: MaterialApp(
        title: 'Mobile Shop',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF0B6E99),
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.nunitoTextTheme(),
          scaffoldBackgroundColor: const Color(0xFFF4F8FB),
          appBarTheme: const AppBarTheme(
            centerTitle: false,
            elevation: 0,
            backgroundColor: Colors.transparent,
            foregroundColor: Color(0xFF153047),
          ),
          cardTheme: CardThemeData(
            elevation: 1,
            shadowColor: const Color(0xFF1B4A6B).withValues(alpha: 0.15),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFD8E7F1)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFD8E7F1)),
            ),
          ),
          useMaterial3: true,
        ),
        initialRoute: AuthGateScreen.routeName,
        routes: {
          AuthGateScreen.routeName: (_) => const AuthGateScreen(),
          LoginScreen.routeName: (_) => const LoginScreen(),
          RegisterScreen.routeName: (_) => const RegisterScreen(),
          AdminDashboardScreen.routeName: (_) => const AdminDashboardScreen(),
          UserHomeScreen.routeName: (_) => const UserHomeScreen(),
          UserAccountScreen.routeName: (_) => const UserAccountScreen(),
          UserDetailScreen.routeName: (_) => const UserDetailScreen(),
          UserCartScreen.routeName: (_) => const UserCartScreen(),
          UserCheckoutScreen.routeName: (_) => const UserCheckoutScreen(),
          MyOrdersScreen.routeName: (_) => const MyOrdersScreen(),
        },
      ),
    );
  }
}
