import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📨 Background message: ${message.notification?.title}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  final SupabaseClient _supabase = Supabase.instance.client;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// Initialize Firebase Cloud Messaging and Local Notifications
  Future<void> initialize() async {
    if (kIsWeb) {
      print('🌐 Notifications skipped on Web');
      return;
    }
    try {
      // Request permissions
      final settings = await _fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('🔔 Notification permission: ${settings.authorizationStatus}');

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        // Initialize local notifications
        await _initializeLocalNotifications();

        // Get FCM token
        _fcmToken = await _fcm.getToken();
        print('🎯 FCM Token: $_fcmToken');

        // Save token to Supabase (optional - for sending targeted notifications)
        if (_fcmToken != null) {
          await _saveFcmTokenToSupabase(_fcmToken!);
        }

        // Listen to token refresh
        _fcm.onTokenRefresh.listen(_saveFcmTokenToSupabase);

        // Set up message handlers
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
        FirebaseMessaging.onBackgroundMessage(
            _firebaseMessagingBackgroundHandler);

        // Check if app was opened from notification
        final initialMessage = await _fcm.getInitialMessage();
        if (initialMessage != null) {
          _handleMessageOpenedApp(initialMessage);
        }

        print('✅ Notification service initialized');
      } else {
        print('❌ Notification permission denied');
      }
    } catch (e) {
      print('❌ Error initializing notifications: $e');
    }
  }

  /// Initialize local notifications for Android/iOS
  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    const androidChannel = AndroidNotificationChannel(
      'train_booking_channel',
      'Train Booking Notifications',
      description: 'Notifications for booking confirmations and trip updates',
      importance: Importance.high,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Handle foreground messages (app is open)
  void _handleForegroundMessage(RemoteMessage message) {
    print('📨 Foreground message: ${message.notification?.title}');

    // Show local notification when app is in foreground
    _showLocalNotification(
      title: message.notification?.title ?? 'Train Booking',
      body: message.notification?.body ?? '',
      payload: message.data.toString(),
    );
  }

  /// Handle when user taps on notification
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('👆 User tapped notification: ${message.notification?.title}');
    // TODO: Navigate to specific screen based on message.data
  }

  /// Handle local notification tap
  void _onNotificationTapped(NotificationResponse response) {
    print('👆 Local notification tapped: ${response.payload}');
    // TODO: Navigate based on payload
  }

  /// Show a local notification
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'train_booking_channel',
      'Train Booking Notifications',
      channelDescription:
          'Notifications for booking confirmations and trip updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Save FCM token to Supabase for targeted notifications
  Future<void> _saveFcmTokenToSupabase(String token) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Update passenger table with FCM token
      await _supabase.from('passenger').update({
        'fcm_token': token,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('PassengerID', userId);

      print('✅ FCM token saved to Supabase');
    } catch (e) {
      print('❌ Error saving FCM token: $e');
    }
  }

  /// Send booking confirmation notification
  Future<void> sendBookingConfirmation({
    required String bookingReference,
    required String trainName,
    required String origin,
    required String destination,
    required DateTime departureTime,
  }) async {
    await _showLocalNotification(
      title: '✅ Booking Confirmed!',
      body:
          'Your ticket for $trainName from $origin to $destination is confirmed. Ref: $bookingReference',
      payload: 'booking:$bookingReference',
    );
  }

  /// Schedule trip reminder notification (24 hours before)
  Future<void> scheduleTripReminder({
    required String bookingReference,
    required String trainName,
    required DateTime departureTime,
  }) async {
    // Calculate notification time (24 hours before departure)
    final notificationTime = departureTime.subtract(const Duration(hours: 24));

    if (notificationTime.isAfter(DateTime.now())) {
      // Note: For production, use a proper scheduling mechanism
      // This is a simplified version
      print('⏰ Trip reminder scheduled for $notificationTime');

      // TODO: Implement with flutter_local_notifications scheduling
      // or Supabase Edge Functions with cron jobs
    }
  }

  /// Send immediate test notification
  Future<void> sendTestNotification() async {
    await _showLocalNotification(
      title: '🚂 Train Booking App',
      body: 'Test notification - Everything is working!',
      payload: 'test',
    );
  }
}
