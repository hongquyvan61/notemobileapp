import 'dart:io';

import 'package:sqflite/sqflite.dart';

import 'package:notemobileapp/model/NoteContentModel.dart';

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

    Future<List<NoteContentModel>> getAllNoteContentsById(Database db, int noteid) async {
      final List<Map> result = await db.rawQuery("select textcontent, imagecontent, note_id from notecontent where note_id=?",[noteid]);

      return List.generate(result.length, (i) {
        return NoteContentModel(
          note_id: result[i]['note_id'],
          textcontent: result[i]['textcontent'],
          imagecontent: result[i]['imagecontent'],
          notecontent_id: null
        );
      });
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
      List<Map> result = await db.rawQuery("select textcontent from notecontent where note_id=? and textcontent is not null limit 1",[noteid]);
      String briefcontent = result[0]['textcontent'];
      return briefcontent;
    }

    Future<List<NoteContentModel>> getAllNoteContents(Database db) async {
      final List<Map> result = await db.rawQuery("select textcontent, imagecontent, note_id from notecontent");

      return List.generate(result.length, (i) {
        return NoteContentModel(
          note_id: result[i]['note_id'],
          textcontent: result[i]['textcontent'],
          imagecontent: result[i]['imagecontent'],
          notecontent_id: null
        );
      });
    }

    
}