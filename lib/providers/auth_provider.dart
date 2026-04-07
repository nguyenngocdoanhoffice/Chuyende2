import 'dart:async';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../models/user.dart';
import '../services/app_database.dart';

class AuthProvider with ChangeNotifier {
  final List<AppUser> _users = [];

  AppUser? _currentUser;
  bool _ready = false;
  late final Future<void> _bootstrapFuture;

  AuthProvider() {
    _bootstrapFuture = _bootstrap();
  }

  AppUser? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isReady => _ready;

  bool get isAdmin => _currentUser?.role == UserRole.admin;

  Future<void> _loadUsers() async {
    _users
      ..clear()
      ..addAll(await AppDatabase.instance.getUsers());
  }

  Future<void> _bootstrap() async {
    await _loadUsers();
    final persistedUserId = await AppDatabase.instance.getCurrentUserId();
    if (persistedUserId != null && persistedUserId.isNotEmpty) {
      final index = _users.indexWhere((u) => u.id == persistedUserId);
      if (index >= 0) {
        _currentUser = _users[index];
      }
    }
    _ready = true;
    notifyListeners();
  }

  Future<void> _ensureReady() async {
    await _bootstrapFuture;
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _ensureReady();
    if (name.trim().isEmpty) return 'Tên không được để trống';
    if (!email.contains('@') || email.length < 5) return 'Email không hợp lệ';
    if (password.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';

    final normalizedEmail = email.trim().toLowerCase();
    final exists = _users.any((u) => u.email.toLowerCase() == normalizedEmail);
    if (exists) return 'Email đã tồn tại';

    final user = AppUser(
      id: const Uuid().v4(),
      name: name.trim(),
      email: normalizedEmail,
      password: password,
      role: UserRole.user,
    );
    _users.add(user);
    await AppDatabase.instance.insertUser(user);
    notifyListeners();
    return null;
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    await _ensureReady();
    final normalizedEmail = email.trim().toLowerCase();

    for (final user in _users) {
      if (user.email.toLowerCase() == normalizedEmail &&
          user.password == password) {
        _currentUser = user;
        await AppDatabase.instance.setCurrentUserId(user.id);
        notifyListeners();
        return null;
      }
    }
    return 'Sai email hoặc mật khẩu';
  }

  void logout() {
    _currentUser = null;
    unawaited(AppDatabase.instance.setCurrentUserId(null));
    notifyListeners();
  }

  Future<String?> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String address,
  }) async {
    await _ensureReady();
    final current = _currentUser;
    if (current == null) return 'Bạn chưa đăng nhập';

    if (name.trim().isEmpty) return 'Tên không được để trống';
    if (!email.contains('@') || email.length < 5) return 'Email không hợp lệ';

    final normalizedEmail = email.trim().toLowerCase();
    final emailExists = _users.any(
      (u) => u.id != current.id && u.email.toLowerCase() == normalizedEmail,
    );
    if (emailExists) return 'Email đã tồn tại';

    final updated = current.copyWith(
      name: name.trim(),
      email: normalizedEmail,
      phone: phone.trim(),
      address: address.trim(),
    );

    final index = _users.indexWhere((u) => u.id == current.id);
    if (index >= 0) {
      _users[index] = updated;
    }
    _currentUser = updated;
    await AppDatabase.instance.updateUser(updated);
    notifyListeners();
    return null;
  }

  List<AppUser> get users => List.unmodifiable(_users);

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _ensureReady();
    final current = _currentUser;
    if (current == null) return 'Bạn chưa đăng nhập';

    if (current.password != currentPassword)
      return 'Mật khẩu hiện tại không đúng';
    if (newPassword.length < 6) return 'Mật khẩu mới phải ít nhất 6 ký tự';

    final updated = current.copyWith(password: newPassword);
    final index = _users.indexWhere((u) => u.id == current.id);
    if (index >= 0) _users[index] = updated;
    _currentUser = updated;
    await AppDatabase.instance.updateUser(updated);
    notifyListeners();
    return null;
  }

  Future<String?> setRole(String userId, UserRole role) async {
    await _ensureReady();
    final index = _users.indexWhere((u) => u.id == userId);
    if (index < 0) return 'Người dùng không tồn tại';
    final updated = _users[index].copyWith(role: role);
    _users[index] = updated;
    if (_currentUser?.id == userId) _currentUser = updated;
    await AppDatabase.instance.updateUser(updated);
    notifyListeners();
    return null;
  }
}
