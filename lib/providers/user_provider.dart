import 'package:flutter/material.dart';
import 'package:app_simagang/models/supervisor_model.dart';
import '../api/user_service.dart';
import '../models/user_model.dart';

// Enum untuk status operasi agar UI bisa merespons dengan lebih baik
enum UserOperationStatus { initial, loading, success, error }

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();

  // State untuk daftar pengguna
  List<UserModel> _users = [];
  List<UserModel> get users => _users;

  // State untuk status pemuatan data awal
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // State untuk pesan error
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // State untuk operasi CRUD (tambah/ubah)
  UserOperationStatus _operationStatus = UserOperationStatus.initial;
  UserOperationStatus get operationStatus => _operationStatus;

  // Mengambil semua data pengguna
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

  // Menambah pengguna baru
  Future<void> addUser(Map<String, dynamic> userData) async {
    _operationStatus = UserOperationStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      await _userService.addUser(userData);
      _operationStatus = UserOperationStatus.success;
      await fetchUsers(); // Refresh daftar pengguna setelah berhasil
    } catch (e) {
      _errorMessage = e.toString();
      _operationStatus = UserOperationStatus.error;
    } finally {
      notifyListeners();
    }
  }

  // Mengupdate data pengguna
  Future<void> updateUser(String id, Map<String, dynamic> userData) async {
    _operationStatus = UserOperationStatus.loading;
    _errorMessage = null;
    notifyListeners();
    try {
      await _userService.updateUser(id, userData);
      _operationStatus = UserOperationStatus.success;
      await fetchUsers(); // Refresh daftar pengguna setelah berhasil
    } catch (e) {
      _errorMessage = e.toString();
      _operationStatus = UserOperationStatus.error;
    } finally {
      notifyListeners();
    }
  }

  // Menghapus pengguna
  Future<void> deleteUser(String id) async {
    _errorMessage = null;
    try {
      await _userService.deleteUser(id);
      // Hapus pengguna dari daftar lokal untuk pembaruan UI yang instan
      _users.removeWhere((user) => user.id == id);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      // Selalu notifikasi listener meskipun gagal, untuk menampilkan pesan error
      notifyListeners();
    }
  }

  // Mengambil daftar supervisor (berguna untuk form tambah intern)
  List<SupervisorModel> get supervisors => _users
      .where((user) => user.role == UserRole.supervisor && user.supervisor != null)
      .map((user) => user.supervisor!)
      .toList();
}
