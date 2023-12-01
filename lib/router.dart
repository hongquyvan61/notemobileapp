import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notemobileapp/home/home.dart';
import 'package:notemobileapp/newnote/newnote.dart';
import 'package:notemobileapp/test/page/auth_page.dart';
import 'package:notemobileapp/test/page/notification_page.dart';
import 'package:notemobileapp/test/page/share_note_page.dart';
import 'package:notemobileapp/test/page/sign_up_page.dart';
import 'package:notemobileapp/test/page/tag_page.dart';
import 'package:notemobileapp/test/page/verify_email.dart';
import 'package:notemobileapp/test/test_page.dart';

class RoutePaths {
  static const start = '/';
  static const newnote = 'newnotescreen';
  static const temp = 'testscreen';
  static const login = 'loginscreen';
  static const signup = 'signupscreen';
  static const verifyEmail = 'verifyscreen';
  static const notificationPage = 'notificationPage';
  static const shareNotePage = 'shareNotePage';
  static const shareNoteManager = 'shareNoteManager';
  static const tagPage = 'tagscreen';
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
                  noteId: '',
                  isEdit: false,
                  isNewNote: true,
                  email: "",
                ));

      case RoutePaths.login:
        return MaterialPageRoute(builder: (_) => const AuthPage());
      case RoutePaths.signup:
        return MaterialPageRoute(builder: (_) => const SignUpPage());
      case RoutePaths.verifyEmail:
        return MaterialPageRoute(builder: (_) => const VerifyEmailPage());
      case RoutePaths.notificationPage:
        return MaterialPageRoute(builder: (_) => const NotificationPage());
      case RoutePaths.tagPage:
        return MaterialPageRoute(
            builder: (_) => TagScreen(email: FirebaseAuth.instance.currentUser?.email == null ? "" : FirebaseAuth.instance.currentUser?.email)
            );

      case RoutePaths.shareNotePage:
        return MaterialPageRoute(
            builder: (_) => const ShareNotePage(
                  navNotification: false,
                ));
      case RoutePaths.temp:
        return MaterialPageRoute(builder: (_) => const TestPage());

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
