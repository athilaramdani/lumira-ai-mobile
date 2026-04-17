class PatientModel {
  final String? id;
  final String? name;
  final String? gender;
  final String? dateOfBirth;
  final String? bloodType;
  final String? medicalHistory;
  final String? contactNumber;
  final String? address;

  PatientModel({
    this.id,
    this.name,
    this.gender,
    this.dateOfBirth,
    this.bloodType,
    this.medicalHistory,
    this.contactNumber,
    this.address,
  });

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id']?.toString(),
      name: json['name'],
      gender: json['gender'],
      dateOfBirth: json['dateOfBirth'],
      bloodType: json['bloodType'],
      medicalHistory: json['medicalHistory'],
      contactNumber: json['contactNumber'],
      address: json['address'],
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
