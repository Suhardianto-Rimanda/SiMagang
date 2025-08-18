import 'supervisor_model.dart';

class InternModel {
  final int id;
  final String fullName;
  final String? division;
  final String? schoolOrigin;
  final String? major;
  final String? gender;
  final String? phoneNumber;
  final String? birthDate;
  final String? startDate;
  final String? endDate;
  final SupervisorModel? supervisor;

  InternModel({
    required this.id,
    required this.fullName,
    this.division,
    this.schoolOrigin,
    this.major,
    this.gender,
    this.phoneNumber,
    this.birthDate,
    this.startDate,
    this.endDate,
    this.supervisor,
  });

  factory InternModel.fromJson(Map<String, dynamic> json) {
    return InternModel(
      id: json['id'],
      fullName: json['full_name'],
      division: json['division'],
      schoolOrigin: json['school_origin'],
      major: json['major'],
      gender: json['gender'],
      phoneNumber: json['phone_number'],
      birthDate: json['birth_date'],
      startDate: json['start_date'],
      endDate: json['end_date'],
      supervisor: json['supervisor'] != null
          ? SupervisorModel.fromJson(json['supervisor'])
          : null,
    );
  }
}