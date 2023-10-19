import 'package:flutter/material.dart';

class ShareNotePage extends StatefulWidget {
  const ShareNotePage({super.key});

  @override
  State<ShareNotePage> createState() => _ShareNotePageState();
}

class _ShareNotePageState extends State<ShareNotePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ghi chú được chia sẻ'),
        centerTitle: true,
      ),
    );
  }
}
