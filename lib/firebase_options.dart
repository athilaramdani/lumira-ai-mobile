// Firebase options untuk project lumira-ai-6c004
// Mode: LOCAL EMULATOR (Firestore berjalan di localhost:8080)
//
// Catatan: Untuk emulator, API key tidak divalidasi — nilai di bawah aman dipakai lokal.
// Untuk production (connect ke Firebase asli), jalankan: flutterfire configure
// dengan akun Google yang punya akses ke project lumira-ai-6c004.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'emulator-fake-api-key',
    appId: '1:000000000000:web:lumira000000000000',
    messagingSenderId: '000000000000',
    projectId: 'lumira-ai-6c004',
    authDomain: 'lumira-ai-6c004.firebaseapp.com',
    storageBucket: 'lumira-ai-6c004.firebasestorage.app',
  );

  // ── Android ──────────────────────────────────────────────────────────────
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'emulator-fake-api-key',
    appId: '1:000000000000:android:lumira000000000000',
    messagingSenderId: '000000000000',
    projectId: 'lumira-ai-6c004',
    storageBucket: 'lumira-ai-6c004.firebasestorage.app',
  );

  // ── iOS ──────────────────────────────────────────────────────────────────
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'emulator-fake-api-key',
    appId: '1:000000000000:ios:lumira000000000000',
    messagingSenderId: '000000000000',
    projectId: 'lumira-ai-6c004',
    storageBucket: 'lumira-ai-6c004.firebasestorage.app',
    iosBundleId: 'com.dutomasti.lumira.lumiraAiMobile',
  );
}
