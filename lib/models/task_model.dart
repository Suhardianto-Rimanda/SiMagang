import 'submission_model.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String supervisorId;
  final SubmissionModel? submission;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.supervisorId,
    this.submission,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    SubmissionModel? submission;
    if (json['submissions'] != null && (json['submissions'] as List).isNotEmpty) {
      // Ambil submission pertama (karena untuk satu intern hanya ada satu)
      submission = SubmissionModel.fromJson(json['submissions'][0]);
    }
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['due_date']),
      supervisorId: json['supervisor_id'],
      submission: submission,
    );
  }
}
