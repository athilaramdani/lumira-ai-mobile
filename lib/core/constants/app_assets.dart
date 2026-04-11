class AppAssets {
  AppAssets._();

  // Root folder path
  static const String basePath = 'assets';
  static const String imagePath = '$basePath/images';
  static const String iconPath = '$basePath/icons';

  // --- Images ---
  // Taruh file logo.png di folder /assets/images/
  static const String logo = '$imagePath/logo.png';
  static const String doctorLogo = '$iconPath/logo_lumira.png'; // Reusing logo_lumira.png as the unicorn logo
  static const String dummyProfile = '$imagePath/dummy_profile.png';
  static const String doctorProfile = '$imagePath/doctor.png';
  static const String medicalScanModel = '$imagePath/medical_scan_model.png';
  static const String medicalScanBrush = '$imagePath/medical_scan_brush.png';

  // --- Icons ---
  // Taruh file ic_home.png di folder /assets/icons/
  static const String icHome = '$iconPath/ic_home.png';
}
