import 'dart:convert';

// Enum untuk role agar lebih aman dan mudah dikelola
enum UserRole { admin, supervisor, intern, unknown }

class User {
  final int id;
  final String name;
  final String email;
  final UserRole role;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  // Factory constructor untuk membuat instance User dari JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      // Mengubah string role dari API menjadi enum UserRole
      role: _parseRole(json['role']),
    );
  }

  // Method untuk mengubah instance User menjadi JSON (berguna untuk menyimpan ke SharedPreferences)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name, // Mengubah enum menjadi string
    };
  }

  // Helper function untuk parsing role
  static UserRole _parseRole(String? role) {
    switch (role?.toLowerCase()) {
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
