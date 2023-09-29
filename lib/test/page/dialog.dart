import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DialogPage {
  late TextEditingController controller = TextEditingController();

  Future openDialog(context) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text("Reset Password"),
            content: TextField(
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Enter Your Email'),
              controller: controller,
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    submit(context);
                  },
                  child: const Text('Send')),
            ],
          ));

  Future<void> submit(context) async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: controller.text);
      await FirebaseAuth.instance.setLanguageCode('vi');
      Navigator.of(context).pop(controller.text);
      controller.clear();
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                content: const Text(
                    "The password reset link has been sent to your email !"),
                actions: [
                  TextButton(onPressed: () {
                      Navigator.pop(context);
                  }, child: const Text("OK")),
                ],
              ));
    } on Exception catch (e) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                content: Text(e.toString()),
              ));
    }
  }
}
