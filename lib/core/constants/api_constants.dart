class ApiConstants {
  // Base URLs
  static const String baseUrl = 'https://apilumiraai.vercel.app';

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String refresh = '/auth/refresh-token';
  static const String me = '/auth/me';

  // Users Endpoints
  static const String users = '/users';

  // Patients & Medical Records Endpoints
  static const String patients = '/patients';
  static const String uploadMedicalRecord = '/medical-records/upload';
  
  static String reviewMedicalRecord(String id) => '/medical-records/$id/review';
  static String reanalyzePatient(String id) => '/patients/$id/reanalyze';
  static String user(String id) => '/users/$id';

  // Statistics & Activities
  static const String statsDashboard = '/stats/dashboard';
  static const String statsDoctor = '/stats/doctor';
  static const String activities = '/activities';

  // Healthcheck
  static const String health = '/health';
}
