import 'package:flutter/material.dart';
import 'package:notemobileapp/home/home.dart';
import 'package:notemobileapp/newnote/newnote.dart';
import 'package:notemobileapp/test/page/auth_page.dart';
import 'package:notemobileapp/test/page/sign_up_page.dart';
import 'package:notemobileapp/test/page/verify_email.dart';
import 'package:notemobileapp/test/test_page.dart';

class RoutePaths {
  static const start = '/';
  static const newnote = 'newnotescreen';
  static const temp = 'tempscreen';
  static const test = 'testscreen';
  static const login = 'loginscreen';
  static const signup = 'signupscreen';
  static const verifyEmail = 'verifyscreen';
}

class RouterCustom {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutePaths.start:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case RoutePaths.newnote:
        // you can do things like pass arguments to screens
        //final event = settings.arguments as Event;

        //SUA NOTEID, USERID O DAY
        return MaterialPageRoute(
            builder: (_) => const NewNoteScreen(
                  isEdit: false,
                  noteId: '',
                ));

      case RoutePaths.test:
        // you can do things like pass arguments to screens
        //final event = settings.arguments as Event;
        return MaterialPageRoute(builder: (_) => const TestPage());
      case RoutePaths.login:
        return MaterialPageRoute(builder: (_) => const AuthPage());
      case RoutePaths.signup:
        return MaterialPageRoute(builder: (_) => const SignUpPage());
      case RoutePaths.verifyEmail:
        return MaterialPageRoute(builder: (_) => const VerifyEmailPage());

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
