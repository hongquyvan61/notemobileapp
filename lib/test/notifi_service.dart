// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notemobileapp/router.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void showNotification(String title, String body, BuildContext context) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id', // ID của channel
      'your_channel_name', // Tên của channel
      // Mô tả của channel
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
        android: AndroidInitializationSettings(
            'app_icon'), // Thay đổi thành tên icon của ứng dụng của bạn
      ),
      onDidReceiveNotificationResponse: (notificationResponse) async {
        // Xử lý khi người dùng tương tác với thông báo (ví dụ: nhấn vào nút)
        // Thông tin chi tiết về tương tác có thể được truy cập từ notificationResponse
        print('Đã nhận phản hồi từ người dùng: ${notificationResponse.id}');
        Navigator.of(context).pushNamed(RoutePaths.shareNotePage);
      },
    );
    await flutterLocalNotificationsPlugin.show(
      0, // ID của thông báo
      title,
      body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }
}
