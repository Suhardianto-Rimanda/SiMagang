// lib/providers/intern_provider.dart

import 'package:flutter/material.dart';
import 'package:app_simagang/api/intern_service.dart';
import 'package:app_simagang/models/task_model.dart';
import 'package:app_simagang/models/learning_module_model.dart';
import 'package:app_simagang/models/activity_report_model.dart';

enum ViewState { idle, loading, error }

class InternProvider with ChangeNotifier {
  final InternService _internService = InternService();

  // State untuk Tugas
  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;
  ViewState _tasksState = ViewState.idle;
  ViewState get tasksState => _tasksState;

  // State untuk Modul
  List<LearningModuleModel> _modules = [];
  List<LearningModuleModel> get modules => _modules;
  ViewState _modulesState = ViewState.idle;
  ViewState get modulesState => _modulesState;

  // State untuk Laporan Aktivitas
  List<ActivityReportModel> _reports = [];
  List<ActivityReportModel> get reports => _reports;
  ViewState _reportsState = ViewState.idle;
  ViewState get reportsState => _reportsState;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  void _setState(ViewState state, String feature) {
    switch (feature) {
      case 'tasks':
        _tasksState = state;
        break;
      case 'modules':
        _modulesState = state;
        break;
      case 'reports':
        _reportsState = state;
        break;
    }
    notifyListeners();
  }

  Future<void> fetchMyTasks() async {
    _setState(ViewState.loading, 'tasks');
    try {
      _tasks = await _internService.getMyTasks();
      _setState(ViewState.idle, 'tasks');
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ViewState.error, 'tasks');
    }
  }

  Future<void> fetchMyLearningModules() async {
    _setState(ViewState.loading, 'modules');
    try {
      _modules = await _internService.getMyLearningModules();
      _setState(ViewState.idle, 'modules');
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ViewState.error, 'modules');
    }
  }

  Future<void> fetchActivityReports() async {
    _setState(ViewState.loading, 'reports');
    try {
      _reports = await _internService.getActivityReports();
      _setState(ViewState.idle, 'reports');
    } catch (e) {
      _errorMessage = e.toString();
      _setState(ViewState.error, 'reports');
    }
  }
}
