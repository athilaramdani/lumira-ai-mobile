import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import '../../main.dart';
import '../../firebase_options.dart';

// Background handler moved to main.dart

/// Manages Firebase initialization. Always connects to PRODUCTION Firebase.
class FirebaseService {
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  /// Call once at app startup, AFTER Firebase.initializeApp().
  static Future<void> initialize() async {
    // NOTE: Never connect to emulator here — always use production Firestore.
    // The emulator was previously enabled in kDebugMode which caused chat messages
    // to point at localhost:8080 and appear empty on real devices.

    // FCM setup (push notifications) — skip on web since web FCM needs VAPID key
    if (!kIsWeb) {
      await initLocalNotifications();
      await _initFCM();
    }
  }

  static Future<void> initLocalNotifications() async {
    try {
      const androidInit = AndroidInitializationSettings('ic_launcher');
      const initSettings = InitializationSettings(android: androidInit);
      await _localNotifications.initialize(settings: initSettings);

      // Explicitly request Android 13+ notification permissions
      if (Platform.isAndroid) {
        await _localNotifications
            .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin>()
            ?.requestNotificationsPermission();
      }

      debugPrint('[FCM] Local notifications initialized');
    } catch (e) {
      debugPrint('[FCM] Error initializing local notifications: $e');
    }
  }

  static void showLocalNotification(RemoteMessage message) {
    final title = message.notification?.title ?? message.data['title'] ?? 'Pesan Baru';
    final body = message.notification?.body ?? message.data['body'] ?? message.data['message'] ?? 'Anda menerima pesan baru.';

    const androidDetails = AndroidNotificationDetails(
      'chat_channel',
      'Chat Notifications',
      importance: Importance.max,
      priority: Priority.high,
      icon: 'ic_launcher',
    );
    const details = NotificationDetails(android: androidDetails);
    
    _localNotifications.show(
      id: message.messageId?.hashCode ?? DateTime.now().millisecond,
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  // ── FCM (Push Notifications) ──────────────────────────────────────────────
  static Future<void> _initFCM() async {
    try {
      final messaging = FirebaseMessaging.instance;

      // Request permission (mostly for iOS, Android 13 handled by local_notifications)
      messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      ).then((settings) {
        debugPrint('[FCM] Permission: ${settings.authorizationStatus}');
      });

      // Log device token
      final token = await messaging.getToken();
      debugPrint('[FCM] Token: $token');

      // iOS foreground notification presentation
      await messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      // Register background handler (Moved to main.dart)
      // FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Foreground message handler
      FirebaseMessaging.onMessage.listen((message) {
        debugPrint('>>>>>>>>>> [FCM] FOREGROUND MESSAGE EVENT FIRED! <<<<<<<<<<');
        debugPrint('[FCM] Foreground data: ${message.data}');
        
        final title = message.notification?.title ?? message.data['title'] ?? 'Pesan Baru';
        final body = message.notification?.body ?? message.data['body'] ?? message.data['message'] ?? 'Anda menerima pesan baru.';

        // Tampilkan SnackBar di dalam aplikasi (Foreground UI)
        globalMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text('$title\n$body'),
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
            dismissDirection: DismissDirection.down,
            duration: const Duration(seconds: 4),
            backgroundColor: Colors.blue.shade800,
            action: SnackBarAction(
              label: 'Lihat',
              textColor: Colors.white,
              onPressed: () {
                // Bisa diarahkan ke halaman chat
              },
            ),
          ),
        );

        // Opsional: Tetap tampilkan heads-up notification lewat system
        showLocalNotification(message);
      });
      debugPrint('[FCM] onMessage listener registered!');

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

  // ── Token Management with Backend ───────────────────────────────────────
  static Future<void> registerDeviceToken(Dio dio) async {
    if (kIsWeb) return;
    try {
      final token = await getToken();
      if (token != null) {
        await dio.post('/chat/device-tokens', data: {
          'fcmToken': token,
          'platform': Platform.operatingSystem,
        });
        debugPrint('[FCM] Token registered to backend successfully');
      }
    } catch (e) {
      debugPrint('[FCM] Failed to register token to backend: $e');
    }
  }

  static Future<void> removeDeviceToken(Dio dio) async {
    if (kIsWeb) return;
    try {
      final token = await getToken();
      if (token != null) {
        await dio.post('/chat/device-tokens/remove', data: {
          'fcmToken': token,
        });
        debugPrint('[FCM] Token removed from backend successfully');
      }
    } catch (e) {
      debugPrint('[FCM] Failed to remove token from backend: $e');
    }
  }
}
