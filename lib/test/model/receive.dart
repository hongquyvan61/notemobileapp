import 'package:cloud_firestore/cloud_firestore.dart';

class Receive{
  late String _noteId;
  late String _owner;
  late String _rule;
  late String _email;
  late Timestamp _timeStamp;
  bool _isNew = true;
  bool _hadSeen = false;


  Receive.withValue(this._owner, this._rule, this._noteId, this._email);
  Receive.withValue1(this._owner, this._rule, this._noteId, this._timeStamp, this._hadSeen);
  Receive();


  Timestamp get timeStamp => _timeStamp;

  set timeStamp(Timestamp value) {
    _timeStamp = value;
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

  bool get hadSeen => _hadSeen;

  set hadSeen(bool value) {
    _hadSeen = value;
  }


  String get owner => _owner;

  set owner(String value) {
    _owner = value;
  }

  bool get isNew => _isNew;

  set isNew(bool value) {
    _isNew = value;
  }

  String get email => _email;

  set email(String value) {
    _email = value;
  }

  String get rule => _rule;

  String get noteId => _noteId;

  set noteId(String value) {
    _noteId = value;
  }

  set rule(String value) {
    _rule = value;
  }

  Map<String, dynamic> toMap(){
    return {
      'owner' : _owner,
      'rule' : _rule,
      'isNew' : _isNew,
      'hadseen' : _hadSeen,
      'timestamp' : _timeStamp,
    };
  }


}