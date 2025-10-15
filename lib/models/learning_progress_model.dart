class LearningProgressModel {
  final String id;
  final String description;
  final String progressStatus;

  final String moduleId;
  final String internId;

  final String? moduleTitle;
  final String? internName;

  LearningProgressModel({
    required this.id,
    this.description = '',
    required this.progressStatus,
    required this.moduleId,
    required this.internId,
    this.moduleTitle,
    this.internName,
  });

  factory LearningProgressModel.fromJson(Map<String, dynamic> json) {
    return LearningProgressModel(
      id: json['id'] ?? '',
      description: json['description'] ?? '',
      progressStatus: json['progress_status'] ?? 'pending',
      moduleId: json['module_id'] ?? '',
      internId: json['intern_id'] ?? '',
      moduleTitle: json['module']?['title'],
      internName: json['intern']?['user']?['name'],
    );
  }
}
