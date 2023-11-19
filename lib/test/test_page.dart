import 'package:flutter/material.dart';
import 'package:notemobileapp/test/notifi_service.dart';


import 'date_time_picker.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  // TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Test Page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const DatePickerTxt(),
            const ScheduleBtn(),
            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: ElevatedButton(
                child: const Text("Show Notification"),
                onPressed: () {
                  NotificationService()
                      .showNotification("Sample title", "it's work", context);

                },
              ),
            ),

          ],
        ),
      ),
    );
  }
}