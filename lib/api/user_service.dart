import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class UserService {
  final String? _baseUrl = dotenv.env['BASE_URL'];

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<UserModel>> getUsers() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/users'),
      headers: await _getHeaders(),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body)['users'];
      List<UserModel> users = body.map((dynamic item) => UserModel.fromJson(item)).toList();
      return users;
    } else {
      throw Exception('Gagal memuat data pengguna. Status: ${response.statusCode}, Body: ${response.body}');
    }
  }

  Future<UserModel> addUser(Map<String, dynamic> userData) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users'),
      headers: await _getHeaders(),
      body: jsonEncode(userData),
    );

    if (response.statusCode == 201) {
      return UserModel.fromJson(jsonDecode(response.body)['user']);
    } else {
      final errorBody = jsonDecode(response.body);
      print('[UserService] Error saat menambah pengguna: ${errorBody.toString()}');
      throw Exception('Gagal menambah pengguna: ${errorBody.toString()}');
    }
  }

  Future<UserModel> updateUser(String id, Map<String, dynamic> userData) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/users/$id'),
      headers: await _getHeaders(),
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body)['user']);
    } else {
      final errorBody = jsonDecode(response.body);
      print('[UserService] Error saat memperbarui pengguna: ${errorBody.toString()}');
      throw Exception('Gagal memperbarui pengguna: ${errorBody.toString()}');
    }
  }

  Future<void> deleteUser(String id) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/users/$id'),
      headers: await _getHeaders(),
    );

    if (response.statusCode != 200) {
      final errorBody = jsonDecode(response.body);
      print('[UserService] Error saat menghapus pengguna: ${errorBody.toString()}');
      throw Exception('Gagal menghapus pengguna: ${errorBody['message']}');
    }
  }
}
