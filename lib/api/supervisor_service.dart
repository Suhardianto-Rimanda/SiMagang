import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_simagang/models/user_model.dart';
import 'package:app_simagang/models/intern_model.dart';

class SupervisorService {
  final String baseUrl = dotenv.env['BASE_URL']!;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Mengambil daftar intern yang dibimbing oleh supervisor
  Future<List<UserModel>> getSupervisorInterns() async {
    final token = await _getToken();
    if (token == null) throw Exception('Token not found');

    final response = await http.get(
      Uri.parse('$baseUrl/supervisor-interns'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['data'];

      // PERBAIKAN: Parsing manual karena API tidak mengirim objek 'user' bersarang.
      return data
          .whereType<Map<String, dynamic>>()
          .map((internJson) {
        // 1. Buat InternModel dari JSON intern.
        InternModel internData = InternModel.fromJson(internJson);

        // 2. Buat UserModel secara manual dari data yang ada.
        // API tidak menyediakan email di endpoint ini, jadi kita beri nilai default.
        // Backend idealnya harus menyertakan data user yang relevan.
        UserModel user = UserModel(
          id: internJson['user_id']?.toString() ?? '',
          name: internData.fullName, // Mengambil nama dari fullName di data intern
          email: internJson['user']?['email'] ?? 'Email tidak tersedia', // Coba ambil email jika ada, jika tidak, beri default
          role: UserRole.intern,
          intern: internData, // Lampirkan data intern yang sudah dibuat
        );

        return user;
      })
          .toList();

    } else {
      throw Exception('Failed to load interns. Status: ${response.statusCode}');
    }
  }
}
