

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notemobileapp/test/notifi_service.dart';

class InviteState with ChangeNotifier{

  InviteState(){
    getReceive();
  }

  final List<QueryDocumentSnapshot> _receive = [];

  List<QueryDocumentSnapshot> get receive => _receive;
  String? userEmail = FirebaseAuth.instance.currentUser?.email;
  // bool isChange = false;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  getReceive() {


    // snapshots().listen((snapshot) {
    //   _receive = snapshot.
    // });
  }

  final Stream<QuerySnapshot> _userStream =
  FirebaseFirestore.instance.collection('notes').snapshots();

  Future<void> showNotification() async {
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

    await flutterLocalNotificationsPlugin.show(
      0, // ID của thông báo
      'Hello, Flutter',
      'This is a notification from Flutter!',
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

}