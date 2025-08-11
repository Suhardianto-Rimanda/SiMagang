enum UserRole { admin, supervisor, intern, unknown }

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: _parseRole(json['role']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
    };
  }

  static UserRole _parseRole(dynamic role) {
    String roleString = role.toString().toLowerCase();
    switch (roleString) {
      case 'admin':
        return UserRole.admin;
      case 'supervisor':
        return UserRole.supervisor;
      case 'intern':
        return UserRole.intern;
      default:
        return UserRole.unknown;
    }
  }
}
