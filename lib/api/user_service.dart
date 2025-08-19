import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserService {
  final String? _baseUrl = dotenv.env['BASE_URL'];

  // Helper untuk mendapatkan token dari SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Helper untuk membuat headers yang menyertakan token otentikasi
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Mengambil semua data pengguna dari API
  Future<List<UserModel>> getUsers() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      // Sesuaikan dengan respons dari controller Laravel: {'users': [...]}
      List<dynamic> body = jsonDecode(response.body)['users'];
      List<UserModel> users = body.map((dynamic item) => UserModel.fromJson(item)).toList();
      return users;
    } else {
      // Melempar exception jika gagal
      throw Exception('Gagal memuat data pengguna. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }

  // Menambah pengguna baru ke API
  Future<UserModel> addUser(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users'),
      headers: await _getHeaders(),
      body: jsonEncode(userData),
    );

    if (response.statusCode == 201) {
      // Mengembalikan data user yang baru dibuat dari respons API
      return UserModel.fromJson(jsonDecode(response.body)['user']);
    } else {
      // Menangani error validasi atau error server lainnya
      final errorBody = jsonDecode(response.body);
      throw Exception('Gagal menambah pengguna: ${errorBody.toString()}');
    }
  }

  // Mengubah data pengguna yang ada di API
  Future<UserModel> updateUser(String id, Map<String, dynamic> userData) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/users/$id'),
      headers: await _getHeaders(),
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      // Mengembalikan data user yang telah diupdate
      return UserModel.fromJson(jsonDecode(response.body)['user']);
    } else {
      final errorBody = jsonDecode(response.body);
      throw Exception('Gagal memperbarui pengguna: ${errorBody.toString()}');
    }
  }

  // Menghapus pengguna dari API
  Future<void> deleteUser(String id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/users/$id'),
      headers: await _getHeaders(),
    );

    // UserController mengembalikan status 200 jika berhasil
    if (response.statusCode != 200) {
      final errorBody = jsonDecode(response.body);
      throw Exception('Gagal menghapus pengguna: ${errorBody['message']}');
    }
  }
}
