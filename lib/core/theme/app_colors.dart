import 'package:flutter/material.dart';

class AppColors {
  // Private constructor agar class ini tidak bisa di-instantiate (di-new)
  AppColors._();

  // --- Warna Utama (Primary & Secondary) ---
  static const Color primary = Color(0xFF0D6EFD); // Contoh Biru Lumira
  static const Color secondary = Color(0xFF6C757D);

  // --- Background & Surface ---
  static const Color background = Color(0xFFF8F9FA); // Warna layar belakang
  static const Color surface = Colors.white; // Warna card atau container

  // --- Teks ---
  static const Color textPrimary = Color(0xFF212529); // Teks utama/judul
  static const Color textSecondary = Color(0xFF6C757D); // Teks deskripsi/sub

  // --- Status & feedback (Error, Success, dll) ---
  static const Color success = Color(0xFF198754);
  static const Color error = Color(0xFFDC3545);
  static const Color warning = Color(0xFFFFC107);

  // --- Warna Tambahan untuk Status AI ---
  static const Color statusNormal = Color(0xFF4CAF50);
  static const Color statusBenign = Color(0xFF42A5F5);
  static const Color statusMalignant = Color(0xFFF44336);
  static const Color statusUnknown = Color(0xFFFFC107);
  static const Color statusMissing = Color(0xFFFF9800);

  // --- Warna Tombol & Aksi ---
  static const Color btnReview = Color(0xFF64B5F6);
  static const Color btnReviewNeeded = Color(0xFFFFD54F);
  static const Color btnDone = Color(0xFF64DD17);
  static const Color btnChat = Color(0xFFFFA000);
}
