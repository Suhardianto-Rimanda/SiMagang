import 'package:flutter/material.dart';
import 'package:app_simagang/models/supervisor_model.dart';
import '../api/user_service.dart';
import '../models/user_model.dart';

enum UserOperationStatus { initial, loading, success, error }

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();

  List<UserModel> _users = [];
  List<UserModel> get users => _users;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  UserOperationStatus _operationStatus = UserOperationStatus.initial;
  UserOperationStatus get operationStatus => _operationStatus;

  Future<void> fetchUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _users = await _userService.getUsers();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addUser(Map<String, dynamic> userData) async {
    _operationStatus = UserOperationStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      await _userService.addUser(userData);
      _operationStatus = UserOperationStatus.success;
      await fetchUsers();
    } catch (e) {
      _errorMessage = e.toString();
      _operationStatus = UserOperationStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateUser(String id, Map<String, dynamic> userData) async {
    _operationStatus = UserOperationStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      await _userService.updateUser(id, userData);
      _operationStatus = UserOperationStatus.success;
      await fetchUsers();
    } catch (e) {
      _errorMessage = e.toString();
      _operationStatus = UserOperationStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> deleteUser(String id) async {
    _errorMessage = null;
    try {
      await _userService.deleteUser(id);
      _users.removeWhere((user) => user.id == id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  List<SupervisorModel> get supervisors => _users
      .where((user) => user.role == UserRole.supervisor && user.supervisor != null)
      .map((user) => user.supervisor!)
      .toList();
}
