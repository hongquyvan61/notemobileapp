import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notemobileapp/home/home.dart';
import 'package:notemobileapp/model/SqliteModel/initializeDB.dart';
import 'package:notemobileapp/newnote/newnote.dart';
import 'package:notemobileapp/router.dart';
import 'package:notemobileapp/test/notifi_service.dart';
import 'package:notemobileapp/test/services/firebase_firestore_service.dart';
import 'package:notemobileapp/test/services/firebase_message_service.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate(
    // You can also use a `ReCaptchaEnterpriseProvider` provider instance as an
    // argument for `webProvider`
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    // Default provider for Android is the Play Integrity provider. You can use the "AndroidProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. Debug provider
    // 2. Safety Net provider
    // 3. Play Integrity provider
    androidProvider: AndroidProvider.debug,
    // Default provider for iOS/macOS is the Device Check provider. You can use the "AppleProvider" enum to choose
    // your preferred provider. Choose from:
    // 1. Debug provider
    // 2. Device Check provider
    // 3. App Attest provider
    // 4. App Attest provider with fallback to Device Check provider (App Attest provider is only available on iOS 14.0+, macOS 14.0+)
    appleProvider: AppleProvider.appAttest,
  );
  InitDataBase.db = await InitDataBase().initDB();
  tz.initializeTimeZones();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  InitDataBase.firebasedb = FirebaseDatabase.instance.ref();
  NotificationService().initNotification();
  tz.initializeTimeZones();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    String? userEmail = FirebaseAuth.instance.currentUser?.email;
    FirebaseFirestore.instance
        .collection('notes')
        .doc(userEmail)
        .collection('receive')
        .snapshots()
        .listen((snapshot) {
      snapshot.docChanges.forEach((element) {
        if (element.doc.get('isNew')) {
          if (element.type == DocumentChangeType.added) {
            String owner = element.doc.get('owner');
            String rule = element.doc.get('rule');
            // // Xử lý sự kiện thay đổi dữ liệu ở đây
            // // NotificationService().showNotification(title: "Chia sẻ ghi chú", body: "Xem ghi chú ngay");
            // // isChange = true;
            // NotificationService().showNotification(
            //     "Chia sẻ ghi chú", '$owner đã chia sẻ ghi chú với bạn', context as BuildContext);

            FireStorageService().setIsNewFalse(element.doc.id);
          } else {
            // isChange = false;
          }
        }
      });
    });
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: RoutePaths.start,
      onGenerateRoute: RouterCustom.generateRoute,
      theme: ThemeData(
          //colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          // textTheme: GoogleFonts(
          //   Theme.of(context).textTheme
          // )
          // textTheme: GoogleFonts.merriweatherSansTextTheme(
          //     Theme.of(context).textTheme)
      ),
      builder: EasyLoading.init(),
      home: const HomeScreen(),
      // home:  StreamBuilder<User?>(
      //   stream: FirebaseAuth.instance.authStateChanges(),
      //   builder: (context, snapshot) {
      //     if(snapshot.hasError){
      //       return Text(snapshot.error.toString());
      //     }
      //     if(snapshot.connectionState == ConnectionState.active){
      //       if (snapshot.hasData) {
      //         return const HomeScreen();
      //       }
      //       else {
      //         return const AuthPage();
      //       }
      //     }
      //     return Divider();
      //   },),
    );
  }
}
