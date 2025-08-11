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

    final Uri loginUri = Uri.parse('$_baseUrl/login');

    // 1. Mencetak URL yang dituju untuk memastikan tidak ada typo.
    print('[AuthService] Mencoba login ke: $loginUri');

    try {
      final response = await http.post(
        loginUri,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Accept': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
        }),
      );

      // 2. Memeriksa apakah respons sukses atau tidak.
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Ini akan tercetak jika login berhasil.
        print('[AuthService] Respons API Sukses: $data');

        String token = data['access_token'];
        User user = User.fromJson(data['data']);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('user', jsonEncode(user.toJson()));

        return {'user': user, 'token': token};
      } else {
        // 3. Blok ini akan berjalan jika server merespons dengan error (4xx atau 5xx).
        print('[AuthService] Login Gagal. Status Code: ${response.statusCode}');
        print('[AuthService] Error Body: ${response.body}');

        // Coba decode error message dari server
        final errorData = jsonDecode(response.body);
        String errorMessage = errorData['message'] ?? 'Terjadi kesalahan server.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      // 4. Blok ini akan menangkap error jaringan atau masalah lain.
      print('[AuthService] Terjadi exception saat request: $e');
      throw Exception('Tidak dapat terhubung ke server. Periksa koneksi internet atau konfigurasi URL.');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }
}
