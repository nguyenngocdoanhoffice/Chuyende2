/// Role definition for simple authorization.
enum UserRole { admin, user }

class AppUser {
  final String id;
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final String phone;
  final String address;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.phone = '',
    this.address = '',
  });

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? password,
    UserRole? role,
    String? phone,
    String? address,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }
}
