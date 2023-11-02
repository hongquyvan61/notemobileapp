import 'package:sqflite/sqflite.dart';

import '../model/SqliteModel/TagModel.dart';

class TagDAL{
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
}