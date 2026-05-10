// Firebase options untuk project lumira-ai-6c004
// Mode: LOCAL EMULATOR (Firestore berjalan di localhost:8080)
//
// Catatan: Untuk emulator, API key tidak divalidasi — nilai di bawah aman dipakai lokal.
// Untuk production (connect ke Firebase asli), jalankan: flutterfire configure
// dengan akun Google yang punya akses ke project lumira-ai-6c004.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  // ── Web ─────────────────────────────────────────────────────────────────
  // Nilai ini bekerja dengan emulator lokal.
  // Untuk production, ganti dengan nilai asli dari Firebase Console.
  static FirebaseOptions get web => FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_API_KEY'] ?? '',
    appId: '1:739741054893:web:lumira000000000000',
    messagingSenderId: '739741054893',
    projectId: 'lumira-ai-6c004',
    authDomain: 'lumira-ai-6c004.firebaseapp.com',
    storageBucket: 'lumira-ai-6c004.firebasestorage.app',
  );

  // ── Android ──────────────────────────────────────────────────────────────
  static FirebaseOptions get android => const FirebaseOptions(
    apiKey: 'AIzaSyDOhL4IlsHFoGOjghN77QE8sH-eJ2Bw8G4', // Key dari google-services.json
    appId: '1:739741054893:android:c5a75a654a191140b49324',
    messagingSenderId: '739741054893',
    projectId: 'lumira-ai-6c004',
    storageBucket: 'lumira-ai-6c004.firebasestorage.app',
  );

  // ── iOS ──────────────────────────────────────────────────────────────────
  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: dotenv.env['FIREBASE_API_KEY'] ?? '',
    appId: '1:739741054893:ios:lumira000000000000',
    messagingSenderId: '739741054893',
    projectId: 'lumira-ai-6c004',
    storageBucket: 'lumira-ai-6c004.firebasestorage.app',
    iosBundleId: 'com.dutomasti.lumira.lumiraAiMobile',
  );
}
