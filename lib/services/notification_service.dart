import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:developer' as developer;
import '../models/service_model.dart';
import '../models/vehicle_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        developer.log('Notification tapped: ${details.payload}');
      },
    );

    // Request permissions for Android 13+
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleServiceReminder({
    required Vehicle vehicle,
    required ServiceRecord service,
  }) async {
    if (!service.hasReminder || service.reminderDate == null) return;

    // Schedule for 9:00 AM on the reminder date
    final scheduledDate = DateTime(
      service.reminderDate!.year,
      service.reminderDate!.month,
      service.reminderDate!.day,
      9,
      0,
    );

    // If the date has already passed, don't schedule
    if (scheduledDate.isBefore(DateTime.now())) {
      developer.log(
        'Reminder date is in the past, skipping: $scheduledDate',
        name: 'NotificationService',
      );
      return;
    }

    final androidDetails = AndroidNotificationDetails(
      'service_reminders',
      'Service Reminders',
      channelDescription: 'Notifications for upcoming vehicle services',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Use string hash as ID for the notification
    final int notificationId = service.id.hashCode.abs();

    try {
      await _notificationsPlugin.zonedSchedule(
        id: notificationId,
        title: 'Service Reminder: ${vehicle.make} ${vehicle.model}',
        body: 'Next ${service.serviceType} is due today!',
        scheduledDate: tz.TZDateTime.from(scheduledDate, tz.local),
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: service.id,
      );

      developer.log(
        'Scheduled reminder for ${vehicle.make} on $scheduledDate',
        name: 'NotificationService',
      );
    } catch (e) {
      developer.log(
        'Error scheduling notification',
        error: e.toString(),
        name: 'NotificationService',
      );
    }
  }

  Future<void> cancelReminder(String serviceId) async {
    await _notificationsPlugin.cancel(id: serviceId.hashCode.abs());
  }
}
