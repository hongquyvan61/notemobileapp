import 'package:flutter/material.dart';
import 'package:notemobileapp/home/home.dart';
import 'package:notemobileapp/newnote/newnote.dart';
import 'package:notemobileapp/temp.dart';
import 'package:notemobileapp/test/speech_to_text.dart';

class RoutePaths {
  static const start = '/';
  static const newnote = 'newnotescreen';
  static const temp = 'tempscreen';
  static const test = 'testscreen';
  
}

class RouterCustom {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutePaths.start:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case RoutePaths.newnote:
        // you can do things like pass arguments to screens
        //final event = settings.arguments as Event;
        return MaterialPageRoute(
            builder: (_) => const NewNoteScreen());
      case RoutePaths.test:
        // you can do things like pass arguments to screens
        //final event = settings.arguments as Event;
        return MaterialPageRoute(
            builder: (_) => const TestPage());

      case RoutePaths.temp:
        return MaterialPageRoute(
            builder: (_) => TempScreen());
      default:
        return MaterialPageRoute(
            builder: (_) => Scaffold(
                  body: Center(
                    child: Text('No route defined for ${settings.name}'),
                  ),
                ));
    }
  }
}
