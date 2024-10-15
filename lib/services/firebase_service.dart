import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:googleapis/servicecontrol/v1.dart' as servicecontrol;
import 'package:googleapis_auth/auth_io.dart' as auth;
import 'package:http/http.dart' as http;

class FirebaseService{
  FirebaseService._();
  static FirebaseService? _instance;
  static FirebaseService get instance =>
      _instance ??= FirebaseService._();


  static Future<String> getApiKey() async {
    final serviceAccountJson = {
      
      /// bu kısımda sizin admin sdk bilgileriniz olucak
    };

    final scopes = [
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    final client = await auth.clientViaServiceAccount(auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes);

    final credentials = await auth.obtainAccessCredentialsViaServiceAccount(auth.ServiceAccountCredentials.fromJson(serviceAccountJson), scopes, client);

    client.close();

    return credentials.accessToken.data;
  }


  Future<String?> getDeviceToken() async {
    final apiKey = await getApiKey();
    final token = await FirebaseMessaging.instance.getToken(vapidKey: apiKey);
   return token;

  }


  void sendNotification({required String title, required String body, required String token}) async {
    final apiKey = await getApiKey();
    final url = Uri.parse("https://fcm.googleapis.com/v1/projects/bildirim-test-5aab6/messages:send");
    final header = {
      "Authorization":"Bearer $apiKey"
    };
    final data = json.encode({
      "message": {
        "token": token,
        "notification": {
          "title": title,
          "body": body
        },
        "data": {
          "story_id": "story_12345",
          "page":"home"
        }
      }

    });

    final response = await http.post(url,headers: header, body: data);

    print(response.statusCode);

  }






}