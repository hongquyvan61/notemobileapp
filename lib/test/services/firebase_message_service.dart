import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notemobileapp/newnote/showShareNote.dart';
import 'package:notemobileapp/router.dart';
import 'package:notemobileapp/test/page/share_note_page.dart';
import 'package:http/http.dart' as http;

class FireBaseMessageService {
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void initLocalNotifications(
      BuildContext context, RemoteMessage message) async {
    var androidInitializationSettings =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSetting =
        InitializationSettings(android: androidInitializationSettings);

    await flutterLocalNotificationsPlugin.initialize(initializationSetting,
        onDidReceiveNotificationResponse: (payload) {
      handleMessage(context, message);
    });
  }

  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      Random.secure().nextInt(100000).toString(), // ID của channel
      'your_channel_name', // Tên của channel
      // Mô tả của channel
      importance: Importance.max,
      priority: Priority.high,
    );
    NotificationDetails notificationDetails =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    Future.delayed(Duration.zero, () {
      flutterLocalNotificationsPlugin.show(
          1,
          message.notification!.title.toString(),
          message.notification!.body.toString(),
          notificationDetails);
    });
  }

  void messageInnit(BuildContext context) {
    FirebaseMessaging.onMessage.listen((event) {
      print(event.notification!.title.toString());
      print(event.notification!.body.toString());

      print(event.data['type']);

      if (Platform.isAndroid) {
        initLocalNotifications(context, event);
        showNotification(event);
      }
    });
  }

  void requestNotificationPermission() async {
    NotificationSettings settings = await firebaseMessaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        sound: true);

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('1');
    } else if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('2');
    } else {
      print('3');
    }
  }

  Future<String?> getToken() async {
    String? fcmToken =  await FirebaseMessaging.instance.getToken();
    return fcmToken;
  }

  Future<void> setupInteractMessage(BuildContext context) async {
    // terminate
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      handleMessage(context, initialMessage);
    }

    //background
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      handleMessage(context, event);
    });
  }

  void handleMessage(BuildContext context, RemoteMessage message) {

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                   ShowShareNote(noteId: message.data['id'], isEdit: true, email: message.data['owner'], rule: message.data['rule'])));

  }

  Future<void> messageFromServer(
      String token, String noteId, String email, String rule) async {
    String? name = FirebaseAuth.instance.currentUser?.email;

    var data = {
      'to': token,
      'priority': 'high',
      'notification': {
        'title': 'Chia sẻ ghi chú',
        'body': '$name đã chia sẻ ghi chú với bạn'
      },
      'data': {
        'type': 'notification',
        'id': noteId,
        'owner': email,
        'rule': rule
      }
    };
    await http.post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
        body: jsonEncode(data),
        headers: {
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization':
              'key=AAAA53E_wSo:APA91bG9wwEfAg6FbKmSfvAvQ4xSpT21RsJnShGmVkexvpiSvUwq9_T3Eg1ujBU6JhEbIOkcF5zi3gXuyX7ZhK4yysTxnS0w0u1RNpTih1kkPYb1o-1mLoo4CRCVxp0QEcQ9Y0qf9fvd'
        });
  }
}
