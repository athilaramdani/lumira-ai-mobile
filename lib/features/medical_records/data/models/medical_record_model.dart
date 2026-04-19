class MedicalRecordModel {
  final String? id;
  final String? patientId;
  final String? imageUrl;
  final String? resultLabel;
  final double? resultConfidence;
  final String? doctorNotes;
  final String? createdAt;

  MedicalRecordModel({
    this.id,
    this.patientId,
    this.imageUrl,
    this.resultLabel,
    this.resultConfidence,
    this.doctorNotes,
    this.createdAt,
  });

  factory MedicalRecordModel.fromJson(Map<String, dynamic> json) {
    return MedicalRecordModel(
      id: json['id'],
      patientId: json['patient_id'] ?? json['patientId'],
      imageUrl: json['image_url'] ?? json['imageUrl'],
      resultLabel: json['result_label'] ?? json['resultLabel'],
      resultConfidence: (json['result_confidence'] ?? json['resultConfidence'])?.toDouble(),
      doctorNotes: json['doctor_notes'] ?? json['doctorNotes'],
      createdAt: json['created_at'] ?? json['createdAt'],
    );
  }
}
