import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // --- Warna Utama (Primary & Secondary) ---
  static const Color primary = Color(0xFF0398F6); // Biru Lumira dari desain UI
  static const Color primaryLight = Color(0xFFE3F4FE); // Background active button dll
  static const Color primaryLighter = Color(0xFFA5DBFD);
  static const Color primaryLightest = Color(0xFFCCEBFF);
  static const Color secondary = Color(0xFF6C757D);

  // --- Background & Surface ---
  static const Color background = Color(0xFFF2F5F8); // Warna layar belakang sedikit bluish gray
  static const Color surface = Colors.white; // Warna card atau container
  static const Color border = Color(0xFFE2E8F0); // Warna outline card
  static const Color headerGradientStart = Color(0xFF5AB6FF);
  static const Color headerGradientEnd = Color(0xFFDFF0FF);

  // --- Teks ---
  static const Color textPrimary = Color(0xFF1E293B); // Teks utama/judul
  static const Color textSecondary = Color(0xFF64748B); // Teks deskripsi/sub
  static const Color textLight = Colors.white;

  // --- Status & feedback (Error, Success, dll) ---
  static const Color success = Color(0xFF198754);
  static const Color error = Color(0xFFDC3545);
  static const Color warning = Color(0xFFFFC107);

  // --- Doctor Dashboard & Features ---
  static const Color btnReview = Color(0xFF0398F6);
  static const Color btnReviewNeeded = Color(0xFFFF9800);
  static const Color btnDone = Color(0xFF4CAF50);
  static const Color btnChat = Color(0xFF9C27B0);
  
  // --- Status Colors ---
  static const Color statusNormal = Color(0xFF4CAF50);
  static const Color statusBenign = Color(0xFFFF9800);
  static const Color statusMalignant = Color(0xFFF44336);
  static const Color statusUnknown = Color(0xFF9E9E9E);

  static const Color pending = Color(0xFFFF9800);
  static const Color pendingLight = Color(0xFFFFF3E0);
  static const Color warningLight = Color(0xFFFFF8E1);
}
