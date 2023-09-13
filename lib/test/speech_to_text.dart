import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:notemobileapp/test/notifi_service.dart';

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  // TextEditingController textEditingController = TextEditingController();
  FlutterTts flutterTts = FlutterTts();

  void textToSpeech(String text) async {
    await flutterTts.setLanguage("vi-VN");
    await flutterTts.setVolume(0.5);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1);
    await flutterTts.speak(text);

  }

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
            textToSpeech("Dậy đi ông cháu, dậy đi học ông cháu ơi");
          },
        ),
      ),
    );
  }
}
