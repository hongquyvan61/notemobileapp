

import 'dart:io';

class Tag {
  late String _tagname;



  Tag.withValue(this._tagname,);
  Tag();

  String get tagname => _tagname;

  set tagname(String value) {
    _tagname = value;
  }

  
   // Chuyển đổi từ ContentNote sang Map để lưu trữ trên Firestore
  Map<String, dynamic> toMap() {
    return {
      "tag_name" : _tagname
    };
  }
}
