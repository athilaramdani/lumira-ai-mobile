class StatisticModel {
  final int totalPatients;
  final int totalRecords;
  final int totalDoctors;
  final Map<String, dynamic>? extraKpiData;

  StatisticModel({
    this.totalPatients = 0,
    this.totalRecords = 0,
    this.totalDoctors = 0,
    this.extraKpiData,
  });

  factory StatisticModel.fromJson(Map<String, dynamic> json) {
    return StatisticModel(
      totalPatients: json['totalPatients'] ?? 0,
      totalRecords: json['totalRecords'] ?? 0,
      totalDoctors: json['totalDoctors'] ?? 0,
      extraKpiData: json['extraKpiData'],
    );
  }
}
