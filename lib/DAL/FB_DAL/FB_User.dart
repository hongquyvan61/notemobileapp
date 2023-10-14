import 'package:firebase_database/firebase_database.dart';

import '../../model/SqliteModel/FirebaseModel/FBUserModel.dart';
import '../../model/SqliteModel/initializeDB.dart';

class FB_User{
  Future<List<dynamic>> getAllUserIDKey() async {
    DatabaseReference? userstable = InitDataBase.firebasedb?.child("users");

    List<dynamic> listuser = [];
    DataSnapshot snap = await userstable!.get();
    Map map = snap.value as Map;
    listuser = map.entries.map((e) => e.key).toList();

    return listuser;
  }
}