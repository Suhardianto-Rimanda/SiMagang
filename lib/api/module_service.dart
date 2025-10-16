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

  // FUNGSI INI SEKARANG MENGGABUNGKAN PEMBUATAN DAN PENUGASAN
  Future<bool> createAndAssignModule({
    required String title,
    required String description,
    File? file,
    required List<String> internIds,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Token not found');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/learning-modules'), // Endpoint untuk membuat modul baru
    );

    // Menambahkan header
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    // Menambahkan data teks (fields)
    request.fields['title'] = title;
    request.fields['description'] = description;

    // Menambahkan array intern_ids
    for (int i = 0; i < internIds.length; i++) {
      request.fields['intern_ids[$i]'] = internIds[i];
    }

    // Menambahkan file jika ada
    if (file != null) {
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Status 201 berarti 'Created' (sukses)
      return response.statusCode == 201;

    } catch (e) {
      print('Error in createAndAssignModule: $e');
      return false;
    }
  }

  // Fungsi getLearningModules tetap sama
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