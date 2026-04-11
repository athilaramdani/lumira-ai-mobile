import 'package:flutter/material.dart';

class AppColors {
  // Private constructor agar class ini tidak bisa di-instantiate (di-new)
  AppColors._();

  // --- Warna Utama (Primary & Secondary) ---
  static const Color primary = Color(0xFF0093EE); // Primary Blue
  static const Color primaryLight = Color(0xFF57BEFF);
  static const Color primaryLighter = Color(0xFFA5DBFD);
  static const Color primaryLightest = Color(0xFFCCEBFF);
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
}
