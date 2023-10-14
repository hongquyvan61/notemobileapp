import 'package:flutter/material.dart';
import 'package:notemobileapp/DAL/FB_DAL/FB_Note.dart';
import 'package:notemobileapp/DAL/FB_DAL/FB_Tag.dart';
import 'package:notemobileapp/DAL/NoteDAL.dart';
import 'package:notemobileapp/DAL/TagDAL.dart';
import 'package:notemobileapp/model/SqliteModel/FirebaseModel/FBNoteModel.dart';
import 'package:notemobileapp/model/SqliteModel/FirebaseModel/FBTagModel.dart';
import 'package:notemobileapp/model/SqliteModel/initializeDB.dart';

import '../../model/SqliteModel/TagModel.dart';

class FB_Upload{
  TagDAL tagDAL = TagDAL();
  NoteDAL noteDAL = NoteDAL();
  FB_Tag fb_tag = FB_Tag();
  FB_Note fb_note = FB_Note();

  Future<bool> UploadAllDataToFB(int uid) async {
    try{
      List<FBTagModel> listtag = await tagDAL.getTagsByUserID_FB(InitDataBase.db, uid);

      if(listtag.isNotEmpty){
        for(int i = 0; i < listtag.length; i++){
          int total = await fb_tag.CountTotalTag();
          
          int newtagid = total + 1;

          listtag[i].tag_id = newtagid;
          listtag[i].user_id = uid;

          /////UPLOAD TAG
          fb_tag.FB_insertTagToFB(uid, newtagid, listtag[i]);

          /////UPLOAD NOTE WITH TAG AND NOTE CONTENTS
          
          List<FBNoteModel> noteswithTag = await noteDAL.getAllNotesWithTagByUserID_FB_setData(uid, listtag[i].tag_id?.toInt() ?? 0, newtagid, InitDataBase.db);

          if(noteswithTag.isNotEmpty){
            fb_note.uploadNoteFromLocalToFB(noteswithTag, uid);
          }

        }
      }
      

      /////UPLOAD NOTE WHICH WITHOUT TAG AND NOTE CONTENTS
      List<FBNoteModel> noteswithoutTag = await noteDAL.getAllNotes_WithoutTag_ByUserID_FB(uid, InitDataBase.db);

      if(noteswithoutTag.isNotEmpty){
        fb_note.uploadNoteFromLocalToFB(noteswithoutTag, uid);
      }
      return true;
    }
    on Exception catch(e){
      debugPrint(e.toString());
      return false;
    }
  }
}