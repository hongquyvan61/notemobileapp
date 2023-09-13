import 'package:flutter/material.dart';
import 'package:notemobileapp/home/home.dart';
import 'package:notemobileapp/router.dart';
import 'package:notemobileapp/test/notifi_service.dart';

void main() {
  NotificationService().initNotification();
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
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          fontFamily: 'Urbanist'),
      home: const HomeScreen(),
    );
  }
}
