
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:notemobileapp/router.dart';


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
       const PopupMenuItem(
        value: "username",
        child: Text('User name')
       ),
       const PopupMenuItem(
        value: "info",
        child: Text('Info')
       ),
       const PopupMenuItem(
        value: "logout",
        child: Text('Log out')
       ),

    ];
    return items;
  }

  List<PopupMenuEntry<dynamic>> loginPopupMenu(context){
    List<PopupMenuEntry<dynamic>> items = [

       const PopupMenuItem(
          value: "login",
          child: Text('Login'),
      ),


    ];
    return items;
  }


}