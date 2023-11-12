import 'package:avatar_glow/avatar_glow.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class TestPage extends StatefulWidget {
  const TestPage({super.key});

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  TextEditingController textEditingController = TextEditingController();

  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = 'Press The Button And Start Speaking';
  double _confidence = 1.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _speech = stt.SpeechToText();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Confidence: ${(_confidence * 100.0).toStringAsFixed(1)}%"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: AvatarGlow(
        animate: _isListening,
        glowColor: Theme.of(context).primaryColor,
        duration: const Duration(microseconds: 2000),
        repeat: true,
        child: FloatingActionButton(
          onPressed: () {
            _listen();
          },
          child: Icon(_isListening ? Icons.mic : Icons.mic_none),
        ),
      ),
      body: SingleChildScrollView(
        reverse: true,
        child: Container(
          padding: const EdgeInsets.fromLTRB(30, 30, 30, 150),
          child: Text(_text),
        ),
      ),
    );
  }


  void _listen() async {

    if(!_isListening) {
      bool available = await _speech.initialize(
        onStatus: (value) => print('onStatus: $value'),
        onError: (value) => print('onError: $value'),
      );

      if(available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult:  (value) => setState(() {
            _text = value.recognizedWords;
            if(value.hasConfidenceRating && value.confidence > 0){
              _confidence = value.confidence;
            }
          })
        );
      }
    } else {
      setState(() => _isListening = false);
      _speech.stop();
    }

  }

}
