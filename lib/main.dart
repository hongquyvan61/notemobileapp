import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notemobileapp/home/home.dart';
import 'package:notemobileapp/newnote/newnote.dart';
import 'package:notemobileapp/router.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: RoutePaths.start,
      onGenerateRoute: RouterCustom.generateRoute,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          // textTheme: GoogleFonts(
          //   Theme.of(context).textTheme
          // )
          textTheme: GoogleFonts.merriweatherSansTextTheme(
            Theme.of(context).textTheme
          )
      ),
      home: const HomeScreen(),
      
    );
  }

}