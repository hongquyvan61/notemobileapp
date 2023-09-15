import 'package:notemobileapp/test/database/database_service.dart';
import 'package:notemobileapp/test/model/todo.dart';
import 'package:sqflite/sqflite.dart';

class TodoDB {
  final name = "note";

  Future<void> createTable(Database database) async {
    await database.execute('''
    CREATE TABLE note (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      text TEXT,
      imageUrl TEXT
    )
  ''');
  }

  Future<int> create(
      {required String title, required String text, String? imageUrl}) async {
    final database = await DatabaseService().database;
    return await database.rawInsert('''INSERT INTO $name (title, text, imageUrl)
      VALUES (?,?,?)''', [title, text, imageUrl]);
  }

  Future<List<ToDo>> fetchAll() async {
    final database = await DatabaseService().database;
    final todos =
        await database.rawQuery('SELECT title, text, imageUrl FROM $name');
    return todos.map((todo) => ToDo.fromSqfliteDatabase(todo)).toList();
  }
}
