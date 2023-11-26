import 'dart:io';

import 'package:notemobileapp/model/SqliteModel/initializeDB.dart';
import 'package:notemobileapp/test/services/firebase_firestore_service.dart';
import 'package:sqflite/sqflite.dart';

import 'package:notemobileapp/model/SqliteModel/NoteContentModel.dart';

import '../test/model/note_content.dart';
import '../test/services/firebase_store_service.dart';

class NoteContentDAL {
  
    Future<bool> insertNoteContent(NoteContentModel notecontent, Database db) async {
      // Insert the Dog into the correct table. You might also specify the
      // `conflictAlgorithm` to use in case the same dog is inserted twice.
      //
      // In this case, replace any previous data.
      // await db.insert(
      //   'notecontent',
      //   notecontent.toMap(),
      //   conflictAlgorithm: ConflictAlgorithm.replace,
      // );
      
      int check = await db.rawInsert("insert into notecontent(textcontent,imagecontent,note_id) values(?,?,?)",[notecontent.textcontent,notecontent.imagecontent,notecontent.note_id]);
      return check != 0 ? true : false;
    }

    Future<bool> deleteNoteContentsByNoteID(Database db, int noteid) async{

      int check = await db.rawDelete("delete from notecontent where note_id=?",[noteid]);
      return check != 0 ? true : false;
    }

    Future<bool> deleteNoteContentsByID(int notecontentid, Database db) async{
      List<Map> result = await db.rawQuery("select imagecontent from notecontent where notecontent_id=? and imagecontent is not null",[notecontentid]);
      if(result.isNotEmpty){
        String? imgpath = result[0]['imagecontent'].toString();
        if(imgpath.isNotEmpty) {
          await File(imgpath).delete();
        }
      }

      int check = await db.rawDelete("delete from notecontent where notecontent_id=?",[notecontentid]);
      return check != 0 ? true : false;
    }

    Future<List<NoteContentModel>> getAllNoteContentsById(Database db, int noteid) async {
      final List<Map> result = await db.rawQuery("select * from notecontent where note_id=?",[noteid]);
      
      return List.generate(result.length, (i) {
        return NoteContentModel(
          note_id: result[i]['note_id'],
          textcontent: result[i]['textcontent'],
          imagecontent: result[i]['imagecontent'],
          notecontent_id: result[i]['notecontent_id']
        );
      });
    }

    Future<List<Map<String, dynamic>>> getAllNoteContentsById_Cloud(Database db, int noteid) async {
      final List<Map> result = await db.rawQuery("select * from notecontent where note_id=?",[noteid]);
      
      List<Map<String, dynamic>> contents = [];

      for(int i = 0; i < result.length; i++){

        if(result[i]["imagecontent"] != null){
           File imgfile = File(result[i]["imagecontent"]);
           String imageurl = await StorageService().uploadImage(imgfile);

           contents.add({"image" : imageurl, "local_image" : result[i]["imagecontent"].toString()});
        }
        else{
          String noiDungGhiChu = result[i]["textcontent"];
          contents.add({'text': noiDungGhiChu});
        }
        
      }
      return contents;
    }


    Future<int> getLatestNoteID(Database db) async {
      List<Map> result = await db.rawQuery("select max(note_id) as latestnote from note");
      int latestid = result[0]['latestnote'];
      return latestid;
    }

    Future<String> getTitleImageofNote(int? noteid, Database db) async{
      List<Map> result = await db.rawQuery("select imagecontent from notecontent where note_id=? and imagecontent is not null limit 1",[noteid]);
      late String imagepath = '';
      if(!result.isEmpty){
        imagepath = result[0]['imagecontent'];
      }
      return imagepath;
    }

    Future<String> getBriefContentofNote(int? noteid, Database db) async{
      List<Map> result = await db.rawQuery("select textcontent from notecontent where note_id=? and textcontent != '' limit 1",[noteid]);
      String briefcontent = result[0]['textcontent'];
      return briefcontent;
    }

    Future<List<NoteContentModel>> getAllNoteContents(Database db) async {
      final List<Map> result = await db.rawQuery("select notecontent_id, textcontent, imagecontent, note_id from notecontent");

      return List.generate(result.length, (i) {
        return NoteContentModel(
          note_id: result[i]['note_id'],
          textcontent: result[i]['textcontent'],
          imagecontent: result[i]['imagecontent'],
          notecontent_id: result[i]['notecontent_id']
        );
      });
    }

    Future<bool> updateContentByID(int notecontentid, String? txt, String? imgpath, Database db) async{
      String sqlimage = "update notecontent set imagecontent=? where notecontent_id=?";
      String sqltext = "update notecontent set textcontent=? where notecontent_id=?";
      if(txt == null){
        int changenum = await db.rawUpdate(sqlimage,[imgpath, notecontentid]);
        return changenum != 0 ? true : false;
      }
      else{
        int changenum = await db.rawUpdate(sqltext,[txt, notecontentid]);
        return changenum != 0 ? true : false;
      }
    }

    Future<void> deleteAllNoteContents(Database db) async{
      await db.rawDelete("delete from notecontent");
    }
}