import 'intern_model.dart';

class SupervisorModel {
  final int id;
  final String fullName;
  final String? division;
  final List<InternModel>? interns; // Relasi ke banyak Intern

  SupervisorModel({
    required this.id,
    required this.fullName,
    this.division,
    this.interns,
  });

  factory SupervisorModel.fromJson(Map<String, dynamic> json) {
    // Mengambil list intern jika ada
    var internList = json['interns'] as List?;
    List<InternModel>? interns;
    if (internList != null) {
      interns = internList.map((i) => InternModel.fromJson(i)).toList();
    }

    return SupervisorModel(
      id: json['id'],
      fullName: json['full_name'],
      division: json['division'],
      interns: interns,
    );
  }
}
