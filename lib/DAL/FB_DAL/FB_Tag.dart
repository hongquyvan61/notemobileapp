import 'package:firebase_database/firebase_database.dart';
import 'package:notemobileapp/DAL/FB_DAL/FB_User.dart';

import '../../model/SqliteModel/FirebaseModel/FBTagModel.dart';
import '../../model/SqliteModel/initializeDB.dart';

class FB_Tag{

  FB_User fb_user = FB_User();

  Future<int> CountTotalTag() async{
    int total = 0;
    DatabaseReference? notetable = InitDataBase.firebasedb?.child("tag");

    List listuserID = await fb_user.getAllUserIDKey();
    for(int i = 0; i < listuserID.length; i++){
      DataSnapshot snap = await notetable!.child(listuserID[i].toString()).get();
      int count = snap.children.length;

      total += count;
    }
    return total;
  }

  Future<void> FB_insertTagToFB(int uid, int tagid, FBTagModel fbtag) async {
    DatabaseReference? tagtable = InitDataBase.firebasedb?.child("tag");

    await tagtable!.child("userID_${uid.toString()}").child("tagID_${tagid.toString()}").set(fbtag.toMap());
  }
}