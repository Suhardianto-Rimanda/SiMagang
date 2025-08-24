import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_simagang/models/task_model.dart';

class TaskService {
  final String baseUrl = dotenv.env['BASE_URL']!;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Membuat task baru
  Future<bool> createTask({
    required String title,
    required String description,
    required String dueDate, // Format: YYYY-MM-DD
    File? file,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Token not found');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/tasks'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';
    request.fields['title'] = title;
    request.fields['description'] = description;
    request.fields['due_date'] = dueDate;

    if (file != null) {
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
    }

    final response = await request.send();
    return response.statusCode == 201;
  }

  // Menugaskan task ke intern
  Future<bool> assignTaskToInterns(int taskId, List<int> internIds) async {
    final token = await _getToken();
    if (token == null) throw Exception('Token not found');

    final response = await http.post(
      Uri.parse('$baseUrl/tasks/$taskId/assign'),
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

  // Mendapatkan semua task
  Future<List<Task>> getTasks() async {
    final token = await _getToken();
    if (token == null) throw Exception('Token not found');

    final response = await http.get(
      Uri.parse('$baseUrl/tasks'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => Task.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tasks');
    }
  }
}
