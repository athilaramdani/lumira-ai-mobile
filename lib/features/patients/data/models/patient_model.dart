import 'package:lumira_ai_mobile/features/medical_records/data/models/medical_record_model.dart';

class PatientModel {
  final String? id;
  final String? name;
  final String? email;
  final String? gender;
  final String? dateOfBirth;
  final String? bloodType;
  final String? medicalHistory;
  final String? contactNumber;
  final String? address;
  final List<MedicalRecordModel>? medicalRecords;
  final MedicalRecordModel? latestRecord;

  PatientModel({
    this.id,
    this.name,
    this.email,
    this.gender,
    this.dateOfBirth,
    this.bloodType,
    this.medicalHistory,
    this.contactNumber,
    this.address,
    this.medicalRecords,
    this.latestRecord,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id']?.toString(),
      name: json['name'],
      email: json['email'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'],
      bloodType: json['bloodType'],
      medicalHistory: json['medicalHistory'],
      contactNumber: json['contactNumber'] ?? json['phone'],
      address: json['address'],
      medicalRecords: json['medical_records'] != null
          ? (json['medical_records'] as List).map((i) => MedicalRecordModel.fromJson(i)).toList()
          : null,
      latestRecord: json['latestRecord'] != null
          ? MedicalRecordModel.fromJson(json['latestRecord'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'bloodType': bloodType,
      'medicalHistory': medicalHistory,
      'contactNumber': contactNumber,
      'address': address,
    };
  }
}
