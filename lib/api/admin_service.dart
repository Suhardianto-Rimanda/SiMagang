// lib/api/admin_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:app_simagang/models/activity_report_model.dart';
import 'package:app_simagang/models/learning_progress_model.dart';

class AdminService {
  final String baseUrl = dotenv.env['BASE_URL']!;

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Mengambil semua laporan aktivitas dari semua intern
  Future<List<ActivityReportModel>> getAllActivityReports() async {
    final token = await _getToken();
    if (token == null) throw Exception('Token not found');

    // CATATAN: Pastikan endpoint ini ada di backend Anda
    final response = await http.get(
      Uri.parse('$baseUrl/admin/activity-reports'),
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

  // Mengambil semua progres pembelajaran dari semua intern
  Future<List<LearningProgressModel>> getAllLearningProgress() async {
    final token = await _getToken();
    if (token == null) throw Exception('Token not found');

    // CATATAN: Pastikan endpoint ini ada di backend Anda
    final response = await http.get(
      Uri.parse('$baseUrl/admin/learning-progress'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body)['data'];
      return data.map((json) => LearningProgressModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load learning progress');
    }
  }
}
