import 'package:notemobileapp/router.dart';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:notemobileapp/test/component/toast.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:notemobileapp/DAL/UserDAL.dart';
import 'package:notemobileapp/model/SqliteModel/FirebaseModel/FBUserModel.dart';
import 'package:notemobileapp/model/SqliteModel/UserModel.dart';
import 'package:notemobileapp/model/SqliteModel/initializeDB.dart';
import '../page/auth_page.dart';
import '../page/verify_email.dart';

class Auth {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();
  final UserDAL uDAL = UserDAL();

  DatabaseReference? userstable;

  Future registerWithEmailPassword(
      context, String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );


      // //INSERT INTO LOCAL
      // String encryptpass = md5.convert(utf8.encode(password)).toString();
      // UserModel umodel = UserModel(
      //     user_id: null,
      //     username: email,
      //     password: encryptpass,
      //     account_type: 'normal');
      //
      // bool checkinsert = await uDAL.insertUser(umodel, InitDataBase.db);
      //
      // if (checkinsert == false) {
      //   debugPrint("Insert user vao db local xay ra loi!!");
      //   return "Đăng kí tài khoản thất bại, hãy thử lại";
      // }
      //
      // //INSERT INTO LOCAL
      //
      // //INSERT INTO FIREBASE
      // userstable = InitDataBase.firebasedb?.child("users");
      // DataSnapshot snap = await userstable!.get();
      // int count = snap.children.length;
      //
      // int uID = count + 1;
      //
      // FBUserModel fbusermod = FBUserModel(
      //     username: email,
      //     password: encryptpass,
      //     account_type: "normal",
      //     user_id: uID);
      //
      // await userstable!
      //     .child("userID_${uID.toString()}")
      //     .set(fbusermod.toMap())
      //     .catchError(
      //   (Object e, StackTrace stackTrace) {
      //     debugPrint(e.toString());
      //   },
      // );
      //
      // //INSERT INTO FIREBASE
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ToastComponent().showToast('Mật khẩu không an toàn. Thử lại');
      } else if (e.code == 'email-already-in-use') {
        ToastComponent().showToast('Tài khoản này đã được đăng ký trước đó.');
      }
    } catch (e) {
      ToastComponent().showToast(e.toString());
    }
  }

  Future signInWithEmailPassword(context, String email, String password) async {
    try {
      final _user = await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((value) {
        if (FirebaseAuth.instance.currentUser!.emailVerified) {
          Navigator.of(context).pushNamedAndRemoveUntil(
              RoutePaths.start, (Route<dynamic> route) => false);
          ToastComponent().showToast('Đăng nhập thành công');
        } else {
          Navigator.of(context).pushReplacementNamed(RoutePaths.verifyEmail);
        }
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
        ToastComponent().showToast('Thông tin đăng nhập không hợp lệ');
      } else if (e.code == 'invalid-email') {
        ToastComponent().showToast('Email không đúng định dạng');
      }
    } catch (e) {
      print(e);
    }
  }

  // Future<int> signInWithEmailPassword(String email, String password) async {
  //   try {
  //     String encryptpass = md5.convert(utf8.encode(password)).toString();
  //
  //     // UserModel u = UserModel(
  //     //   user_id: null,
  //     //   username: email,
  //     //   password: encryptpass,
  //     //   account_type: 'normal'
  //     // );
  //     // bool insertlocal = await uDAL.insertUser(u, InitDataBase.db);
  //
  //     userstable = InitDataBase.firebasedb?.child("users");
  //     DataSnapshot snap = await userstable!.get();
  //     Map map = snap.value as Map;
  //     List<FBUserModel> listuser = map.entries
  //         .map((e) => FBUserModel(
  //             username: e.value["username"],
  //             password: e.value["password"],
  //             account_type: e.value["account_type"],
  //             user_id: e.value["user_id"]))
  //         .toList();
  //
  //     late int uID;
  //     for (int i = 0; i < listuser.length; i++) {
  //       if (listuser[i].username == email &&
  //           listuser[i].password == encryptpass) {
  //         uID = listuser[i].user_id?.toInt() ?? -1;
  //       }
  //     }
  //
  //     return uID;
  //     // table = table.sublist(1,table.length);
  //     // late String uID;
  //
  //     // for(int i = 0; i < table.length; i++){
  //     //   Map item = table[i] as Map;
  //     //   if(item["username"] == email && item["password"] == encryptpass){
  //     //     uID = (i + 1).toString();
  //     //     break;
  //     //   }
  //     // }
  //
  //     //return uID;
  //   } on Exception catch (e) {
  //     debugPrint(e.toString());
  //   }
  //
  //   return -1;
  //   // table.forEach((key, value) {
  //   //   if(value['username'] == email && value['password'] == password){
  //   //     uID = key;
  //   //   }
  //   // });
  //
  //   // userstable!.p
  //   // return null;
  // }

  signInWithGoogle(context) async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication aAuth = await gUser!.authentication;

    final credential = GoogleAuthProvider.credential(
        accessToken: aAuth.accessToken, idToken: aAuth.idToken);
    try {
      await FirebaseAuth.instance
          .signInWithCredential(credential);

    } on FirebaseAuthException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }
  }

// bool checkLogin()  {
//   bool result = true;
//   _auth.authStateChanges().listen((User? user) {
//     if (user == null) {
//       result = false;
//     }
//
//   });
//   return result;
// }
}
