import 'package:cloud_firestore/cloud_firestore.dart';

class NoteReceive{
  late List<dynamic> _content;
  late String _noteId;
  late Timestamp _timeStamp;
  late String _title;
  late String _tagname;
  late String _owner;
  late String _rule;
  Map<String, dynamic> _rules = {};


  NoteReceive.withValue(this._content, this._noteId, this._timeStamp, this._title, this._tagname);
  NoteReceive.withValue2(this._content, this._noteId, this._timeStamp, this._title, this._tagname, this._owner, this._rule);
  NoteReceive.withValue1(this._title,this._timeStamp);
  NoteReceive();


  String get rule => _rule;

  set rule(String value) {
    _rule = value;
  }

  Map<String, dynamic> get rules => _rules;

  set rules(Map<String, dynamic> value) {
    _rules = value;
  }

  String get title => _title;

  set title(String value) {
    _title = value;
  }

  String get owner => _owner;

  set owner(String value) {
    _owner = value;
  }


  Timestamp get timeStamp => _timeStamp;

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

  String get noteId => _noteId;

  set noteId(String value) {
    _noteId = value;
  }

  String get tagname => _tagname;

  set tagname(String value) {
    _tagname = value;
  }

  List<dynamic> get content => _content;

  set content(List<dynamic> value) {
    _content = value;
  }

  String listMapToString(List<dynamic> content){
    String result = '';

    for (Map<String, dynamic> note in content){
      if(note.containsKey('text')){
        result += note['text'];
      } else {
        result += note['image'];
      }
    }

    return result;
  }
}