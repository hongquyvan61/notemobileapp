class NoteReceive{
  late List<dynamic> _content;
  late String _noteId;
  late String _timeStamp;
  late String _title;


  NoteReceive.withValue(this._content, this._noteId, this._timeStamp, this._title);
  NoteReceive();

  String get title => _title;

  set title(String value) {
    _title = value;
  }

  String get timeStamp => _timeStamp;

  set timeStamp(String value) {
    _timeStamp = value;
  }

  String get noteId => _noteId;

  set noteId(String value) {
    _noteId = value;
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