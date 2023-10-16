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

  Future<List<String>> getAllTagsByUserID(int uid, Database db) async{
    final List<Map> result = await db.rawQuery("select tag_name from tag where user_id=?",[uid]);
      
      return List.generate(result.length, (i) {
        return  result[i]["tag_name"];
      });
  }
}