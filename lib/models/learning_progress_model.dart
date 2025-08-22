class LearningProgressModel {
  final String id;
  final String title;
  final String description;
  final String progressStatus;
  final String moduleId;
  final String internId;

  LearningProgressModel({
    required this.id,
    required this.title,
    required this.description,
    required this.progressStatus,
    required this.moduleId,
    required this.internId,
  });

  factory LearningProgressModel.fromJson(Map<String, dynamic> json) {
    return LearningProgressModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      progressStatus: json['progress_status'],
      moduleId: json['module_id'],
      internId: json['intern_id'],
    );
  }
}
