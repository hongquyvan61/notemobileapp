

import 'dart:io';

class NoteContent {
  late List<File> _file;
  late List<dynamic> _content;
  late String _timeStamp;
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

  String get timeStamp => _timeStamp;

  set timeStamp(String value) {
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
