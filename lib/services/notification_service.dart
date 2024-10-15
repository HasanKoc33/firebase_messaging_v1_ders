import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;

/// bildirim hizmeti
class NotificationService {
  NotificationService._();

  static NotificationService? _instance;

  static NotificationService get instance =>
      _instance ??= NotificationService._();

  final _flnp = FlutterLocalNotificationsPlugin();


  String? blochedId;

  /// bildirim dinleyicisi
  final StreamController<String?> selectNotificationStream =
      StreamController<String?>.broadcast();

  void listen(NotificationResponse notificationResponse) {
    if (notificationResponse.payload == null) return;
    selectNotificationStream.add(notificationResponse.payload);
  }

  /// bildirim kurulumu
  Future<void> initalize() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');
    const initializationSettingsDarwin = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );
    await _flnp.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            listen(notificationResponse);
            break;
          case NotificationResponseType.selectedNotificationAction:
            if (notificationResponse.actionId == '') {
              listen(notificationResponse);
            }
            break;
        }
      },
      //onDidReceiveBackgroundNotificationResponse: listenBack,
    );
  }

  /// bidirim göster
  Future<void> showNotification(RemoteMessage message) async {
    if(message.messageId == blochedId) return;

    final info =  BigTextStyleInformation(
            message.notification?.body ?? '',
            htmlFormatBigText: true,
            contentTitle: message.notification?.title,
            htmlFormatContentTitle: true,
          );

    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'test',
      'test',
      importance: Importance.max,
      styleInformation: info,
      priority: Priority.max,
      icon: 'ic_launcher',
    );
    final detail = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: const DarwinNotificationDetails(
        attachments: [],
      ),
    );
    print('bildirim gideyorr');
    await _flnp.show(
      1,
      message.notification?.title,
      message.notification?.body,
      detail,
      payload: json.encode(message.data),
    );
  }

  /// bildirime tıklandığında
  Future<void> openNotification(RemoteMessage message) async {
    print('----------openNotification --------------');
  }


  /// bildirimi iptal et
  Future<void> cancelNotification(int id) async => _flnp.cancel(id);







  StreamSubscription?  subscriptionFirebase;
  StreamSubscription?  subscriptionLocal;
  void listenOnTapNotification(BuildContext context) {
    subscriptionFirebase = FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('BİLDİRİME TIKLANDI');
      final page = message.data['page'] as String?;
      final url = message.data['url'] as String?;

    });
    subscriptionLocal = NotificationService.instance.selectNotificationStream.stream.listen((event) {
      if (event == null) return;
      final message = json.decode(event);
      final page = message['page'] as String?;
      final url = message['url'] as String?;

    });
  }

  void dispose(){
    subscriptionFirebase?.cancel();
    subscriptionLocal?.cancel();
    subscriptionFirebase=null;
    subscriptionLocal=null;
  }
}
