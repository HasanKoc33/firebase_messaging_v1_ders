import 'dart:async';

import 'package:firebase_bildirim_gonderme/services/firebase_service.dart';
import 'package:firebase_bildirim_gonderme/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.instance.initalize();



  unawaited(FirebaseMessaging.instance.requestPermission());
  unawaited( FirebaseMessaging.instance
      .setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  ));

  FirebaseMessaging.onMessage.listen(NotificationService.instance.showNotification);

  runApp(const MyApp());
}


/// MyApp ekranı
class MyApp extends StatefulWidget {
  /// MyApp ekranı
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      NotificationService.instance.listenOnTapNotification(navigatorKey.currentContext!);
    });

  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}


/// MyHomePage ekranı
class MyHomePage extends StatefulWidget {
  /// MyHomePage ekranı
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bildirim testi'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              NotificationService.instance.showNotification(
                RemoteMessage(
                  messageId: 'test',
                  data: {

                  },
                  notification: RemoteNotification(
                    title: 'Bildirim başlığı',
                    body: 'Bildirim içeriği',
                  ),
                ),
              );
            },
            child: const Text('Local BİLDİRİM GÖNDER'),
          ),
          ElevatedButton(
            onPressed: () async {
              final token = await FirebaseService.instance.getDeviceToken();
              FirebaseService.instance.sendNotification(title: "11111", body: "ffff", token: token!);
            },
            child: const Text('Uzak BİLDİRİM GÖNDER'),
          ),
        ],
      ),
    );
  }
}

