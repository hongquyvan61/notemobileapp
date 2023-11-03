import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ShareNotePage extends StatefulWidget {
  const ShareNotePage({super.key});

  @override
  State<ShareNotePage> createState() => _ShareNotePageState();
}

class _ShareNotePageState extends State<ShareNotePage> {
  final Stream<QuerySnapshot> _userStream =
      FirebaseFirestore.instance.collection('notes').snapshots();
  String test = '';

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _userStream,
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return const Text('Something went wrong');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading");
          }



          test = snapshot.data?.docs.first.get('haha');

          return Scaffold(
            body: Center(child: Text(test)),
          );
        });
  }
}
