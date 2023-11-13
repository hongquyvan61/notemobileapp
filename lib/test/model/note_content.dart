

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

class NoteContent {
  late List<File> _file;
  late List<dynamic> _content;
  late Timestamp _timeStamp;
  late String _title;
  late String _tagname;


  List<File> get file => _file;

  set file(List<File> value) {
    _file = value;
  }

  NoteContent.withValue(this._content, this._timeStamp, this._title, this._tagname);
  NoteContent();

  List<dynamic> get content => _content;

  set content(List<dynamic> value) {
    _content = value;
  } // Chuyển đổi từ ContentNote sang Map để lưu trữ trên Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': _title,
      'timestamp': _timeStamp,
      'content' : _content,
      'tagname' : _tagname
    };
  }


  String getTimeStamp(){
    DateTime dateTime = _timeStamp.toDate();
    String day = dateTime.day.toString();
    String month = dateTime.month.toString();
    String year = dateTime.year.toString();
    String hour = dateTime.hour.toString().padLeft(2, '0');
    String minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  set timeStamp(Timestamp value) {
    _timeStamp = value;
  }

  String get title => _title;

  set title(String value) {
    _title = value;
  }

  String get tagname => _tagname;

  set tagname(String value) {
    _tagname = value;
  }
}
