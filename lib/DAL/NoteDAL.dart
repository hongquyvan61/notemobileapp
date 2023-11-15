import 'dart:io';

import 'package:flutter/material.dart';
import 'package:notemobileapp/DAL/NoteContentDAL.dart';
import 'package:notemobileapp/DAL/TagDAL.dart';
import 'package:notemobileapp/model/SqliteModel/initializeDB.dart';
import 'package:sqflite/sqflite.dart';

import 'package:notemobileapp/model/SqliteModel/NoteModel.dart';

import '../model/SqliteModel/TagModel.dart';

class NoteDAL {
  
  
  Future<bool> insertNote(NoteModel note, int user_id, Database db) async {
    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    // await db.insert(
    //   'note',
    //   note.toMap(),
    //   conflictAlgorithm: ConflictAlgorithm.replace,
    // );

    int check = await db.rawInsert("insert into note(title,date_created,user_id,tag_id) values(?,?,?,?)",[note.title,note.date_created,user_id, note.tag_id]);
    return check != 0 ? true : false;
  }

  Future<bool> deleteNote(int noteid, Database db) async {

    int check = await db.rawDelete("delete from note where note_id=?",[noteid]);
    if(check != 0){
      List<String> lsthinhcanxoa = await getAllImageContentsByNoteID(db, noteid);
      if(lsthinhcanxoa.isNotEmpty){
        for(int i = 0; i < lsthinhcanxoa.length; i++){
          File imgcanxoa = File(lsthinhcanxoa[i]);
          bool exists = await File(imgcanxoa.path).exists();
          if(exists){
            await imgcanxoa.delete().catchError((Object e, StackTrace stackTrace) {
                debugPrint(e.toString());
            },); 
          }
           
        }
      }
      int checkdelcontents = await db.rawDelete("delete from notecontent where note_id=?",[noteid]);
      return checkdelcontents != 0 ? true : false;
    }
    return false;
  }

  Future<bool> updateNoteTitle(int noteid, String tieude, Database db) async {
    int checkupdate  = await db.rawUpdate("update note set title=? where note_id=?",[tieude,noteid]);
    return checkupdate != 0 ? true : false;
  }

  Future<bool> updateTagInNote(int noteid, TagModel? tag, Database db) async {
    int checkupdate = -1;
    if(tag!.tag_id == null){
      checkupdate  = await db.rawUpdate("update note set tag_id=null where note_id=?",[noteid]);
    }
    else{
      String tagname = await TagDAL().getTagNameByID(tag.tag_id?.toInt() ?? -1, InitDataBase.db);
      
      if(tagname.isNotEmpty){
        checkupdate  = await db.rawUpdate("update note set tag_id=? where note_id=?",[tag!.tag_id?.toInt() ?? -1,noteid]);
      }
    }
    return checkupdate != 0 ? true : false;
  }

  Future<List<NoteModel>> getAllNotes(Database db) async {

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('note');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    List<NoteModel> results = [];
    for(int i = 0; i < maps.length; i++){
      results.add(NoteModel(
        note_id: maps[i]['note_id'],
        title: maps[i]['title'],
        date_created: maps[i]['date_created'],
        user_id: maps[i]['user_id'],
        tag_id: maps[i]['tag_id'],
        tag_name: maps[i]['tag_id'] == null ? "" : await TagDAL().getTagNameByID(maps[i]['tag_id'], db)
      ));
    }
    return results;
  }

  Future<List<NoteModel>> getAllNotesByUserID(int userid, Database db) async {

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.rawQuery('select note_id, title, date_created, note.user_id as uid, tag.tag_id as tagid, tag_name from note join tag on note.tag_id = tag.tag_id where note.user_id=?',[userid]);

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return NoteModel(
        note_id: maps[i]['note_id'],
        title: maps[i]['title'],
        date_created: maps[i]['date_created'],
        user_id: maps[i]['uid'],
        tag_id: maps[i]['tagid'],
        tag_name: maps[i]['tag_name']
      );
    });
  }

  Future<List<NoteModel>> getNoteByID(int userid, int noteid, Database db) async{
    late List<Map<String, dynamic>> maps;

    final List<Map<String, dynamic>> mapstag = await db.rawQuery('select tag_id from note where note_id=?',[noteid]);
    if(mapstag[0]['tag_id'] == null){
      maps = await db.rawQuery('select note_id, title, date_created, user_id from note where user_id=? and note_id=?',[userid, noteid]);
      return List.generate(maps.length, (i) {
        return NoteModel(
          note_id: maps[i]['note_id'],
          title: maps[i]['title'],
          date_created: maps[i]['date_created'],
          user_id: maps[i]['user_id'],
          tag_id: null,
          tag_name: ""
        );
      });
    }
    else{
      maps = await db.rawQuery('select note_id, title, date_created, note.user_id as uid, tag.tag_id as tagid, tag_name from note join tag on note.tag_id = tag.tag_id where note.user_id=? and note_id=?',[userid, noteid]);
      return List.generate(maps.length, (i) {
        return NoteModel(
          note_id: maps[i]['note_id'],
          title: maps[i]['title'],
          date_created: maps[i]['date_created'],
          user_id: maps[i]['uid'],
          tag_id: maps[i]['tagid'],
          tag_name: maps[i]['tag_name']
        );
      });
    }

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    
  }

  Future<List<NoteModel>> getNotesWithoutTag(int userid, Database db) async {
    final List<Map<String, dynamic>> maps = await db.rawQuery('select * from note where user_id=? and tag_id is null',[userid]);

    return List.generate(maps.length, (i) {
      return NoteModel(
        note_id: maps[i]['note_id'],
        title: maps[i]['title'],
        date_created: maps[i]['date_created'],
        user_id: maps[i]['user_id'],
        tag_id: null,
        tag_name: ""
      );
    });
  }

  Future<List<NoteModel>> getNotesWithTagname(int userid, String tagname, Database db) async{
    
    final List<Map<String, dynamic>> maps = await db.rawQuery('select note_id, title, date_created, note.user_id as uid, tag.tag_id as tagid, tag_name from note join tag on note.tag_id = tag.tag_id where note.user_id=? and tag_name=?',[userid,tagname]);
      return List.generate(maps.length, (i) {
        return NoteModel(
          note_id: maps[i]['note_id'],
          title: maps[i]['title'],
          date_created: maps[i]['date_created'],
          user_id: maps[i]['uid'],
          tag_id: maps[i]['tagid'],
          tag_name: maps[i]['tag_name']
        );
      });
  }

  Future<List<String>> getAllImageContentsByNoteID(Database db, int noteid) async{
      List<Map> result = await db.rawQuery("select imagecontent from notecontent where note_id=? and imagecontent is not null",[noteid]);
      
      return List.generate(result.length, (index){
        return result[index]["imagecontent"];
      });
    }

  Future<void> deleteAllNote(Database db) async{
    await db.rawDelete("delete from note");
  } 
}
