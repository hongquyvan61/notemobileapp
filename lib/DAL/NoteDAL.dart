import 'package:sqflite/sqflite.dart';

import 'package:notemobileapp/model/NoteModel.dart';

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
    return check != 0 ? true : false;
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
}
