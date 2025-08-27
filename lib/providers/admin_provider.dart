// lib/providers/admin_provider.dart

import 'package:flutter/material.dart';
import 'package:app_simagang/api/admin_service.dart';
import 'package:app_simagang/models/activity_report_model.dart';
import 'package:app_simagang/models/learning_progress_model.dart';

enum ViewState { idle, loading, error }

class AdminProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();

  List<ActivityReportModel> _reports = [];
  List<ActivityReportModel> get reports => _reports;
  ViewState _reportsState = ViewState.idle;
  ViewState get reportsState => _reportsState;

  List<LearningProgressModel> _progresses = [];
  List<LearningProgressModel> get progresses => _progresses;
  ViewState _progressesState = ViewState.idle;
  ViewState get progressesState => _progressesState;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  void _setState(ViewState state, String feature) {
    switch (feature) {
      case 'reports':
        _reportsState = state;
        break;
      case 'progresses':
        _progressesState = state;
        break;
    }
    notifyListeners();
  }

  Future<void> fetchAllActivityReports() async {
    _setState(ViewState.loading, 'reports');
    try {
      _reports = await _adminService.getAllActivityReports();
      _setState(ViewState.idle, 'reports');
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ViewState.error, 'reports');
    }
  }

  Future<void> fetchAllLearningProgress() async {
    _setState(ViewState.loading, 'progresses');
    try {
      _progresses = await _adminService.getAllLearningProgress();
      _setState(ViewState.idle, 'progresses');
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ViewState.error, 'progresses');
    }
  }
}
