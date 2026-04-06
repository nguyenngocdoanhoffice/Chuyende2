/// Role definition for simple authorization.
enum UserRole { admin, user }

class AppUser {
  final String id;
  final String name;
  final String email;
  final String password;
  final UserRole role;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });
}
