// lib/api/module_service.dart

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

  // Mengembalikan objek LearningModule yang baru dibuat agar ID-nya bisa didapat
  Future<LearningModuleModel?> createModule({
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

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return LearningModuleModel.fromJson(json.decode(response.body)['data']);
    } else {
      return null;
    }
  }

  // Menugaskan module ke intern
  Future<bool> assignModuleToInterns(String moduleId, List<String> internIds) async {
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

  // Method gabungan untuk membuat dan menugaskan modul
  Future<bool> createAndAssignModule({
    required String title,
    required String description,
    File? file,
    required List<String> internIds,
  }) async {
    try {
      final newModule = await createModule(title: title, description: description, file: file);
      if (newModule != null) {
        return await assignModuleToInterns(newModule.id, internIds);
      }
      return false;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
