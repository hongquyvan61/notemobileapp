

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:notemobileapp/router.dart';
import 'package:notemobileapp/test/component/toast.dart';

import '../page/auth_page.dart';
import '../page/verify_email.dart';

class Auth {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();

  Future registerWithEmailPassword(String email, String password) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      )
          .then((value) =>
          ToastComponent()
              .showToast('Đăng ký thành công. Vui lòng xác nhận email'));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ToastComponent().showToast('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        ToastComponent()
            .showToast('The account already exists for that email.');
      } else {
        ToastComponent().showToast('Successful');
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
        ToastComponent().showToast('Successful');
        Navigator.of(context).pushReplacementNamed(RoutePaths.verifyEmail);
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
        ToastComponent().showToast('Thông tin đăng nhập không hợp lệ');
      } else if (e.code == 'invalid-email') {
        ToastComponent().showToast('Email không đúng định dạng');
      }

      print(e);
    } catch (e) {
      print(e);
    }
  }

  signInWithGoogle(context) async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication aAuth = await gUser!.authentication;

    final credential = GoogleAuthProvider.credential(
        accessToken: aAuth.accessToken, idToken: aAuth.idToken);
    try {
      await FirebaseAuth.instance
          .signInWithCredential(credential)
          .then((value)  {
      ToastComponent().showToast("Đăng nhập thành công");
      Navigator.of(context).pushNamedAndRemoveUntil(RoutePaths.start, (Route<dynamic> route) => false);
      });
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
