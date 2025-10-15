import 'package:flutter/material.dart';
import 'package:app_simagang/api/supervisor_service.dart';
import 'package:app_simagang/models/user_model.dart';
import 'package:app_simagang/models/activity_report_model.dart';
import 'package:app_simagang/models/learning_progress_model.dart';

enum ViewState { idle, loading, error }

class SupervisorProvider with ChangeNotifier {
  final SupervisorService _supervisorService = SupervisorService();

  List<UserModel> _interns = [];
  List<UserModel> get interns => _interns;
  ViewState _internsState = ViewState.idle;
  ViewState get internsState => _internsState;

  List<LearningProgressModel> _progresses = [];
  List<LearningProgressModel> get progresses => _progresses;
  ViewState _progressesState = ViewState.idle;
  ViewState get progressesState => _progressesState;

  List<ActivityReportModel> _activityReports = [];
  List<ActivityReportModel> get activityReports => _activityReports;
  ViewState _activityReportsState = ViewState.idle;
  ViewState get activityReportsState => _activityReportsState;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  void _setState(ViewState state, String feature) {
    switch (feature) {
      case 'interns':
        _internsState = state;
        break;
      case 'progresses':
        _progressesState = state;
        break;
      case 'activityReports':
        _activityReportsState = state;
        break;
    }
    notifyListeners();
  }

  Future<void> fetchSupervisorInterns() async {
    _setState(ViewState.loading, 'interns');
    try {
      _interns = await _supervisorService.getSupervisorInterns();
      _setState(ViewState.idle, 'interns');
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ViewState.error, 'interns');
    }
  }

  Future<void> fetchLearningProgress() async {
    _setState(ViewState.loading, 'progresses');
    try {
      _progresses = await _supervisorService.getLearningProgress();
      _setState(ViewState.idle, 'progresses');
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ViewState.error, 'progresses');
    }
  }

  Future<void> fetchActivityReports() async {
    _setState(ViewState.loading, 'activityReports');
    try {
      _activityReports = await _supervisorService.getActivityReports();
      _setState(ViewState.idle, 'activityReports');
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ViewState.error, 'activityReports');
    }
  }
}
