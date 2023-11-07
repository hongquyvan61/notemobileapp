import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:notemobileapp/test/notifi_service.dart';
import 'package:notemobileapp/test/services/change_invite_state.dart';
import 'package:provider/provider.dart';

class ShareNotePage extends StatefulWidget {
  const ShareNotePage({super.key});

  @override
  State<ShareNotePage> createState() => _ShareNotePageState();
}

class _ShareNotePageState extends State<ShareNotePage> {
  String? userEmail = FirebaseAuth.instance.currentUser?.email;
  // bool isChange = false;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();
  String test = '';
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseFirestore.instance.collection('notes').doc(userEmail).collection('receive').snapshots().listen((snapshot) {

      snapshot.docChanges.forEach((element) {
        if (element.type == DocumentChangeType.modified) {
          // Xử lý sự kiện thay đổi dữ liệu ở đây
          // NotificationService().showNotification(title: "Chia sẻ ghi chú", body: "Xem ghi chú ngay");
          // isChange = true;
          showNotification();
        } else {
          // isChange = false;

        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // final Stream<QuerySnapshot> _userStream = FirebaseFirestore.instance
    //     .collection('notes')
    //     .doc(userEmail)
    //     .collection('receive')
    //     .snapshots();
    // return StreamBuilder<QuerySnapshot>(
    //     stream: _userStream,
    //     builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
    //       if (snapshot.hasError) {
    //         return const Text('Something went wrong');
    //       }
    //
    //       if (snapshot.connectionState == ConnectionState.waiting) {
    //         return const Text("Loading");
    //       }
    //
    //       snapshot.data?.docs.forEach((element) {
    //         test = element.get('rule');
    //       });
    //
    //       NotificationService().showNotification(title: "Sample title", body: "it's work");
    //
    //       return Scaffold(
    //         appBar: AppBar(title: Text('Chia sẻ ghi chú'), centerTitle: true,),
    //         body: Center(child: Text(test)),
    //       );
    //     });

    return ChangeNotifierProvider(
      create: (BuildContext context) => InviteState(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Chia sẻ ghi chú'),
          centerTitle: true,
        ),
      ),
      builder: (context, child) {
        return Center(
            child: ElevatedButton(
          onPressed: () {
            Provider.of<InviteState>(context, listen: false).getReceive();
          },
          child: Text('Test'),
        ));
      },
    );
  }
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
