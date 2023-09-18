import 'package:sqflite/sqflite.dart';

import 'package:notemobileapp/model/UserModel.dart';

class UserDAL {
  
  Future<bool> insertUser(UserModel user, Database db) async {
    // Insert the Dog into the correct table. You might also specify the
    // `conflictAlgorithm` to use in case the same dog is inserted twice.
    //
    // In this case, replace any previous data.
    // await db.insert(
    //   'users',
    //   user.toMap(),
    //   conflictAlgorithm: ConflictAlgorithm.replace,
    // );

    //List<UserModel> lst = await getAllUsers(db);
    //bool checkdel = await deleteAllUser(db);
      int check = await db.rawInsert("insert into users(username,password) values(?,?)",[user.username,user.password]);
      return check != 0 ? true : false;
    
  }

  Future<bool> deleteUser(int userid, Database db) async {

    int check = await db.rawDelete("delete from users where user_id=?",[userid]);
    return check != 0 ? true : false;
  }

  Future<bool> deleteAllUser(Database db) async {

    int check = await db.rawDelete("delete from users");
    return check != 0 ? true : false;
  }

  Future<List<UserModel>> getAllUsers(Database db)async {

    // Query the table for all The Dogs.
    final List<Map<String, dynamic>> maps = await db.rawQuery("select user_id, username from users");

    // Convert the List<Map<String, dynamic> into a List<Dog>.
    return List.generate(maps.length, (i) {
      return UserModel(
        user_id: maps[i]['user_id'],
        username: maps[i]['username'],
        password: null,
      );
    });
  }
}
