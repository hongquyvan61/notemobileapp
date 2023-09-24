import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notemobileapp/home/home.dart';
import 'package:notemobileapp/model/initializeDB.dart';
import 'package:notemobileapp/newnote/newnote.dart';
import 'package:notemobileapp/router.dart';
import 'package:notemobileapp/test/notifi_service.dart';
import 'package:notemobileapp/test/page/auth_page.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  InitDataBase.db = await InitDataBase().initDB();
  NotificationService().initNotification();
  tz.initializeTimeZones();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
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
          textTheme: GoogleFonts.merriweatherSansTextTheme(
            Theme.of(context).textTheme
          )
      ),
      builder: EasyLoading.init(),
      // home:  StreamBuilder<User?>(
      //   stream: FirebaseAuth.instance.authStateChanges(),
      //   builder: (context, snapshot) {
      //     if (snapshot.hasData) {
      //       return const HomeScreen();
      //     } else {
      //       return const AuthPage();
      //     }
      //   },),
    );
  }
}
