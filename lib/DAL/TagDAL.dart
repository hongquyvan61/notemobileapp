import 'dart:io';

import 'package:notemobileapp/model/SqliteModel/TagModel.dart';
import 'package:notemobileapp/model/SqliteModel/initializeDB.dart';
import 'package:sqflite/sqflite.dart';

import '../model/SqliteModel/FirebaseModel/FBTagModel.dart';


class TagDAL {
  Future<List<TagModel>> getTagsByUserID(Database db, int uid) async {
    final List<Map> result = await db.rawQuery("select * from tag where user_id=?",[uid]);
      
      return List.generate(result.length, (i) {
        return TagModel(
          tag_id: result[i]["tag_id"],
          tag_name: result[i]["tag_name"], 
          user_id: result[i]["user_id"]
        );
      });
  }

  Future<List<FBTagModel>> getTagsByUserID_FB(Database db, int uid) async {
    final List<Map> result = await db.rawQuery("select * from tag where user_id=?",[uid]);
      
      return List.generate(result.length, (i) {
        return FBTagModel(
          tag_id: result[i]["tag_id"],
          tag_name: result[i]["tag_name"], 
          user_id: null
        );
      });
  }
}