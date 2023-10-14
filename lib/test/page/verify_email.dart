import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notemobileapp/home/home.dart';
import 'package:notemobileapp/test/authservice/auth.dart';
import 'package:notemobileapp/test/component/toast.dart';
import 'package:notemobileapp/test/page/auth_page.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({
    Key? key, required this.email, required this.password
  }) : super(key: key);

  final String email;
  final String password;

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool _isEmailVerified = false;
  bool canResendEmail = false;
  Timer? timer;

  get canResend => null;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!_isEmailVerified) {
      sendVerificationEmail();
      timer = Timer.periodic(
        Duration(seconds: 3),
            (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _isEmailVerified
          ? const AuthPage() //const HomeScreen(userID: -1,)                 /////TAO BO SUNG USERID O DAY NE, CO GI SUA LAI CHO PHU HOP VOI CODE
                                                          /////CUA M
          : Scaffold(
        appBar: AppBar(
          title: const Text("Verify email"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('A verification email has been sent to your email.'),
              SizedBox(height: 20,),
              ElevatedButton.icon(
                  onPressed: () {
                    if (canResendEmail) {
                      sendVerificationEmail();
                    }
                  },
                  icon: const Icon(Icons.email),
                  label: const Text('Resent Email')),
              TextButton(onPressed: () {
                FirebaseAuth.instance.signOut();
              },
                child: Text('Cancel'),
                style: ElevatedButton.styleFrom(
                    minimumSize: Size.fromHeight(20)),)
            ],
          ),
        ),
      );

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();
      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 5));
      setState(() => canResendEmail = true);
    } catch (e) {
      print(e);
    }
  }

  checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser?.reload();
    _isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    
    if (_isEmailVerified) {
      ToastComponent().showToast("Email của bạn đã được xác thực thành công !");
      int uID = await Auth().registerWithEmailPassword(widget.email, widget.password);
      timer?.cancel();
    }

    setState(() {
      
    });
  }
}
