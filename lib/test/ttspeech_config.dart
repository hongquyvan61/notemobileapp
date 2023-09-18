import 'package:flutter_tts/flutter_tts.dart';

void configTextToSpeech(FlutterTts flutterTts) async {
  await flutterTts.setLanguage("vi-VN");
  await flutterTts.setVolume(0.5);
  await flutterTts.setSpeechRate(0.5);
  await flutterTts.setPitch(1);
}