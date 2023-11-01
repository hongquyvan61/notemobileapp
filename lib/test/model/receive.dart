class Receive{
  late String _noteId;
  late String _owner;
  late String _rule;
  late String _email;


  Receive.withValue(this._owner, this._rule, this._noteId, this._email);
  Receive();



  String get owner => _owner;

  set owner(String value) {
    _owner = value;
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
    };
  }
}