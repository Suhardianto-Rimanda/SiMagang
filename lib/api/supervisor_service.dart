import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_simagang/models/user_model.dart';
import 'package:app_simagang/models/intern_model.dart';
import 'package:app_simagang/models/submission_model.dart';
import 'package:app_simagang/models/learning_progress_model.dart';

class SupervisorService {
  final String baseUrl = dotenv.env['BASE_URL']!;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

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

      return data
          .whereType<Map<String, dynamic>>()
          .map((internJson) {
        InternModel internData = InternModel.fromJson(internJson);

        UserModel user = UserModel(
          id: internJson['user_id']?.toString() ?? '',
          name: internData.fullName, // Mengambil nama dari fullName di data intern
          email: internJson['user']?['email'] ?? 'Email tidak tersedia', // Coba ambil email jika ada, jika tidak, beri default
          role: UserRole.intern,
          intern: internData,
        );

        return user;
      })
          .toList();

    } else {
      throw Exception('Failed to load interns. Status: ${response.statusCode}');
    }
  }

  Future<List<LearningProgressModel>> getLearningProgress() async {
    final token = await _getToken();
    if (token == null) throw Exception('Token not found');

    final response = await http.get(
      Uri.parse('$baseUrl/supervisor/learning-progress'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['data'];
      return data
          .whereType<Map<String, dynamic>>()
          .map((json) => LearningProgressModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load learning progress. Status: ${response.statusCode}');
    }
  }

  Future<List<LearningProgressModel>> getModuleProgress(String moduleId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Token not found');

    final response = await http.get(
      Uri.parse('$baseUrl/modules/$moduleId/learning-progress'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['data'];
      return data
          .whereType<Map<String, dynamic>>()
          .map((json) => LearningProgressModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load module progress');
    }
  }

  Future<List<SubmissionModel>> getTaskSubmissions(String taskId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Token not found');

    final response = await http.get(
      Uri.parse('$baseUrl/tasks/$taskId/submissions'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['data'];
      return data
          .whereType<Map<String, dynamic>>()
          .map((json) => SubmissionModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load task submissions');
    }
  }

  Future<List<LearningProgressModel>> getInternProgress(String internId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Token not found');

    final response = await http.get(
      Uri.parse('$baseUrl/supervisor/interns/$internId/learning-progress'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['data'];
      return data
          .whereType<Map<String, dynamic>>()
          .map((json) => LearningProgressModel.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load intern progress');
    }
  }
}
