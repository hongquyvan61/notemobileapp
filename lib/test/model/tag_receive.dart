

import 'dart:io';

class TagReceive {
  late String _tagname;
  late String _tagid;



  TagReceive.withValue(this._tagname, this._tagid);
  TagReceive();

  String get tagname => _tagname;

  set tagname(String value) {
    _tagname = value;
  }

  String get tagid => _tagid;

  set tagid(String value) {
    _tagid = value;
  }

  // String listMapToString(List<dynamic> content){
  //   String result = '';

  //   for (Map<String, dynamic> note in content){
  //     if(note.containsKey('text')){
  //       result += note['text'];
  //     } else {
  //       result += note['image'];
  //     }
  //   }

  //   return result;
  // }
}
