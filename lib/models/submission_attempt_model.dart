class SubmissionAttemptModel {
  final String id;
  final String filePath;
  final String submissionId;
  final DateTime uploadedAt;

  SubmissionAttemptModel({
    required this.id,
    required this.filePath,
    required this.submissionId,
    required this.uploadedAt,
  });

  factory SubmissionAttemptModel.fromJson(Map<String, dynamic> json) {
    return SubmissionAttemptModel(
      id: json['id'],
      filePath: json['file_path'],
      submissionId: json['submission_id'],
      uploadedAt: DateTime.parse(json['uploaded_at']),
    );
  }
}
