import 'package:firebase_database/firebase_database.dart';
import 'package:notemobileapp/DAL/FB_DAL.dart/FB_Note.dart';
import 'package:notemobileapp/model/SqliteModel/FirebaseModel/FBNoteContentModel.dart';
import 'package:notemobileapp/model/SqliteModel/NoteModel.dart';

import '../../model/SqliteModel/initializeDB.dart';

class FB_NoteContent{

  FB_Note fb_note = FB_Note();

  Future<void> FB_insertNoteContent(int noteID, int notectID, FBNoteContentModel fbnotect) async{
    DatabaseReference? notetable = InitDataBase.firebasedb?.child("notecontent");

    await notetable!.child("noteID_${noteID.toString()}").child("notectID_${notectID.toString()}").set(fbnotect.toMap());
  }


  Future<int> FB_CountTotalNoteContents() async{
    int total = 0;
    DatabaseReference? notecttable = InitDataBase.firebasedb?.child("notecontent");

    List listnoteID = await fb_note.FB_getAllNoteIDKey();
    for(int i = 0; i < listnoteID.length; i++){
      DataSnapshot snap = await notecttable!.child(listnoteID[i].toString()).get();
      int count = snap.children.length;

      total += count;
    }
    return total;
  }


  Future<String> FB_getTitleImageOfNote(int note_id) async {
    DatabaseReference? notecttable = InitDataBase.firebasedb?.child("notecontent");

    DataSnapshot snap = await notecttable!.child("noteID_${note_id.toString()}").get();
    Map map = snap.value as Map;

    List<String> lstimgcontent = map.entries.map((e) => e.value["imagecontent"].toString()).toList();

    String titleimagelink = lstimgcontent.firstWhere((element) => element != "", orElse: () => "");

    return titleimagelink;
  }

  Future<String> FB_getBriefContentOfNote(int note_id) async{
    DatabaseReference? notecttable = InitDataBase.firebasedb?.child("notecontent");

    DataSnapshot snap = await notecttable!.child("noteID_${note_id.toString()}").get();
    Map map = snap.value as Map;

    List<String> lsttextcontent = map.entries.map((e) => e.value["textcontent"].toString()).toList();

    String briefcontent = lsttextcontent.firstWhere((element) => element != "", orElse: () => "");

    return briefcontent;
  }

}