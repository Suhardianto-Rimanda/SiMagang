class LearningModuleModel {
  final String id;
  final String title;
  final String description;
  final String supervisorId;
  final DateTime createdAt;

  LearningModuleModel({
    required this.id,
    required this.title,
    required this.description,
    required this.supervisorId,
    required this.createdAt,
  });

  factory LearningModuleModel.fromJson(Map<String, dynamic> json) {
    return LearningModuleModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      supervisorId: json['supervisor_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
