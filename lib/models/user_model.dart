import 'intern_model.dart';
import 'supervisor_model.dart';

enum UserRole { admin, supervisor, intern, unknown }

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final InternModel? intern;
  final SupervisorModel? supervisor;


  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.intern,
    this.supervisor,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      name: json['name'],
      email: json['email'],
      role: _parseRole(json['role']),
      intern: json['intern'] != null ? InternModel.fromJson(json['intern']) : null,
      supervisor: json['supervisor'] != null ? SupervisorModel.fromJson(json['supervisor']) : null,
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

  static UserRole _parseRole(String? roleString) {
    switch (roleString?.toLowerCase()) {
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
