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

    final records = json['medical_records'] != null
        ? (json['medical_records'] as List)
            .map((i) => MedicalRecordModel.fromJson(i))
            .toList()
        : <MedicalRecordModel>[];

    // Ambil latestRecord dari field eksplisit jika ada,
    // atau sort medical_records by uploadedAt descending.
    MedicalRecordModel? latestRecord;
    if (json['latestRecord'] != null) {
      latestRecord = MedicalRecordModel.fromJson(json['latestRecord']);
    } else if (records.isNotEmpty) {
      final sorted = [...records]
        ..sort((a, b) {
          final dateA = DateTime.tryParse(a.createdAt ?? '') ?? DateTime(0);
          final dateB = DateTime.tryParse(b.createdAt ?? '') ?? DateTime(0);
          return dateB.compareTo(dateA);
        });
      latestRecord = sorted.first;
    }


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

      medicalRecords: records.isNotEmpty ? records : null,
      latestRecord: latestRecord,



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
