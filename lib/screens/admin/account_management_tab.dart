import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../models/user.dart';

class AccountManagementTab extends StatefulWidget {
  const AccountManagementTab({super.key});

  @override
  State<AccountManagementTab> createState() => _AccountManagementTabState();
}

class _AccountManagementTabState extends State<AccountManagementTab> {
  bool _loading = false;

  Future<void> _changeRole(String userId, UserRole role) async {
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final err = await auth.setRole(userId, role);
    if (!mounted) return;
    setState(() => _loading = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật phân quyền thành công')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final users = auth.users;

    return RefreshIndicator(
      onRefresh: () async {},
      child: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: users.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (_, i) {
          final u = users[i];
          return ListTile(
            title: Text(u.name),
            subtitle: Text(u.email),
            trailing: _loading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : DropdownButton<UserRole>(
                    value: u.role,
                    items: const [
                      DropdownMenuItem(
                        value: UserRole.user,
                        child: Text('User'),
                      ),
                      DropdownMenuItem(
                        value: UserRole.admin,
                        child: Text('Admin'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) _changeRole(u.id, v);
                    },
                  ),
          );
        },
      ),
    );
  }
}
