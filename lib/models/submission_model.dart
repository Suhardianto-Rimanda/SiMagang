import 'package:app_simagang/models/intern_model.dart';
import 'submission_attempt_model.dart';

class SubmissionModel {
  final String id;
  final String status;
  final DateTime submissionDate;
  final String taskId;
  final String internId;
  final List<SubmissionAttemptModel> attempts;
  final InternModel? intern; // Menyimpan objek intern jika dikirim oleh API

  SubmissionModel({
    required this.id,
    required this.status,
    required this.submissionDate,
    required this.taskId,
    required this.internId,
    this.attempts = const [],
    this.intern,
  });

  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    var attemptsList = json['attempts'] as List? ?? [];
    List<SubmissionAttemptModel> attempts = attemptsList.map((i) => SubmissionAttemptModel.fromJson(i)).toList();

    return SubmissionModel(
      id: json['id'] ?? '',
      status: json['status'] ?? 'pending',
      submissionDate: DateTime.parse(json['submission_date']),
      taskId: json['task_id'] ?? '',
      internId: json['intern_id'] ?? '',
      attempts: attempts,
      // Mem-parsing objek intern jika ada di dalam JSON
      intern: json['intern'] != null ? InternModel.fromJson(json['intern']) : null,
    );
  }
}
