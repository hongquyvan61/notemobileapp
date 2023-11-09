class NoteReceive{
  late List<dynamic> _content;
  late String _noteId;
  late String _timeStamp;
  late String _title;
  late String _tagname;
  late String _owner;
  Map<String, dynamic> _rules = {};


  NoteReceive.withValue(this._content, this._noteId, this._timeStamp, this._title, this._tagname);
  NoteReceive.withValue2(this._content, this._noteId, this._timeStamp, this._title, this._tagname, this._owner);
  NoteReceive.withValue1(this._title,this._timeStamp);
  NoteReceive();


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

  String get timeStamp => _timeStamp;

  set timeStamp(String value) {
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