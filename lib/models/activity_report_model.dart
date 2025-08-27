class ActivityReportModel {
  final String id;
  final String? reportType;
  final String title;
  final String? description;
  final DateTime reportDate;
  final String internId;

  ActivityReportModel({
    required this.id,
    this.reportType,
    required this.title,
    this.description,
    required this.reportDate,
    required this.internId,
  });

  factory ActivityReportModel.fromJson(Map<String, dynamic> json) {
    return ActivityReportModel(
      id: json['id'] ?? '',
      reportType: json['report_type'],
      title: json['title'] ?? 'Tanpa Judul',
      description: json['description'],
      reportDate: DateTime.parse(json['report_date']),
      internId: json['intern_id'] ?? '',
    );
  }
}
