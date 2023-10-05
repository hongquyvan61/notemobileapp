
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:notemobileapp/router.dart';
import 'package:notemobileapp/test/authservice/auth.dart';

class PopUpMenu{
  final _googleSignIn = GoogleSignIn();
  Widget MenuItems(List<PopupMenuEntry<dynamic>> menuItems){
    return PopupMenuButton(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(6))),
        offset: const Offset(0, 50),
        icon: const Icon(
          Icons.account_circle,
          color: Colors.black,
        ),
        itemBuilder: (context) => menuItems);
  }

  List<PopupMenuEntry<dynamic>> accountPopupMenu(context){
    List<PopupMenuEntry<dynamic>> items = [
       PopupMenuItem(child: Text('User name')),
       PopupMenuItem(child: Text('Info')),
       PopupMenuItem(child: Text('Log out'), onTap: () {
         _googleSignIn.signOut();
         FirebaseAuth.instance.signOut();
         Navigator.pushNamed(context, RoutePaths.login);
         Navigator.defaultGenerateInitialRoutes(NavigatorState(), RoutePaths.start);
      },),

    ];
    return items;
  }

  List<PopupMenuEntry<dynamic>> loginPopupMenu(context){
    List<PopupMenuEntry<dynamic>> items = [
       PopupMenuItem(child: Text('Login'), onTap: () {
        Navigator.of(context).pushNamed(RoutePaths.login);
      },),

    ];
    return items;
  }


}