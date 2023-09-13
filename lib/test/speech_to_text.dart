import 'package:flutter/material.dart';
import 'package:notemobileapp/test/notifi_service.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test Page"),
      ),
      body: Center(
        child: ElevatedButton(
          child: const Text("Show Notification"),
          onPressed: () {
              NotificationService().showNotification(title: "Sample title", body: "it's work");
          },
        ),
      ),
    );
  }
}
