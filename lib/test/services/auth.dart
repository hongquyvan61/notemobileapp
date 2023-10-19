import 'package:notemobileapp/router.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_database/firebase_database.dart';

import 'package:notemobileapp/test/component/toast.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:notemobileapp/DAL/UserDAL.dart';

class Auth {
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();
  final UserDAL uDAL = UserDAL();

  DatabaseReference? userstable;

  Future registerWithEmailPassword(
      context, String email, String password) async {
    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
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

  signInWithGoogle(context) async {
    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication aAuth = await gUser!.authentication;

    final credential = GoogleAuthProvider.credential(
        accessToken: aAuth.accessToken, idToken: aAuth.idToken);
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      print(e);
    } catch (e) {
      print(e);
    }
  }

  changePassword() async {
    final user = _auth.currentUser;
    await user?.sendEmailVerification();
  }
}
