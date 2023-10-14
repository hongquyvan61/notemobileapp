import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:notemobileapp/DAL/FB_DAL/FB_NoteContent.dart';
import 'package:notemobileapp/DAL/FB_DAL/FB_User.dart';
import 'package:notemobileapp/DAL/NoteContentDAL.dart';
import 'package:notemobileapp/model/SqliteModel/FirebaseModel/FBNoteModel.dart';
import 'package:notemobileapp/model/SqliteModel/NoteModel.dart';

import '../../model/SqliteModel/FirebaseModel/FBNoteContentModel.dart';
import '../../model/SqliteModel/initializeDB.dart';

class FB_Note{
  FB_User fb_user = FB_User();
  FB_NoteContent fb_noteContent = FB_NoteContent();
  NoteContentDAL ncontentDAL = NoteContentDAL();
  
  Future<bool> uploadNoteFromLocalToFB(List<FBNoteModel> lst, int uID) async {
    try{
      for(int i = 0; i < lst.length ; i++){
        
        int totalnote = await FB_CountTotalNote();

        int newnoteIDatFB = totalnote + 1;

        lst[i].user_id = uID;
        lst[i].note_id = newnoteIDatFB;

        /////UPLOAD NOTE

        FB_insertNotetoFB(uID, newnoteIDatFB, lst[i]);

        List<FBNoteContentModel> lstcontentFB = await ncontentDAL.getAllNoteContentsById_FB_setData(InitDataBase.db, lst[i].note_id?.toInt() ?? 0, newnoteIDatFB);

        /////UPLOAD NOTE CONTENT
        bool insertnotect = await fb_noteContent.uploadNoteContentFromLocalToFB(lstcontentFB, newnoteIDatFB);

      }
    }
    on Exception catch(e){
      debugPrint(e.toString());
      return false;
    }
    return true;
  }


  Future<int> FB_CountTotalNote() async {
    int total = 0;
    DatabaseReference? notetable = InitDataBase.firebasedb?.child("note");

    List listuserID = await fb_user.getAllUserIDKey();
    for(int i = 0; i < listuserID.length; i++){
      DataSnapshot snap = await notetable!.child(listuserID[i].toString()).get();
      int count = snap.children.length;

      total += count;
    }
    return total;
  }

  Future<void> FB_insertNotetoFB(int uID, int noteID, FBNoteModel fbnote) async {
    DatabaseReference? notetable = InitDataBase.firebasedb?.child("note");

    await notetable!.child("userID_${uID.toString()}").child("noteID_${noteID.toString()}").set(fbnote.toMap());
  }

  Future<dynamic> FB_getAllNoteIDKey() async {
    List<dynamic> lstnoteid = [];
    DatabaseReference? notetable = InitDataBase.firebasedb?.child("note");

    List listuserID = await fb_user.getAllUserIDKey();
    for(int i = 0; i < listuserID.length; i++){
      DataSnapshot snap = await notetable!.child(listuserID[i].toString()).get();
      Map map = snap.value as Map;

      List tam = map.entries.map((e) => e.key).toList();

      lstnoteid += tam;
    }
    return lstnoteid;
  }

  Future<List<FBNoteModel>> FB_getAllNoteByUid(int uid) async {
    DatabaseReference? notetable = InitDataBase.firebasedb?.child("note");
    DataSnapshot snap = await notetable!.child("userID_${uid.toString()}").get();
    List<FBNoteModel> notelist = [];
    if(snap.value != null){
      Map map = snap.value as Map;

      notelist = map.entries.map((e) => FBNoteModel(
        title: e.value["title"], 
        date_created: e.value["date_created"], 
        user_id: e.value["user_id"], 
        tag_id: e.value["tag_id"],
        note_id: e.value["note_id"]
      )).toList();
    }
    
    return notelist;
  }

}