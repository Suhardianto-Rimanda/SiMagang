class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final String supervisorId;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.supervisorId,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      dueDate: DateTime.parse(json['due_date']),
      supervisorId: json['supervisor_id'],
    );
  }
}
