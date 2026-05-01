class AppAssets {
  AppAssets._();

  // Root folder path
  static const String basePath = 'assets';
  static const String imagePath = '$basePath/images';
  static const String iconPath = '$basePath/icons';

  // --- Images ---
  static const String logo = '$imagePath/logo.png';
  static const String doctor = '$imagePath/doctor.png';
  static const String doctorProfile = '$imagePath/doctor.png';
  static const String dummyProfile = '$imagePath/doctor.png';
  static const String doctorLogo = '$imagePath/logo.png'; // temporarily point to logo.png
  static const String medicalScan = '$imagePath/medical_scan.png';
  static const String medicalScanModel = '$imagePath/medical_scan_model.png';
  static const String medicalScanBrush = '$imagePath/medical_scan_brush.png';
  static const String aiGradcam = '$imagePath/ai_gradcam.png';
  static const String rawPixels = '$imagePath/raw_pixels.png';
  static const String normalizedView = '$imagePath/normalized.png';

  // --- Icons ---
  static const String icHome = '$iconPath/logo_lumira.png'; // temporarily map missing icon
}
