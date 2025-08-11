import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  final String? _baseUrl = dotenv.env['BASE_URL'];

  Future<Map<String, dynamic>> login(String email, String password) async {
    if (_baseUrl == null) {
      throw Exception('BASE_URL tidak ditemukan di .env');
    }

    final response = await http.post(
      Uri.parse('$_baseUrl/api/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      String token = data['token'];
      User user = User.fromJson(data['user']);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('user', jsonEncode(user.toJson()));

      return {'user': user, 'token': token};
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Gagal untuk login.');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');

    final token = prefs.getString('token');
    await http.post(Uri.parse('$_baseUrl/logout'), headers: {'Authorization': 'Bearer $token'});
  }
}
