import 'dart:convert';

enum UserRole { admin, supervisor, intern, unknown }

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
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
