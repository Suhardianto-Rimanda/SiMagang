import 'learning_progress_model.dart';

class LearningModuleModel {
  final String id;
  final String title;
  final String description;
  final String supervisorId;
  final DateTime createdAt;
  final LearningProgressModel? progress;

  LearningModuleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.supervisorId,
    required this.createdAt,
    this.progress,
  });

  factory LearningModuleModel.fromJson(Map<String, dynamic> json) {
    LearningProgressModel? progress;
    if (json['learning_progress'] != null && (json['learning_progress'] as List).isNotEmpty) {
      // Ambil progress pertama (karena untuk satu intern hanya ada satu progress per modul)
      progress = LearningProgressModel.fromJson(json['learning_progress'][0]);
    }

    return LearningModuleModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      supervisorId: json['supervisor_id'],
      createdAt: DateTime.parse(json['created_at']),
      progress: progress,
    );
  }
}
