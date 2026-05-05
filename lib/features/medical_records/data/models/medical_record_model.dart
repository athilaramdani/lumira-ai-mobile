class MedicalRecordModel {
  final String? id;
  final String? patientId;
  final String? imageUrl;
  final String? resultLabel;
  final double? resultConfidence;
  final String? doctorNotes;
  final String? createdAt;
  final String? validationStatus;
  final String? doctorDiagnosis;
  final String? gradcamImageUrl;
  final String? agreement;

  MedicalRecordModel({
    this.id,
    this.patientId,
    this.imageUrl,
    this.resultLabel,
    this.resultConfidence,
    this.doctorNotes,
    this.createdAt,
    this.validationStatus,
    this.doctorDiagnosis,
    this.gradcamImageUrl,
    this.agreement,
  });

  factory MedicalRecordModel.fromJson(Map<String, dynamic> json) {
    return MedicalRecordModel(
      id: json['id'],
      patientId: json['patient_id'] ?? json['patientId'],
      imageUrl: json['original_image_path'] ?? json['image_url'] ?? json['imageUrl'],
      resultLabel: json['ai_diagnosis'] ?? json['result_label'] ?? json['resultLabel'],
      resultConfidence: (json['ai_confidence'] ?? json['result_confidence'] ?? json['resultConfidence'])?.toDouble(),
      doctorNotes: json['doctor_notes'] ?? json['doctorNotes'],
      createdAt: json['uploaded_at'] ?? json['created_at'] ?? json['createdAt'],
      validationStatus: json['validation_status'] ?? json['validationStatus'] ?? json['status'],
      doctorDiagnosis: json['doctor_diagnosis'] ?? json['doctorDiagnosis'],
      gradcamImageUrl: json['ai_gradcam_path'] ?? json['gradcam_image_url'] ?? json['gradcamImageUrl'],
      agreement: json['agreement'],
    );
  }
}
