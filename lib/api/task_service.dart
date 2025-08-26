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

  Future<Task?> createTask({
    required String title,
    required String description,
    required String dueDate,
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

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 201) {
      return Task.fromJson(json.decode(response.body)['data']);
    } else {
      print('Failed to create task. Status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return null;
    }
  }

  Future<bool> assignTaskToInterns(String taskId, List<String> internIds) async {
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

    if (response.statusCode != 200) {
      print('Failed to assign task. Status: ${response.statusCode}');
      print('Response body: ${response.body}');
    }

    return response.statusCode == 200;
  }

  Future<bool> createAndAssignTask({
    required String title,
    required String description,
    required String dueDate,
    File? file,
    required List<String> internIds,
  }) async {
    try {
      final newTask = await createTask(title: title, description: description, dueDate: dueDate, file: file);
      if (newTask != null) {
        return await assignTaskToInterns(newTask.id, internIds);
      }
      return false;
    } catch (e) {
      print('An error occurred in createAndAssignTask: $e');
      return false;
    }
  }
}
