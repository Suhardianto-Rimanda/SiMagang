import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_simagang/models/task_model.dart';
import 'package:app_simagang/models/learning_module_model.dart';
import 'package:app_simagang/models/activity_report_model.dart';

class InternService {
  final String baseUrl = dotenv.env['BASE_URL']!;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<List<Task>> getMyTasks() async {
    final token = await _getToken();
    if (token == null) throw Exception('Token not found');

    final response = await http.get(
      Uri.parse('$baseUrl/intern-tasks'),
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

  Future<List<LearningModuleModel>> getMyLearningModules() async {
    final token = await _getToken();
    if (token == null) throw Exception('Token not found');

    final response = await http.get(
      Uri.parse('$baseUrl/intern-learning-modules'),
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

  Future<bool> submitTask(String taskId, {File? file, String? text}) async {
    final token = await _getToken();
    if (token == null) throw Exception('Token not found');

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/intern/tasks/$taskId/submit'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.headers['Accept'] = 'application/json';

    if (text != null) {
      request.fields['text_submission'] = text;
    }
    if (file != null) {
      request.files.add(await http.MultipartFile.fromPath('file', file.path));
    }

    final response = await request.send();
    return response.statusCode == 200;
  }

  // Mengirimkan progress pembelajaran
  Future<bool> submitLearningProgress({
    required String moduleId,
    required String title, // Ditambahkan
    required String description,
    required String status,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Token not found');

    final response = await http.post(
      Uri.parse('$baseUrl/intern/learning-progress'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'module_id': moduleId,
        'title': title, // Ditambahkan
        'description': description,
        'progress_status': status,
      }),
    );

    if (response.statusCode == 201) {
      return true;
    } else {
      print('Failed to submit progress. Status: ${response.statusCode}');
      print('Response body: ${response.body}');
      return false;
    }
  }

  Future<List<ActivityReportModel>> getActivityReports() async {
    final token = await _getToken();
    if (token == null) throw Exception('Token not found');

    final response = await http.get(
      Uri.parse('$baseUrl/intern/activity-reports'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => ActivityReportModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load activity reports');
    }
  }

  Future<bool> createActivityReport({
    required String title,
    required String description,
    required String reportDate,
  }) async {
    final token = await _getToken();
    if (token == null) throw Exception('Token not found');

    final response = await http.post(
      Uri.parse('$baseUrl/intern/activity-reports'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'title': title,
        'description': description,
        'report_date': reportDate,
      }),
    );

    return response.statusCode == 201;
  }
}
