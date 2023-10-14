import 'dart:io';

import 'package:flutter/material.dart';
import 'package:notemobileapp/DAL/NoteContentDAL.dart';
import 'package:notemobileapp/model/SqliteModel/FirebaseModel/FBNoteModel.dart';
import 'package:sqflite/sqflite.dart';

import 'package:notemobileapp/model/SqliteModel/NoteModel.dart';

class NoteDAL {
  
  Future<bool> insertNote(NoteModel note, int userid, Database db) async {
    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    // await db.insert(
    //   'note',
    //   note.toMap(),
    //   conflictAlgorithm: ConflictAlgorithm.replace,
    // );

    int check = await db.rawInsert("insert into note(title,date_created,user_id) values(?,?,?)",[note.title,note.date_created,userid]);
    return check != 0 ? true : false;
  }

  Future<bool> deleteNote(int noteid, Database db) async {

    int check = await db.rawDelete("delete from note where note_id=?",[noteid]);
    if(check != 0){
      List<String> lsthinhcanxoa = await getAllImageContentsByNoteID(db, noteid);
      if(lsthinhcanxoa.isNotEmpty){
        for(int i = 0; i < lsthinhcanxoa.length; i++){
          File imgcanxoa = File(lsthinhcanxoa[i]);
          await imgcanxoa.delete().catchError((Object e, StackTrace stackTrace) {
                debugPrint(e.toString());
          },);  
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

  Future<List<NoteModel>> getAllNotes(Database db) async {

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.query('note');

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return NoteModel(
        note_id: maps[i]['note_id'],
        title: maps[i]['title'],
        date_created: maps[i]['date_created'],
        user_id: maps[i]['user_id'],
        tag_id: maps[i]['tag_id']
      );
    });
  }

  Future<List<NoteModel>> getAllNotesByUserID(int userid, Database db) async {

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.rawQuery('select * from note where user_id=?',[userid]);

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return NoteModel(
        note_id: maps[i]['note_id'],
        title: maps[i]['title'],
        date_created: maps[i]['date_created'],
        user_id: maps[i]['user_id'],
        tag_id: maps[i]['tag_id']
      );
    });
  }

  Future<List<FBNoteModel>> getAllNotesByUserIDForFB(int userid, Database db) async {

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.rawQuery('select title, date_created, tag_id from note where user_id=?',[userid]);

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return FBNoteModel(
        note_id: -1,
        title: maps[i]['title'],
        date_created: maps[i]['date_created'],
        user_id: -1,
        tag_id: maps[i]['tag_id']
      );
    });
  }

  Future<List<FBNoteModel>> getAllNotesWithTagByUserID_FB_setData(int userid, int tagid, int newtagid, Database db) async {

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.rawQuery('select title, date_created, tag_id from note where user_id=? and tag_id=?',[userid, tagid]);

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return FBNoteModel(
        note_id: -1,
        title: maps[i]['title'],
        date_created: maps[i]['date_created'],
        user_id: -1,
        tag_id: newtagid
      );
    });
  }

  Future<List<FBNoteModel>> getAllNotes_WithoutTag_ByUserID_FB(int userid, Database db) async {

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.rawQuery('select title, date_created from note where user_id=? and tag_id is null',[userid]);

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return FBNoteModel(
        note_id: -1,
        title: maps[i]['title'],
        date_created: maps[i]['date_created'],
        user_id: -1,
        tag_id: -1
      );
    });
  }

  Future<List<NoteModel>> getNoteByID(int uid, int noteid, Database db) async{

    final List<Map<String, dynamic>> maps = await db.rawQuery('select * from note where user_id=? and note_id=?',[uid, noteid]);

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return NoteModel(
        note_id: maps[i]['note_id'],
        title: maps[i]['title'],
        date_created: maps[i]['date_created'],
        user_id: maps[i]['user_id'],
        tag_id: maps[i]['tag_id']
      );
    });
  }

  Future<List<String>> getAllImageContentsByNoteID(Database db, int noteid) async{
      List<Map> result = await db.rawQuery("select imagecontent from notecontent where note_id=? and imagecontent is not null",[noteid]);
      
      return List.generate(result.length, (index){
        return result[index]["imagecontent"];
      });
    }
}
