import 'package:flutter/material.dart';
import 'package:notemobileapp/home/home.dart';
import 'package:notemobileapp/newnote/newnote.dart';

class RoutePaths {
  static const start = '/';
  static const newnote = 'newnotescreen';
  static const temp = 'tempscreen';
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
