//import 'dart:async';

import 'dart:io';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class InitDataBase {
  static var db;
  static DatabaseReference? firebasedb;
  
  Future<Database> initDB() async {
      WidgetsFlutterBinding.ensureInitialized();
      Directory dr = await getApplicationDocumentsDirectory();
      String dbpath = join(dr.path, 'notemobileapp.db');
      await deleteDatabase(dbpath);
      final database = openDatabase(
        join(dr.path, 'notemobileapp.db'),
        // When the database is first created, create a table to store dogs.
        onCreate: (db, version) {
          // Run the CREATE TABLE statement on the database.
           db.execute(
            'CREATE TABLE users(user_id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT, password TEXT, account_type TEXT) '
          );

          db.execute('CREATE TABLE tag(tag_id INTEGER PRIMARY KEY AUTOINCREMENT, tag_name TEXT, user_id INTEGER,' + 
          'FOREIGN KEY (user_id) references users(user_id) ON UPDATE RESTRICT ON DELETE RESTRICT)');

          db.execute('CREATE TABLE note(note_id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, date_created TEXT, user_id INTEGER, tag_id INTEGER,' + 
              'FOREIGN KEY (user_id) references users(user_id) ON UPDATE RESTRICT ON DELETE RESTRICT,' + 
              'FOREIGN KEY (tag_id) references tag(tag_id) ON UPDATE RESTRICT ON DELETE RESTRICT)  ');
          
          db.execute('CREATE TABLE notecontent(notecontent_id INTEGER PRIMARY KEY AUTOINCREMENT, textcontent TEXT, imagecontent TEXT, note_id INTEGER, ' + 
            'FOREIGN KEY (note_id) references note(note_id) ON UPDATE RESTRICT ON DELETE RESTRICT)');
          db.execute('CREATE TABLE invite(invite_id INTEGER PRIMARY KEY AUTOINCREMENT, sender_id INTEGER, receiver_id INTEGER, note_id INTEGER, receiver_auth TEXT, ' + 
          'FOREIGN KEY (sender_id) references users(user_id) ON UPDATE RESTRICT ON DELETE RESTRICT,' + 
          'FOREIGN KEY (receiver_id) references users(user_id) ON UPDATE RESTRICT ON DELETE RESTRICT,' + 
          'FOREIGN KEY (note_id) references note(note_id) ON UPDATE RESTRICT ON DELETE RESTRICT)');
        },
        // Set the version. This executes the onCreate function and provides a
        // path to perform database upgrades and downgrades.
        version: 1,
      );
        return database;
}
}
