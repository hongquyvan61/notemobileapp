import 'package:notemobileapp/DAL/NoteDAL.dart';
import 'package:sqflite/sqflite.dart';

import '../model/SqliteModel/NoteModel.dart';
import '../model/SqliteModel/TagModel.dart';

class TagDAL{
  NoteDAL nDAL = NoteDAL();

  Future<String> getTagNameByID(int tagid, Database db) async {
    
    if(tagid == 0) return "";
    
    final List<Map> result = await db.rawQuery("select tag_name from tag where tag_id=?",[tagid]);

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    String tagname = result[0]["tag_name"];
    return tagname;
  }

  Future<List<TagModel>> getAllTagsByUserID(int uid, Database db) async{
    final List<Map> result = await db.rawQuery("select tag_id, tag_name from tag where user_id=?",[uid]);
      
      return List.generate(result.length, (i) {
        return TagModel(
          tag_id: result[i]["tag_id"], 
          tag_name: result[i]["tag_name"]
        );
      });
  }

  Future<List<TagModel>> getTagsForFilter_Local(int uid, Database db) async{
    final List<Map> result = await db.rawQuery("select tag_id, tag_name from tag where user_id=? limit 7",[uid]);
      
      return List.generate(result.length, (i) {
        return TagModel(
          tag_id: result[i]["tag_id"], 
          tag_name: result[i]["tag_name"]
        );
      });
  }

  Future<void> deleteAllTags(Database db) async {
    await db.rawDelete("delete from tag");
  }

  Future<bool> insertTag(TagModel md, int uid, Database db) async {
    int check = await db.rawInsert("insert into tag(tag_name, user_id) values(?,?)",[md.tag_name,uid]);
    return check != 0 ? true : false;
  }

  Future<bool> updateTagNameById(int uid, int tagid, String newname, Database db) async {
    int checkupt = await db.rawUpdate("update tag set tag_name=? where tag_id=? and user_id=?",[newname, tagid,uid]);
    return checkupt != 0 ? true : false;
  }

  Future<bool> deleteTagById(int tagid, int uid, Database db) async {
    int checkupt = await db.rawUpdate("update note set tag_id=null where tag_id=? and user_id=?",[tagid,uid]);

    
    int del = await db.rawDelete("delete from tag where tag_id=?",[tagid]);
    return del != 0 ? true : false;
  }
}