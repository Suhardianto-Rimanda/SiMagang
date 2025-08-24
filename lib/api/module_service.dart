import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_simagang/models/learning_module_model.dart';

class ModuleService {
  final String baseUrl = dotenv.env['BASE_URL']!;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<bool> createModule({
    required String title,
    required String description,
    File? file,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Token not found');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/learning-modules'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    request.fields['title'] = title;
    request.fields['description'] = description;

    if (file != null) {
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
    }

    final response = await request.send();
    return response.statusCode == 201;
  }

  // Menugaskan module ke intern
  Future<bool> assignModuleToInterns(int moduleId, List<int> internIds) async {
    final token = await _getToken();
    if (token == null) throw Exception('Token not found');

    final response = await http.post(
      Uri.parse('$baseUrl/learning-modules/$moduleId/assign'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'intern_ids': internIds,
      }),
    );

    return response.statusCode == 200;
  }

  // Mendapatkan semua learning modules
  Future<List<LearningModuleModel>> getLearningModules() async {
    final token = await _getToken();
    if (token == null) throw Exception('Token not found');

    final response = await http.get(
      Uri.parse('$baseUrl/learning-modules'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => LearningModuleModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load learning modules');
    }
  }
}
