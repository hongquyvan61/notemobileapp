

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class InviteState with ChangeNotifier{
  final Stream<QuerySnapshot> _userStream =
  FirebaseFirestore.instance.collection('notes').snapshots();

  void listenChange(){

  }


}