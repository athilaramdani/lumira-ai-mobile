import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Manages Firebase initialization: emulator (debug) vs production (release).
class FirebaseService {
  // ── Emulator config ──────────────────────────────────────────────────────
  static const String _emulatorHost = 'localhost';
  static const int _firestorePort = 8080;

  /// Call once at app startup, AFTER Firebase.initializeApp().
  static Future<void> initialize() async {
    // Connect to local emulator in debug mode
    if (kDebugMode) {
      await _connectToEmulator();
    }

    // FCM setup (push notifications) — skip on web since web FCM needs VAPID key
    if (!kIsWeb) {
      await _initFCM();
    }
  }

  // ── Emulator ─────────────────────────────────────────────────────────────
  static Future<void> _connectToEmulator() async {
    try {
      FirebaseFirestore.instance.useFirestoreEmulator(
        _emulatorHost,
        _firestorePort,
      );
      debugPrint('[Firebase] 🔧 Connected to Firestore emulator at $_emulatorHost:$_firestorePort');
    } catch (e) {
      debugPrint('[Firebase] ⚠️ Could not connect to emulator: $e');
    }
  }

  // ── FCM (Push Notifications) ──────────────────────────────────────────────
  static Future<void> _initFCM() async {
    try {
      final messaging = FirebaseMessaging.instance;

      // Request permission
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      debugPrint('[FCM] Permission: ${settings.authorizationStatus}');

      // Log device token
      final token = await messaging.getToken();
      debugPrint('[FCM] Token: $token');

      // Foreground message handler
      FirebaseMessaging.onMessage.listen((message) {
        debugPrint('[FCM] Foreground: ${message.notification?.title}');
      });

      // Background notification tap
      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        debugPrint('[FCM] Tapped: ${message.data}');
      });
    } catch (e) {
      debugPrint('[FCM] Init error: $e');
    }
  }

  static Future<String?> getToken() async {
    if (kIsWeb) return null;
    return FirebaseMessaging.instance.getToken();
  }
}
