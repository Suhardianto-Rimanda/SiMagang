import 'submission_attempt_model.dart';

class SubmissionModel {
  final String id;
  final String status;
  final DateTime submissionDate;
  final String taskId;
  final String internId;
  final List<SubmissionAttemptModel> attempts;

  SubmissionModel({
    required this.id,
    required this.status,
    required this.submissionDate,
    required this.taskId,
    required this.internId,
    this.attempts = const [],
  });

  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    var attemptsList = json['attempts'] as List? ?? [];
    List<SubmissionAttemptModel> attempts = attemptsList.map((i) => SubmissionAttemptModel.fromJson(i)).toList();

    return SubmissionModel(
      id: json['id'],
      status: json['status'],
      submissionDate: DateTime.parse(json['submission_date']),
      taskId: json['task_id'],
      internId: json['intern_id'],
      attempts: attempts,
    );
  }
}
