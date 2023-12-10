import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DialogPage {
  late TextEditingController controller = TextEditingController();

  Future openDialog(context) => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            title: const Text("Đặt lại mật khẩu"),
            content: TextField(
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Nhập Email của bạn'),
              controller: controller,
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    submit(context);
                  },
                  child: const Text('Gửi')),
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
                    "Đường dẫn đặt lại mật khẩu đã được gửi đến Email của bạn !"),
                actions: [
                  TextButton(onPressed: () {
                      Navigator.pop(context);
                  }, child: const Text("Xong")),
                ],
              ));
    } on Exception catch (e) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
            actions: [TextButton(onPressed: (){Navigator.of(context).pop();}, child: Text("Xong"))],
                content: const Text("Có lỗi xảy ra ! Vui lòng thử lại."),
              ));
    }
  }
}
